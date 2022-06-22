#include "Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"

const f32 arrowMediumSpeed = 8.0f;
const f32 arrowFastSpeed = 13.0f;
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 ARROW_PUSH_FORCE = 6.0f;
const f32 SPECIAL_HIT_SCALE = 1.0f;

// Boomerang logic
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = true; //turn off?

	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	CSprite@ sprite = this.getSprite();
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.getTickSinceCreated() > 22)
	{
		u16 id = blob.get_u16("target");
		if (id != 0xffff && id != 0)
		{
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				if (b.isKeyPressed(key_action2))
				{
					this.SetAnimation("hyper");

					if (getGameTime() % 4 == 0)
					{
						const Vec2f pos = blob.getPosition() + getRandomVelocity(0, blob.getRadius(), 360);
							CParticle@ p = ParticleAnimated("HyperParticle.png", pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), 0.0f, false);
							if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
					}
				}
				else
				{
					this.SetAnimation("critical");
				}
			}
		}
	}
	else
	{
		this.SetAnimation("default");
	}
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);

	this.getSprite().SetZ(1000.0f);

	f32 angle;
	bool processSticking = true;

	if (this.getTickSinceCreated() > 31)
	{
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.8f);
	}

	if (this.getTickSinceCreated() > 20)
	{
		u16 id = this.get_u16("target");
		if (id != 0xffff && id != 0)
		{
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				Vec2f vel = this.getVelocity();
				Vec2f dir = b.getPosition() - this.getPosition();
				dir.Normalize();

				this.setVelocity(vel + dir * 1.2f);
				
				if (b.isKeyPressed(key_action2))
				{
					this.setVelocity(vel * 0.65f);

					// boomer jumps off rang, if not knocked
					if ((this.getDistanceTo(b) < 12.0f) && (getKnocked(b) <= 0))
					{
						this.getSprite().PlaySound("StoneFall2");
						b.AddForce(Vec2f((b.isFacingLeft() ? -1 : 1)*200.0f, -360.0f));
						SetKnocked(b, 3);
					}
				}
				else
				{
					// die when returned
					if (this.getDistanceTo(b) < 6.0f && !isKnocked(b))
					{
						Sound::Play("Getrang", this.getPosition());

						this.server_Die();
					}
				}
			}
			else
			{
				this.server_Die();
			}
		}
	}

	angle = (this.getVelocity()).Angle();
	this.setAngleDegrees(-angle);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		f32 dmg = 0.0f;

		if (!solid && !blob.hasTag("flesh") && !specialArrowHit(blob) && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
		{
			return;
		}

		Vec2f initVelocity = this.getOldVelocity();
		f32 vellen = initVelocity.Length();
		if (vellen < 0.1f)
		{
			return;
		}

		if (blob.getTeamNum() != this.getTeamNum())
		{
			if (this.getTickSinceCreated() <= 20)
			{
				dmg = 0.5f;
			}
			if (this.getTickSinceCreated() > 20)
			{
				u16 id = this.get_u16("target");
				if (id != 0xffff && id != 0)
				{
					CBlob@ b = getBlobByNetworkID(id);
					if (b !is null)
					{
						if (b.isKeyPressed(key_action2))
						{
							dmg = 2.5f;

							dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::rang);

							this.server_Hit(blob, point1, initVelocity, dmg, Hitters::hyper_rang);     // hitter the enemy
							return;
						}
						else
						{
							dmg = 1.0f;
						}
					}
				}
			}
		}

		dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::rang);

		//dmg = 1.0f;

		if (dmg > 0.0f)
		{
			//perform the hit and tag so that another doesn't happen
			this.server_Hit(blob, point1, initVelocity, dmg, Hitters::rang);     // hitter the enemy
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.4f, Hitters::crush);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//don't collide with other projectiles
	if (blob.hasTag("projectile"))
	{
		return false;
	}

	//definitely collide with non-team blobs
	bool check = this.getTeamNum() != blob.getTeamNum();
	//maybe collide with team structures
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (
			//we've collided
			this.getShape().isStatic() ||
			this.hasTag("collided") ||
			//or they're dead
			blob.hasTag("dead")
		)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}

bool specialArrowHit(CBlob@ blob)
{
	string bname = blob.getName();
	return (bname == "fishy" && blob.hasTag("dead") || bname == "food"
		|| bname == "steak" || bname == "grain"/* || bname == "heart"*/); //no egg because logic
}

void AddArrowLayer(CBlob@ this, CBlob@ hitBlob, CSprite@ sprite, Vec2f worldPoint, Vec2f velocity)
{
	CSpriteLayer@ boomerang = sprite.addSpriteLayer("arrow", "Entities/Items/Projectiles/Arrow.png", 16, 8, this.getTeamNum(), this.getSkinNum());

	if (boomerang !is null)
	{
		Animation@ anim = boomerang.addAnimation("default", 13, true);

		if (this.getSprite().animation !is null)
		{
			anim.AddFrame(4 + XORRandom(4));
		}
		else
		{
			warn("exception: boomerang has no anim");
			anim.AddFrame(0);
		}

		boomerang.SetAnimation(anim);
		Vec2f normal = worldPoint - hitBlob.getPosition();
		f32 len = normal.Length();
		if (len > 0.0f)
			normal /= len;
		Vec2f soffset = normal * (len + 0);

		if (hitBlob.getMovement() is null)
		{
			boomerang.RotateBy(180.0f, Vec2f(0, 0));
			boomerang.SetFacingLeft(true);
		}
		else
		{
			soffset.x *= -1;
			boomerang.SetFacingLeft(false);
		}

		boomerang.SetIgnoreParentFacing(true); //dont flip when parent flips

		boomerang.SetOffset(soffset);
		boomerang.SetRelativeZ(-0.01f);

		f32 angle = velocity.Angle();
		boomerang.RotateBy(-angle - hitBlob.getAngleDegrees(), Vec2f(0, 0));
	}
}

f32 ArrowHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null)
	{
		// check if invincible + special -> add force here
		if (specialArrowHit(hitBlob))
		{
			const f32 scale = SPECIAL_HIT_SCALE;
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;
			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			hitBlob.AddForce(velocity * force);

			//die
			//this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::crush);
		}
		
		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));

		// play sound
		if (hitShield)
		{
			this.getSprite().PlaySound("SwordCling");
			
			this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::crush);
			damage = 0.0f;
		}
	}

	return damage;
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	f32 radius = this.getRadius();

	f32 angle = velocity.Angle();

	this.set_u8("angle", Maths::get256DegreesFrom360(angle));

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);
	Vec2f lock = worldPoint - norm;
	this.set_Vec2f("lock", lock);

	this.Sync("lock", true);
	this.Sync("angle", true);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock);

	this.Tag("collided");
}

//random object used for gib spawning
Random _gib_r(0xa7c3a);
void onDie(CBlob@ this)
{
	u16 id = this.get_u16("target");
	if (id != 0xffff && id != 0)
	{
		CBlob@ b = getBlobByNetworkID(id);
		if (b !is null)
		{
			b.set_u8("rang_count", b.get_u8("rang_count") + 1);
		}
	}

	if (getNet().isClient())
	{
		Vec2f pos = this.getPosition();
		if (pos.x >= 1 && pos.y >= 1)
		{
			Vec2f vel = this.getVelocity();
			makeGibParticle(
				"GenericGibs.png", pos, vel,
				1, _gib_r.NextRanged(4) + 4,
				Vec2f(8, 8), 2.0f, 20, "/thud",
				this.getTeamNum()
			);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword)
	{
		return 5.0f; // Cut through the boomerang
	}

	return damage;
}
/*
void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity

		const f32 scale = specialArrowHit(hitBlob) ? SPECIAL_HIT_SCALE : 1.0f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel * 0.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;
			force *= 1.3f;

			hitBlob.AddForce(velocity * force);

			// Stun targets if critical
			if (this.getTickSinceCreated() < 20 && hitBlob.hasTag("player"))
			{
				SetKnocked(hitBlob, 28);
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			}
		}
	}
}