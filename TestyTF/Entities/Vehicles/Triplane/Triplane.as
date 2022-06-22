#include "Hitters.as";
#include "Explosion.as";

const u32 fuel_timer_max = 30 * 600;

void onInit(CBlob@ this)
{
	this.addCommandID("offblast"); // will be removed
	this.addCommandID("change speed");
	
	// this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 48.0f);
	// this.set_string("custom_explosion_sound", "Keg.ogg");
		
	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 0.3f);
	
	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
		if (point !is null)
		{
			CBlob@ holder = point.getOccupied();
			
			if (holder !is null)
			{
				if (holder.isMyPlayer())
				{
					bool pressed_add = point.isKeyPressed(key_up);
					// bool pressed_sub = point.isKeyPressed(key_down);
					
					if (pressed_add) this.set_f32("velocity", this.get_f32("velocity") + 0.2f); else this.set_f32("velocity", Maths::Max(0, this.get_f32("velocity") - 0.3f));
			
					// if (pressed_add || pressed_sub)
					// {
						// f32 speed = (pressed_add ? 0.1f : 0) + (pressed_sub ? -0.1f : 0);
						// this.set_f32("velocity", this.get_f32("velocity") + speed);
					
						// // CBitStream params;
						// // params.write_s8((pressed_add ? 1 : 0) + (pressed_sub ? -1 : 0));
						// // this.SendCommand(this.getCommandID("change speed"), params);
					// }
				}
			}
		}
	}

	if (this.hasTag("offblast"))
	{
		Vec2f dir;
	
		if (this.get_u32("fuel_timer") > getGameTime())
		{
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
			if (point is null) return;
		
			CBlob@ holder = point.getOccupied();
			// this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.1f, 5.0f));
			
			if (holder is null)
			{
				dir = Vec2f(0, 1);
				dir.RotateBy(this.getAngleDegrees());
			}
			else
			{
				dir = (holder.getPosition() - holder.getAimPos());
				dir.Normalize();
			
				f32 mouseAngle = dir.getAngleDegrees();
				if (!holder.isFacingLeft()) mouseAngle += 180;
				
				this.setAngleDegrees(-this.getVelocity().Angle() + 0);
			}
						
			this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, 5));
			MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		else
		{
			this.setAngleDegrees(-this.getVelocity().Angle() + 0);
			this.getSprite().SetEmitSoundPaused(true);
		}		
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void DoExplosion(CBlob@ this, Vec2f velocity)
{
	// if (this.hasTag("dead")) return;
	// this.Tag("dead");
	
	// this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));
	
	// Explode(this, 64.0f, 10.0f);
	// for (int i = 0; i < 4; i++)
	// {
		// Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		// Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);
		
		// LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 32.0f + XORRandom(32), 25.0f, 6, 8.0f, Hitters::explosion);
	// }

	// this.server_Die();
	// this.getSprite().Gib();
}

void onDie(CBlob@ this)
{
	if (this.hasTag("offblast")) DoExplosion(this, Vec2f(0, 0));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if ((blob !is null ? !blob.isCollidable() : !solid)) return;
	
	if (this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime()) DoExplosion(this, this.getOldVelocity());
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;

	if (point.getOccupied() is null)
	{
		CBitStream params;
		caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("change speed"))
	{
		f32 speed = params.read_s8();
		
		this.set_f32("velocity", this.get_f32("velocity") + speed);
		
		print("" + speed);
	}

	if (cmd == this.getCommandID("offblast"))
	{
		if (this.hasTag("offblast")) return;
		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		if (point.getOccupied() is null)
		{
			this.Tag("offblast");
			this.set_u32("no_explosion_timer", getGameTime() + 30);
			this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);
			
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("Rocket_Idle.ogg");
			sprite.SetEmitSoundSpeed(1.9f);
			sprite.SetEmitSoundPaused(false);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ holder = point.getOccupied();
	if (holder is null) return true;
	else return false;
}





			
