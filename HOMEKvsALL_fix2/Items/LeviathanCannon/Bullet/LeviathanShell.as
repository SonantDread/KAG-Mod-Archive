#include "Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "MakeDustParticle.as";
#include "ParticleSparks.as";

const f32 ARROW_PUSH_FORCE = 22.0f;
void onInit(CBlob@ this)
{
	this.Tag("exploding");
	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 3.0f);
	this.set_f32("map_damage_radius", 48.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("map_damage_ratio", 0.4f); //heck no!
	this.set_bool("explosive_teamkill", false);

	this.getShape().SetGravityScale(0.8f);
	this.getShape().setDrag(0.1f);
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		//this.server_SetTimeToDie(3);
		this.set_string("custom_explosion_sound", "OrbExplosion.ogg");
		//this.getSprite().PlaySound("OrbFireSound.ogg");
		this.Tag("projectile");

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
}

bool explodeOnCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((blob !is null) || blob.getShape().isStatic() && blob.isCollidable());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.isCollidable() || blob.hasTag("projectile") || blob.hasTag("gun") || this.getTeamNum() == blob.getTeamNum())
	{
		return false;
	}

	CShape@ shape = blob.getShape();
	if (shape.isStatic())
	{
		if (!shape.getConsts().platform)
		{
			return true;
		}
		else
		{
			Vec2f h();
			return rayCheck(this.getPosition(), this.getPosition() + this.getOldVelocity(), h);
		}
	}

	return this.getTeamNum() != blob.getTeamNum();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && (doesCollideWithBlob(this, blob) && (!this.hasTag("collided") && !blob.hasTag("dead") || blob.isPlatform())) || blob is null)
	{
		this.Tag("exploding");
		this.Sync("exploding", true);

		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
}

void Pierce(CBlob @this)
{
	CMap@ map = this.getMap();
	Vec2f end;
	if (rayCheck(this.getOldPosition(), this.getPosition(), end))
	{
		HitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
	// if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	// {
	// 	HitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	// }
}

void HitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	this.getSprite().PlaySound(XORRandom(4) == 0 ? "BulletRicochet.ogg" : "BulletImpact.ogg");
	MakeDustParticle(worldPoint, "/DustSmall.png");
	CMap@ map = this.getMap();
	f32 vellen = velocity.Length();
	TileType tile = map.getTile(worldPoint).type;
	if (map.isTileCastle(tile) || map.isTileStone(tile))
	{
		sparks (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage));
	}
	this.server_Die();
}

bool rayCheck(Vec2f start, Vec2f end, Vec2f &out res)
{
	HitInfo@[] hitsd;
	Vec2f diff = end - start;
	f32 angle = -diff.Angle();

	if (getMap().getHitInfosFromRay(start, angle, diff.Length(), null, hitsd))
	{
		for (int i = 0; i < hitsd.size(); i++)
		{
			HitInfo@ h = hitsd[i];
			CBlob@ blob = h.blob;
			if (blob is null)
			{
				res = h.hitpos;
				return true;
			}

			if (!blob.isPlatform() && blob.getShape().isStatic() && !blob.isAttached() && blob.isCollidable())
			{
				res = h.hitpos;
				return true;
			}

			if (blob.isPlatform() && blob.getName() != "wyvernplatform")
			{
				ShapePlatformDirection@ plat = blob.getShape().getPlatformDirection(0);
				Vec2f dir = plat.direction;
				if (!plat.ignore_rotations)
				{
					dir.RotateBy(-blob.getAngleDegrees());
				}

				// Does the platform block damage
				Vec2f hitvec_dir = (h.hitpos - start);

				if(Maths::Abs(dir.AngleWith(hitvec_dir)) < plat.angleLimit)
				{
					res = h.hitpos;
					return true;
				}

				continue;
			}
		}
	}
	else
	{
		res = end;
		return false;
	}
	
	res = end;
	return false;
}
