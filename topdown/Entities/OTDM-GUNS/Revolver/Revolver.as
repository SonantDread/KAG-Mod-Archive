// TrampolineLogic.as

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}

void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.set_u32(Trampoline::TIMER, 0);
	this.set_u32("ammunition", 60);
	this.set_u32("reloadgun", 40);
	this.set_u32("round", 6);
	//this.Tag("super heavy weight");
	this.getShape().getConsts().collideWhenAttached = true;

	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
	this.getCurrentScript().runFlags |= Script::tick_attached;

}

void onTick(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if(holder is null) return;
	bool shooting = holder.get_bool("shooting");

	if (holder.getHealth() > holder.getInitialHealth()) holder.server_SetHealth(holder.getInitialHealth());
	
	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	angle -= 0;
	if (this.isFacingLeft())
	{
		this.setAngleDegrees((-angle)-180);
	}
	if (!this.isFacingLeft())
	{
		this.setAngleDegrees(-angle);
	}

	u32 round = this.get_u32("round");
	u32 ammunition = this.get_u32("ammunition");
	u32 reloadgun = this.get_u32("reloadgun");

	if(reloadgun > 0 && round <= 0)
	{
		reloadgun = (reloadgun - 1);
	}	

	if(reloadgun <= 0&& round <= 0)
	{
		round = 6;
		reloadgun = 40;
	}

	bool pressed_a1 = point.isKeyJustPressed(key_action1) || shooting;
	if (ammunition < 1)
	{
		this.server_Die();
	}
	if (pressed_a1 && round > 0 && ammunition > 0 && this.getTickSinceCreated() > 10)

	{	
		//print(""+round);
		if (this !is null)
		{
			round = (round -1);
			Vec2f pos = this.getPosition();
			//Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));

			if (!getNet().isServer())
			{
				return;
			}
			CBlob@ bullet = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());

			ammunition = (ammunition-1);
			if (bullet !is null && point !is null && holder !is null)
			{
				bullet.Tag("revolver");
				bullet.server_SetTimeToDie(0.6);
				//this.getSprite().PlaySound("thud.ogg");
				CSprite@ sprite = this.getSprite();

				bullet.SetDamageOwnerPlayer(holder.getPlayer());
				if (point.isKeyPressed(key_down) && holder.isOnGround() && holder.getVelocity() == Vec2f(0, 0))
				{
					Vec2f aim = holder.getAimPos();
					Vec2f norm = aim - pos;
					norm.Normalize();
					bullet.setVelocity(norm * ((29.0f+(XORRandom(2.0f)))));
					
				}
				else
				{			
					Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));
					Vec2f norm = aim - pos;
					norm.Normalize();
					bullet.setVelocity(norm * (25.0f+(XORRandom(5.0f))));
				}
			}
		}
	}
	this.set_u32("round", round);
	this.set_u32("reloadgun", reloadgun);
	this.set_u32("ammunition", ammunition);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//cant bounce while held by something attached to something else
	//if (holder !is null && holder.isAttached()) return;
/*
	if (this.get_u32(Trampoline::TIMER) < getGameTime())
	{
		Vec2f velocity_old = blob.getOldVelocity();
		//if (velocity_old.Length() < 1.0f) return;

		float angle = this.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);
		/*
		float velocity_angle = direction.AngleWith(velocity_old);
		
		if (Maths::Abs(velocity_angle) > 90)
		{
			this.set_u32(Trampoline::TIMER, getGameTime() + Trampoline::COOLDOWN);

			Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);


			velocity.RotateBy(angle);

			//blob.setVelocity(velocity);

			}
		}
	}*/
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}