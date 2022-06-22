#include "Hitters.as";
#include "TeamStructureNear.as";
#include "Knocked.as"

//blob functions
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f; // Important  4.0
	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	this.server_SetTimeToDie(5.0);

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
	bool processSticking = true;
	if (!this.hasTag("collided"))
	{
		{
			Vec2f pos = this.getPosition();
			if (pos.x < 0.1f ||
			        pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
			{
				this.server_Die();
				return;
			}
		}

		angle = (this.getVelocity()).Angle();
		Pierce(this);   //map
		this.setAngleDegrees(-angle);

		if (shape.vellen > 0.0001f)
		{
			if (shape.vellen > 13.5f)
				shape.SetGravityScale(0.1f);
			else
				shape.SetGravityScale(Maths::Min(1.0f, 1.0f / (shape.vellen * 0.1f)));

			processSticking = false;
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		if (blob.getName() == "m60" && blob.getTeamNum() != this.getTeamNum() && !this.hasTag("rico"))
		{
			this.Tag("dead");

			this.Tag("rico");

			this.getSprite().PlaySound("/BulletMetal" + XORRandom(4));

			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;

			ParticlePixel(this.getPosition(), velr, SColor(255, 255, 255, 0), true);
			this.server_SetTimeToDie(0.35);

			return;
		}

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
			dmg = 4.25;

			if (blob.hasTag("vehicle"))
			{
				this.getSprite().PlaySound("/BulletHitVehicle");
			}
		}

		dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::arrow);

		if (dmg > 0.0f)
		{
			this.server_Hit(blob, point1, initVelocity, dmg, Hitters::arrow);
		}

		if (dmg > 0.0f)
		{
			this.Tag("collided");
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("projectile"))
	{
		return false;
	}

	if (blob.hasTag("door") && this.getTickSinceCreated() < 2)
	{
		return false;
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

		// play sound
		if (hitBlob.hasTag("flesh"))
		{
			if (isClient())
			{
				this.getSprite().PlaySound("ShellBounce.ogg");
			}
		}

		// play sound
		if (hitBlob.getName() == "shootingtarget")
		{
			if (isClient())
			{
				this.getSprite().PlaySound("ShellBounce.ogg");
			}
		}

		if (hitBlob.getShape().isStatic())
		{
			ArrowHitMap(this, worldPoint, velocity, damage, Hitters::arrow);
		}
		else
		{
			this.server_Die();
		}
	}

	if (hitBlob.get_string("equipment_head") == "helmet" || hitBlob.get_string("equipment_head") == "goldenhelmet")
	{
		damage*=0.90;

		if (XORRandom(100) < 10)
		{
			if (isClient())
			{
				this.Tag("dead");

				this.Tag("rico");

				this.getSprite().PlaySound("/BulletMetal" + XORRandom(4));

				Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
				velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;

				ParticlePixel(this.getPosition(), velr, SColor(255, 255, 255, 0), true);
				this.server_SetTimeToDie(0.35);
			}

			damage = 0;
			return damage;
		}
	}

	CPlayer@ player = this.getDamageOwnerPlayer();

	if (player.getBlob() !is null && this.getDistanceTo(player.getBlob()) < 175.0f)
	{
		if (player.hasTag("Commando"))
		{
			damage*=1.35;
		}
	}

	if (hitBlob.isAttached())
	{
		return damage/1.5;
	}

	const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.05f, 360);
	CParticle@ p = ParticleAnimated("SparkParticle.png", pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), 0.0f, false);
	if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

	return damage;
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	this.getSprite().PlaySound("/BulletDirt" + XORRandom(3));

	this.Tag("collided");

	this.server_Die();
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.05f, 360);
				CParticle@ p = ParticleAnimated("SparkParticle.png", pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), 0.0f, false);
				if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

			ParticleAnimated("BoomParticle", this.getPosition(), Vec2f(0.0f, -0.1f), 0.0f, 0.5f, 3, XORRandom(70) * -0.00005f, true);
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

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (this !is hitBlob)
	{
		const f32 scale = 0.5f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > 6.5f)
		{
			f32 force = 0.07f * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			hitBlob.AddForce(velocity * force);
		}
	}
}