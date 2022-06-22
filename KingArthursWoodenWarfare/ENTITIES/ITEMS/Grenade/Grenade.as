#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 10;

	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (!blob.hasTag("vehicle") && blob.isCollidable());
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.hasTag("activated");
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("exploded")) return;

	f32 angle = -this.get_f32("bomb angle");

	this.set_f32("map_damage_radius", 32.0f);
	this.set_f32("map_damage_ratio", 0.10f);
	
	Explode(this, 68.0f, 5.0f);
	
	for (int i = 0; i < 8; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		LinearExplosion(this, dir, 9.0f, 28, 2, 0.10f, Hitters::explosion);
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		for (int i = 0; i < 30; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(-angle, XORRandom(125) * 0.01f, 90));
		}
		
		this.Tag("exploded");
		this.getSprite().Gib();
	}
}

void onTick(CSprite@ this)
{
	if (this.getBlob().hasTag("activated") && XORRandom(100) < 45)
	{
		sparks(this.getBlob().getPosition(), this.getBlob().getAngleDegrees(), 3.5f + (XORRandom(10) / 5.0f), SColor(255, 255, 230, 0));
	}
}

void sparks(Vec2f at, f32 angle, f32 speed, SColor color)
{
	Vec2f vel = getRandomVelocity(angle + 90.0f, speed, 25.0f);
	at.y -= 2.5f;
	ParticlePixel(at, vel, color, true, 119);
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "Explosion.png")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("activate"))
    {
        if (isServer())
        {
    		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
            if (point is null){return;}
    		CBlob@ holder = point.getOccupied();

            if (holder !is null && this !is null)
            {
                this.Tag("activated");
                this.server_SetTimeToDie(4);
            }
        }
    }
}
