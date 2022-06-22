

#include "Hitters.as";
#include "MakeMat.as";
#include "ParticleSparks.as";
 
const u16 Reborn = 100 * 30;
const f32 YIELD_PROBABILITY = 0.50f;

void onInit( CSprite@ sprite )
{
    sprite.SetZ(-50);
    sprite.SetFacingLeft(((sprite.getBlob().getNetworkID() % 13) % 2) == 0);
}



void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	shape.SetStatic(true);
	shape.SetGravityScale(0.0f);
	
	this.set_u32("depleteRespawnTime", 0);
	
	this.getCurrentScript().tickFrequency = 33;
}

void onTick( CBlob@ this )
{
    if(getNet().isServer())
	{
	    const u32 time = getGameTime();
		const u32 depleteRespawnTime = this.get_u32("Time");
        const bool depleted = this.getHealth() <= 1.0f;
	    
		if(depleted)
		{
	        if(depleteRespawnTime == 0)
			{
	            this.set_u32("Time", getGameTime() + Reborn);
			}
	        else if(time >= depleteRespawnTime)
			{
	            this.server_SetHealth(this.getInitialHealth());
				this.set_u32("depleteRespawnTime", 0);
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(damage <= 0.0f) return damage;
	if(this.getHealth() <= 1.0f || customData != Hitters::builder)
	{
	    if(getNet().isClient())
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			sparks(worldPoint, velocity.Angle(), damage);
		}
	    return 0.0f;
	}
	else if(getNet().isServer() && XORRandom(10) / 10.0f > 0.4f)
	{
		    MakeMat(hitterBlob, worldPoint, "bf_cobalt", 2);
	}
    return damage;
}


