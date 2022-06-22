#include "MakeMat.as";
#include "Hitters.as";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (x > 0.02f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		this.PlaySound("/ScaredChicken");
	}
}

//blob

void onInit(CBlob@ this)
{
	
	this.getBrain().server_SetActive(true);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	this.set_f32("gib health", -0.0f);
	this.Tag("plant");
	
	this.getShape().SetOffset(Vec2f(0, 6));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("onewithnature"))return false;
	return (this.getTeamNum() != blob.getTeamNum() || blob.getShape().isStatic());
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft(false);
		}
	}
	
	if(this.isOnGround()){
		if(XORRandom(20) == 0){
			this.AddForce(Vec2f((XORRandom(2)*2-1)*10,-40));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!getNet().isServer())
		return damage;

	if (damage > 0.0f)
	{
		MakeMat(hitterBlob, worldPoint, "mat_wood", 5*damage);
	}
	return damage;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.hasTag("flesh") && !blob.hasTag("onewithnature"))
	{
		if(getNet().isServer()){
			blob.server_Hit(blob, this.getPosition(), this.getVelocity()*-0.5f, 0.25f, Hitters::suddengib, false);
			blob.set_s16("poison",8);
		}
	}
}