#include "Hitters.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "Explosion.as";

const f32 ARROW_PUSH_FORCE = 0.5f;
const f32 SPECIAL_HIT_SCALE = 0.5f; //special hit on food items to shoot to team-mates

//blob functions
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;	 // we have our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f; // Important  4.0
	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	this.server_SetTimeToDie(15.0);

	this.getSprite().SetEmitSound("RocketFly.ogg");
	this.getSprite().SetEmitSoundPaused(false);

	CSprite@ sprite = this.getSprite();
	{
		Animation@ anim = sprite.addAnimation("arrow", 0, false);
		anim.AddFrame(XORRandom(4));
		sprite.SetAnimation(anim);
	}
}
void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();

	f32 angle;
	bool processSticking = false;

	Vec2f initVelocity = this.getOldVelocity();
	f32 vellen = initVelocity.Length();

	//prevent leaving the map
	{
		Vec2f pos = this.getPosition();
		if (pos.x < 0.1f ||
		        pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
		{
			this.server_Die();
			return;
		}

		if (pos.y < 0.2f)
		{
			shape.SetGravityScale(0.35f * vellen);
		}
		else
		{
			shape.SetGravityScale(0.051f * vellen);
		}
	}

	if (vellen < 9.0f) //11
		this.setVelocity(this.getVelocity() * 1.075f);

	angle = (this.getVelocity()).Angle();
	Pierce(this);   //map
	this.setAngleDegrees(-angle);

	if (isClient())
	{
		ParticleAnimated("LargeSmoke", this.getPosition(), getRandomVelocity(0.0f, XORRandom(130) * 0.01f, 90), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 3 + XORRandom(2), XORRandom(70) * -0.00005f, true);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		if (!solid && !blob.hasTag("flesh") && this.getTeamNum() != blob.getTeamNum())
		{
			return;
		}

		Vec2f initVelocity = this.getOldVelocity();
		f32 vellen = initVelocity.Length();
		if (vellen < 0.1f)
			return;

		f32 dmg = 0.0f;
		if (blob.getTeamNum() != this.getTeamNum())
		{
			dmg = 1.75;
		}

		// this isnt synced cause we want instant collision for arrow even if it was wrong
		dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::arrow);

		if (dmg > 0.0f)
		{
			this.server_Hit(blob, point1, initVelocity, dmg, Hitters::arrow);
		}

		if (dmg > 0.0f)   // dont stick bomb arrows
		{
			this.Tag("collided");
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.getTeamNum() != blob.getTeamNum() && blob.hasTag("projectile"))
	{
		this.server_Die();
		return true;
	}

	bool check = this.getTeamNum() != blob.getTeamNum();
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (this.getTeamNum() == blob.getTeamNum())
	{
		return false;
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
		        this.hasTag("collided") ||
		        blob.hasTag("dead") ||
		        blob.hasTag("ignore_arrow"))
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

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		ArrowHitMap(this, end, this.getOldVelocity(), 0.25f, Hitters::arrow);
	}
}

void AddArrowLayer(CBlob@ this, CBlob@ hitBlob, CSprite@ sprite, Vec2f worldPoint, Vec2f velocity)
{
	CSpriteLayer@ arrow = sprite.addSpriteLayer("arrow", "Entities/Items/Projectiles/Arrow.png", 16, 8, this.getTeamNum(), this.getSkinNum());

	if (arrow !is null)
	{
		Animation@ anim = arrow.addAnimation("default", 13, true);

		if (this.getSprite().animation !is null)
		{
			anim.AddFrame(4 + XORRandom(4));  //always use broken frame
		}
		else
		{
			warn("exception: arrow has no anim");
			anim.AddFrame(0);
		}

		arrow.SetAnimation(anim);
		Vec2f normal = worldPoint - hitBlob.getPosition();
		f32 len = normal.Length();
		if (len > 0.0f)
			normal /= len;
		Vec2f soffset = normal * (len + 0);

		// wow, this is shit
		// movement existing makes setfacing matter?
		if (hitBlob.getMovement() is null)
		{
			// soffset.x *= -1;
			arrow.RotateBy(180.0f, Vec2f(0, 0));
			arrow.SetFacingLeft(true);
		}
		else
		{
			soffset.x *= -1;
			arrow.SetFacingLeft(false);
		}

		arrow.SetIgnoreParentFacing(true); //dont flip when parent flips

		arrow.SetOffset(soffset);
		arrow.SetRelativeZ(-0.01f);

		f32 angle = velocity.Angle();
		arrow.RotateBy(-angle - hitBlob.getAngleDegrees(), Vec2f(0, 0));
	}
}

f32 ArrowHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null)
	{
		Pierce(this, hitBlob);
		if (this.hasTag("collided")) return 0.0f;

		if (hitBlob.getShape().isStatic())
		{
			ArrowHitMap(this, worldPoint, velocity, damage, Hitters::arrow);
		}
		else
		{
			this.server_Die();
		}
	}

	if (hitBlob.isAttached())
	{
		return damage/2;
	}

	const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.05f, 360);
	CParticle@ p = ParticleAnimated("SparkParticle.png", pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), 0.0f, false);
	if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

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

	this.server_Die();

	this.set_Vec2f("fire pos", (worldPoint + (norm * 0.5f)));
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		Explode(this, 128.0f, 3.0f);
		LinearExplosion(this, this.getVelocity(), 128.0f, 64.0f, 15, 4.5f, Hitters::fall);

		this.getSprite().PlaySound("/ShellExplosion");

		if (isClient())
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();

			ParticleAnimated("BoomParticle", pos, Vec2f(0.0f, -0.1f), 0.0f, 1.0f, 3, XORRandom(70) * -0.00005f, true);
			
			for (int i = 0; i < 15; i++)
			{
				ParticleAnimated("LargeSmoke", pos + Vec2f(XORRandom(40) - 20, XORRandom(32) - 16), getRandomVelocity(0.0f, XORRandom(35) * 0.01f, 360) + Vec2f(0.0f, -0.16f), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 10 + XORRandom(10), XORRandom(70) * -0.00005f, true);
			}

			for (int i = 0; i < (4 + XORRandom(15)); i++)
			{
				makeGibParticle("GenericGibs", this.getPosition(), getRandomVelocity((this.getPosition() + Vec2f(XORRandom(24) - 12, 0.0f)).getAngle(), 1.0f + XORRandom(4), 360.0f) + Vec2f(0.0f, -5.0f),
		                2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword)
	{
		return 0.0f; //no cut arrows
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

		const f32 scale = 0.5f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > 6.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			hitBlob.AddForce(velocity * force);
		}
	}
}