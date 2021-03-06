#include "MakeMat.as";
#include "Hitters.as"
#include "ParticleSparks.as";

void onInit(CSprite@ this)
{
	this.SetZ(10);
	
	this.SetEmitSound("Grinder_Loop.ogg");
	this.SetEmitSoundVolume(0.3f);
	this.SetEmitSoundSpeed(0.9f);
	this.SetEmitSoundPaused(false);
	
	CSpriteLayer@ chop_left = this.addSpriteLayer("chop_left", "/Saw.png", 16, 16);

	if (chop_left !is null)
	{
		Animation@ anim = chop_left.addAnimation("default", 0, false);
		anim.AddFrame(3);
		anim.AddFrame(7);
		chop_left.SetAnimation(anim);
		chop_left.SetRelativeZ(-1.0f);
		chop_left.SetOffset(Vec2f(5.0f, -1.0f));
	}
	
	CSpriteLayer@ chop_right = this.addSpriteLayer("chop_right", "/Saw.png", 16, 16);

	if (chop_right !is null)
	{
		Animation@ anim = chop_right.addAnimation("default", 0, false);
		anim.AddFrame(3);
		anim.AddFrame(7);
		chop_right.SetAnimation(anim);
		chop_right.SetRelativeZ(-1.0f);
		chop_right.SetOffset(Vec2f(-5.0f, -2.0f));
	}
}
void onInit(CBlob@ this)
{	
	this.Tag("builder always hit");
	
	this.getShape().SetOffset(Vec2f(0, 4));
		
	{
		Vec2f offset(-24, 8);
	
		Vec2f[] shape = 
		{ 
			Vec2f(0.0f, 0.0f) - offset,
			Vec2f(8.0f, 0.0f) - offset,
			Vec2f(8.0f, 24.0f) - offset,
			Vec2f(0.0f, 24.0f) - offset
		};
		this.getShape().AddShape(shape);
	}
	
	{
		Vec2f offset(8, 8);
	
		Vec2f[] shape = 
		{ 
			Vec2f(0.0f, 0.0f) - offset,
			Vec2f(8.0f, 0.0f) - offset,
			Vec2f(8.0f, 24.0f) - offset,
			Vec2f(0.0f, 24.0f) - offset
		};
		this.getShape().AddShape(shape);
	}
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() > 30)
	{
		ShapeConsts@ consts = this.getShape().getConsts();
		consts.collidable = true;
	}


	
	// this.getCurrentScript().tickFrequency = 1;
	
	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(-8, -3), this.getPosition() + Vec2f(8, 3), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (blob !is null)
			{
				if (canSaw(this, blob))
				{
					Blend(this, blob);
					if (getNet().isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, -2), 2.00f, Hitters::saw, true);
				}
				else if (blob.hasTag("material") ? !this.server_PutInInventory(blob) : true)
				{
					blob.setVelocity(Vec2f(4 - XORRandom(8), -4));
				}
			}
		}
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ chop_left = this.getSpriteLayer("chop_left");
	CSpriteLayer@ chop_right = this.getSpriteLayer("chop_right");

	if (chop_left !is null) chop_left.RotateBy(10.0f, Vec2f(0.5f, -0.5f));
	if (chop_right !is null) chop_right.RotateBy(-10.0f, Vec2f(0.5f, -0.5f));
}

bool canSaw(CBlob@ this, CBlob@ blob)
{
	if (this.getTickSinceCreated() < 90 || blob.hasTag("sawed") || blob.getShape().isStatic() || (blob.getConfig() == "mat_stone" ? false : blob.hasTag("invincible"))) return false;

	if (blob.hasTag("flesh") && getNet().isClient() && !g_kidssafe)
	{
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ chop_left = sprite.getSpriteLayer("chop_left");
		CSpriteLayer@ chop_right = sprite.getSpriteLayer("chop_right");

		if (chop_left !is null) chop_left.animation.frame = 1;
		if (chop_right !is null) chop_right.animation.frame = 1;
		
		sprite.SetAnimation("blood");
	}
	
	return true;
}

void Blend(CBlob@ this, CBlob@ blob)
{
	if (this is blob || blob.hasTag("sawed")) return;

	bool kill = false;
	const string name = blob.getName();
	
	if (name == "log")
	{	
		if (getNet().isServer())
		{
			MakeMat(this, this.getPosition(), "mat_wood", 60 + XORRandom(40));
		}
		
		this.getSprite().PlaySound("SawLog.ogg", 0.8f, 0.9f);
		kill = true;
	}
	else if (name == "mat_stone")
	{
		if (getNet().isServer())
		{
			u32 quantity = blob.getQuantity();
		
			MakeMat(this, this.getPosition(), "mat_stone", 		quantity * 0.50f + XORRandom(quantity * 0.25f));
			MakeMat(this, this.getPosition(), "mat_concrete", 	quantity * 0.125f + XORRandom(quantity * 0.125f));
			MakeMat(this, this.getPosition(), "mat_iron", 		XORRandom(quantity * 0.20f));
			MakeMat(this, this.getPosition(), "mat_sulphur", 	XORRandom(quantity * 0.15f));
			MakeMat(this, this.getPosition(), "mat_copper", 	XORRandom(quantity * 0.12f));
			MakeMat(this, this.getPosition(), "mat_gold",	 	XORRandom(quantity * 0.08f));
			MakeMat(this, this.getPosition(), "mat_mithril", 	XORRandom(quantity * 0.05f));
		}
		
		this.getSprite().PlaySound("rocks_explode" + (1 + XORRandom(2)) + ".ogg", 1.5f, 1.0f);
		kill = true;
		
		if (XORRandom(100) < 75) 
		{
			ParticleAnimated(CFileMatcher("Smoke.png").getFirst(), this.getPosition() + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
		}
	}
	else if (blob.hasTag("flesh"))
	{
		if (getNet().isServer())
		{
			f32 amount = ((blob.getRadius() + XORRandom(blob.getMass() / 3.0f)) / blob.getInitialHealth()) * 0.35f;
			amount += XORRandom(amount) * 0.50f;
			
			// print("" + amount);
			
			blob.setVelocity(Vec2f(1 - XORRandom(2), -0.25f));
			
			MakeMat(this, this.getPosition(), "mat_meat", amount);
		}
	}
	else if (blob.getConfig() == "steak")
	{
		if (getNet().isServer())
		{
			MakeMat(this, this.getPosition(), "mat_meat", 20 + XORRandom(10));
		}
		
		this.getSprite().PlaySound("SawLog.ogg", 0.8f, 1.0f);
		kill = true;
	}
	else if (blob.hasTag("isWeapon"))
	{
		if (getNet().isServer())
		{
			MakeMat(this, this.getPosition(), "mat_iron", 20 + XORRandom(60));
			MakeMat(this, this.getPosition(), "mat_wood", 10 + XORRandom(40));
			
			kill = true;
		}
	}
	else if (name == "scythergib")
	{
		if (getNet().isServer())
		{
			MakeMat(this, this.getPosition(), "mat_plasteel", 5 + XORRandom(20));
			MakeMat(this, this.getPosition(), "mat_steelingot", 1 + XORRandom(3));
			
			kill = true;
		}
	}
	else
	{
		this.getSprite().PlaySound("ShieldHit.ogg");
		sparks(blob.getPosition(), 1, 1);
		blob.setVelocity(Vec2f(4 - XORRandom(8), -5));
	}
	
	if (kill)
	{
		blob.Tag("sawed");
	
		CSprite@ s = blob.getSprite();
		if (s !is null)
		{
			s.Gib();
		}
	
		blob.server_SetHealth(-1.0f);
		blob.server_Die();
	}
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null) return;

	// Vec2f pos = this.getPosition();
	// Vec2f bpos = blob.getPosition();

	// if ((bpos.x > pos.x + 9) || (bpos.x < pos.x - 9) || bpos.y > pos.y) return;
	
	// if (canSaw(this, blob))
	// {
		// Blend(this, blob);
		// this.server_Hit(blob, bpos, Vec2f(0, -2), 2.00f, Hitters::saw, true);
	// }
	// else if (blob.hasTag("material") ? !this.server_PutInInventory(blob) : true)
	// {
		// blob.setVelocity(Vec2f(4 - XORRandom(8), -4));
	// }
// }

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
	return true;
}