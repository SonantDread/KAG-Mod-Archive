#include "Hitters.as";
#include "LimitedAttacks.as";
#include "FighterVarsCommon.as"

void onInit(CBlob @ this)
{
	this.server_setTeamNum(-1);
	this.Tag("throwable");

	this.set_bool("dangerous projectile", false);
}

void onTick(CBlob@ this)
{
	bool readyToHit = this.get_bool("dangerous projectile");
	if (readyToHit)
	{
		Vec2f vel = this.getVelocity();
		f32 angle = vel.Angle();

		f32 spinSpeed = 25.0f;
		if (vel.x > 0)
		{
			this.setAngularVelocity(spinSpeed);
		}
		else
		{
			this.setAngularVelocity(-spinSpeed);
		}

		Slam(this, angle, vel, this.getShape().vellen * 1.5f);
	}
	else if (!this.isAttached() && this.getAngleDegrees() != 0.0f)	// force to stay upright while not in throw mode
	{
		this.setAngleDegrees(0);
		this.setAngularVelocity(0);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if(attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}
}

void Slam(CBlob @this, f32 angle, Vec2f vel, f32 vellen)
{
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	u8 team = this.get_u8("launch team");

	HitInfo@[] groundHitInfos;
	if (map.getHitInfosFromRay(pos, 90.0f, this.getRadius()+3.5f, null, groundHitInfos))
	{
		for (uint i = 0; i < groundHitInfos.length; i++)
		{
			HitInfo@ hi = groundHitInfos[i];

			bool hitGround = false;

			CBlob@ hitBlob = hi.blob;
			if (hitBlob !is null) // hit blob
			{
				if (hitBlob.isCollidable() && hitBlob.getShape().isStatic())
				{
					hitGround = true;
				}
			}
			else	// hit map
			{
				hitGround = true;
			}

			if (hitGround)
			{
				this.setVelocity(Vec2f(vel.x*0.2f, -4.5f));
				this.set_bool("dangerous projectile", false);

				if (getNet().isServer())
				{
					this.Sync("dangerous projectile", true);
				}

				break;	
			}
		}
	}

	HitInfo@[] damageHitInfos;
	if (map.getHitInfosFromArc(pos, -angle, 45, vellen, this, true, @damageHitInfos))
	{
		for (uint i = 0; i < damageHitInfos.length; i++)
		{
			HitInfo@ hi = damageHitInfos[i];
			f32 dmg = Maths::Min(vellen, 12.0f);

			if (hi.blob !is null) // map
			{
				if (shouldDamageBlob(this,hi.blob))
				{
					FighterHitData fighterHitData(0, 3.0f, 0.04f);
					server_fighterHit(this, hi.blob, pos, vel, dmg, Hitters::cata_boulder, true, fighterHitData);
					this.setVelocity(Vec2f(vel.x*0.3f,-7.0f));

					this.set_bool("dangerous projectile", false);
				}
			}
		}
	}

	if (vellen < 0.2f)
	{
		this.set_bool("dangerous projectile", false);
	}
}

bool shouldDamageBlob(CBlob@ this, CBlob@ blob)
{
	if(this.getTeamNum() != blob.getTeamNum())
	{
		if (blob.hasTag("player"))
			return true;
	}

	return false;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	CShape@ shape = blob.getShape();

	return blob.isCollidable() && shape.isStatic();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}
