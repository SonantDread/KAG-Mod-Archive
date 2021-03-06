// TrampolineLogic.as

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 7;

	const u8 SCALAR = 7;
	const u8 UP_BOOST = 4;
	const u8 RANGE = 60;

	const bool SAFETY = true;
	const int COOLDOWN_LIMIT = 8;

	const bool PHYSICS = false; // adjust angle to account for blob's previous velocity
	const float PERPENDICULAR_BOUNCE = 1.0f; // strength of angle adjustment
}

class TrampolineCooldown{
	u16 netid;
	u32 timer;
	TrampolineCooldown(u16 netid, u16 timer){this.netid = netid; this.timer = timer;}
};

void onInit(CBlob@ this)
{
	TrampolineCooldown @[] cooldowns;
	this.set(Trampoline::TIMER, cooldowns);
	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("no falldamage");
	// this.Tag("medium weight");  // Waffle: Make the trampoline lighter
	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// point.SetKeysToTake(key_action1 | key_action2);  Waffle: Make it so you can do all actions while holding a trampoline

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	f32 angle;
	if (this.hasTag("activated") && this.exists("freeze_angle"))
	{
		angle = this.get_f32("freeze_angle");
	}
	else
	{
		angle = getHoldAngle(this, holder);
	}
	this.setAngleDegrees(angle);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//choose whether to jump on team trampolines
	if (blob.hasTag("player") && blob.isKeyPressed(key_down) && this.getTeamNum() == blob.getTeamNum()) return;

	//cant bounce holder
	if (holder is blob) return;

	//cant bounce while held by something attached to something else
	if (holder !is null && holder.isAttached()) return;

	// // Waffle: Bounce from any angle
	// //prevent knights from flying using trampolines
	// //get angle difference between entry angle and the facing angle
	// Vec2f pos_delta = (blob.getPosition() - this.getPosition()).RotateBy(90);
	// float delta_angle = Maths::Abs(-pos_delta.Angle() - this.getAngleDegrees());
	// if (delta_angle > 180)
	// {
	// 	delta_angle = 360 - delta_angle;
	// }
	// //if more than 90 degrees out, no bounce
	// if (delta_angle > 90)
	// {
	// 	return;
	// }

	TrampolineCooldown@[]@ cooldowns;
	if (!this.get(Trampoline::TIMER, @cooldowns)) return;

	//shred old cooldown if we have too many
	if (Trampoline::SAFETY && cooldowns.length > Trampoline::COOLDOWN_LIMIT) cooldowns.removeAt(0);

	u16 netid = blob.getNetworkID();
	bool block = false;
	for(int i = 0; i < cooldowns.length; i++)
	{
		if (cooldowns[i].timer < getGameTime())
		{
			cooldowns.removeAt(i);
			i--;
		}
		else if (netid == cooldowns[i].netid)
		{
			block = true;
			break;
		}
	}
	if (!block)
	{
		Vec2f velocity_old = blob.getOldVelocity();
		if (velocity_old.Length() < 1.0f) return;

		float angle = this.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);

		float velocity_angle = direction.AngleWith(velocity_old);

		if (Maths::Abs(velocity_angle) > 90)
		{
			TrampolineCooldown cooldown(netid, getGameTime() + Trampoline::COOLDOWN);
			cooldowns.push_back(cooldown);

			Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);

			// Rotate it to simulate keeping some momentum
			if (Trampoline::PHYSICS)
			{
				velocity_old.RotateBy(-angle);
				velocity.x = velocity_old.x * Trampoline::PERPENDICULAR_BOUNCE;
				velocity *= Trampoline::SCALAR / velocity.getLength();
				// velocity_old.RotateBy(angle); // change velocity_old back?
			}

			// jesus christ
			velocity *= (Maths::Max(0, (Trampoline::RANGE
										- Maths::Abs(90
													 - (direction.getAngleDegrees()
													 	+ velocity.getAngleDegrees()-90))
									   ) / (1.0f * Trampoline::RANGE)
								   ) * Trampoline::UP_BOOST + Trampoline::SCALAR
						) / Trampoline::SCALAR;

			velocity.RotateBy(angle);
			blob.setVelocity(velocity);

			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetAnimation("default");
				sprite.SetAnimation("bounce");
				sprite.PlaySound("TrampolineJump.ogg");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		if (getNet().isServer())
		{
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ holder = point.getOccupied();
			if (holder is null) return;

			this.set_f32("freeze_angle", getHoldAngle(this, holder));
			this.Sync("freeze_angle", true);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.Untag("activated");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}

f32 getHoldAngle(CBlob@ this, CBlob@ holder)
{
	return -1.0f * (holder.getAimPos() - this.getPosition()).Angle() + 90;
}
