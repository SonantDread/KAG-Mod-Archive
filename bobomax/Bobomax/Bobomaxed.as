#include "Knocked.as";
#include "RunnerCommon.as";

int red;
int green;
int blue;
const int max = 4;

void onInit(CBlob@ this)
{
	this.set_u32("bobomax start", getGameTime());
	this.set_u32("bobomax end", getGameTime() + (30 * 108));
	
	// if (this.isMyPlayer()) Sound::Play("/clown.ogg");
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	u8 level = this.get_u8("bobomaxed");
	
	u32 start = this.get_u32("bobomax start");
	u32 end = this.get_u32("bobomax end");
	
	f32 time = (f32(getGameTime() - start) / f32(end - start)) * level;
	// print("" + time);

	red * time;
	if(red > 254)
	{
		red = 0;
		print("reset red");
	}

	green * time;
	if(green > 254)
	{
		green = 0;
		print("reset green");
	}

	blue * time;
	if(blue > 254)
	{
		blue = 0;
		print("reset blue");
	}
		
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.40f + level * time * 0.5f;
		moveVars.jumpFactor *= 1.75f + level * time * 0.7f;
	}	
	
	this.getShape().SetGravityScale(0.15f + 0.25f * (1.00f - (f32(level) / f32(max))));
	
	if (this.isMyPlayer())
	{
		f32 camX = Maths::Sin(getGameTime()) * 0.01f * (level);
		f32 camY = Maths::Cos(getGameTime()) * 0.01f * (level);
		f32 camZ = Maths::Sin(getGameTime() * 0.125f) * 2 * (level);
		CCamera@ cam = getCamera();
		cam.setRotation(camX, camY, camZ);
		SetScreenFlash(255 * time, red, green, blue);
		
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("/clown.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.SetEmitSoundSpeed(0.75f + f32(level) * 0.25f);
		sprite.SetEmitSoundVolume(1.50f);
	}
	
	Vec2f vel = this.getVelocity();
	if (Maths::Abs(vel.x) > 0.1)
	{
		f32 angle = this.get_f32("angle");
		angle += vel.x * this.getRadius();
		if (angle > 360.0f)
			angle -= 360.0f;
		else if (angle < -360.0f)
			angle += 360.0f;
		this.set_f32("angle", angle);
		this.setAngleDegrees(angle);
	}
	
	if ((level > max - 1 || time >= 1) && !this.hasTag("transformed"))
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer() && !this.hasTag("transformed"))
	{
		server_CreateBlob("bobomax", this.getTeamNum(), this.getPosition());
		CBlob@ man = server_CreateBlob("klaxon", this.getTeamNum(), this.getPosition());
		this.Tag("transformed");
	}

	if (getNet().isClient() && this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
		cam.setRotation(0);
	}
	
	this.getSprite().PlaySound("klaxon0.ogg", 1.0f, 1.0f);
	this.set_u8("bobomaxed", 0);

	
	// print("die");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 1.5f) 
	{
		Sound::Play("launcher_boing" + XORRandom(2), this.getPosition(), 0.4f, 1.00f + (vellen * 0.05f));
		this.setVelocity(this.getVelocity() * 0.5f + (normal * vellen * 0.75f));
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage * 0.25f;
}