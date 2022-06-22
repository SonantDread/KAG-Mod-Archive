#include "Hitters.as";
#include "ShieldCommon.as";
#include "LimitedAttacks.as";
#include "ParticleSparks.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.set_u8("blocks_pierced", 0);
	this.set_u8("state", 0);
	this.server_SetTimeToDie(2.5);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;
	LimitedAttack_setup(this);
	u32[] tileOffsets;
	this.set("tileOffsets", tileOffsets);
	this.Tag("projectile");

	this.getSprite().SetFrame(0);

	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallExplosion1")
{
	if (!getNet().isClient())
		return;

	const f32 rad = this.getRadius();
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition(), vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	u8 state = this.get_u8("state");
	f32 angle = 0;
	makeSteamParticle(this, Vec2f());

	if (state == 0) //we haven't hit anything yet!
	{
		this.set_f32("map_damage_radius", 4.0f);
		this.set_bool("map_damage_raycast", false);
		this.getSprite().SetFrame(1);

		angle = (this.getVelocity()).Angle();
		Pierce(this, angle);
	}
	this.setAngleDegrees(-angle+180.0f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((this.getTeamNum() != blob.getTeamNum() && !blob.hasTag("dead")) || (blob.getShape().isStatic() && !blob.getShape().getConsts().platform));
}

void Pierce(CBlob @this, f32 angle)
{
	CMap@ map = this.getMap();

	Vec2f initVelocity = this.getVelocity();
	Vec2f velDir = initVelocity;
	velDir.Normalize();

	f32 dmg = 3.0f;

	Vec2f pos = this.getPosition();
	Vec2f tailpos = pos - velDir * 12.0f;
	Vec2f tippos = pos + velDir * 12.0f;
	Vec2f midpos = pos + velDir * 6.0f;

	Vec2f[] positions = {tippos, midpos, pos, tailpos};

	for(uint i = 0; i < positions.length; i++)
	{	
		Vec2f temp = positions[i];
		TileType overtile = map.getTile(temp).type;
		if(map.isTileSolid(overtile))
		{
			BallistaHitMap(this, map.getTileOffset(temp), temp, initVelocity, dmg, Hitters::bomb);
			this.server_HitMap(temp, initVelocity, dmg, Hitters::bomb);
			break;
		}
	}

	f32 vellen = this.getShape().vellen;
	HitInfo@[] hitInfos;

	if (vellen > 0.1f)
		if (map.getHitInfosFromArc(tailpos, -angle, 10, vellen + 12.0f, this, false, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob !is null) // blob
				{
					if (!hi.blob.isCollidable() || !doesCollideWithBlob(this, hi.blob))
					{
						continue;
					}

					if (LimitedAttack_has_hit_actor(this, hi.blob))
					{
						continue;
					}

					BallistaHitBlob(this, hi.hitpos, initVelocity, dmg, hi.blob, Hitters::bomb);
					this.server_Hit(hi.blob, hi.hitpos, initVelocity, dmg, Hitters::bomb);
					LimitedAttack_add_actor(this, hi.blob);
				}
			}
		}
}

bool DoExplosion(CBlob@ this, Vec2f velocity)
{
	if(this.hasTag("dead"))
		return true;

	Explode (this, 2.0f, 2.0f);
	LinearExplosion(this, velocity, 24.0f, 4.0f, 2, 4.0f, Hitters::bomb);
	this.Tag("dead");
	this.server_Die();
	this.getSprite().Gib();
	return true;
}

void BallistaHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null)
	{
		if(DoExplosion(this, velocity))
			return;

		// check if shielded
		if (hitBlob.hasTag("flesh"))
		{
			this.getSprite().PlaySound("SparkleShort.ogg");
		}
		else
		{
			this.getSprite().PlaySound("Bomb.ogg");
		}
	}
}

void BallistaHitMap(CBlob@ this, u32 tileOffset, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if(DoExplosion(this, velocity))
		return;

	if(this.get_u8("state") == 1)
		return;

	//check if we've already hit this tile
	u32[]@ offsets;
	this.get("tileOffsets", @offsets);

	if(offsets.find(tileOffset) >= 0)
	{
		return;
	}

	CMap@ map = getMap();

	this.getSprite().PlaySound("Bomb.ogg");
	f32 angle = velocity.Angle();
	TileType t = map.getTile(tileOffset).type;

	if (t == CMap::tile_bedrock)
	{
		//die
		this.Tag("dead");
		this.server_Die();
		this.getSprite().Gib();
	}
	else if (!map.isTileGround(t))
	{
		map.server_DestroyTile(worldPoint, 1.0f, this);
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.5f);
		this.push("tileOffsets", tileOffset);
	}
}