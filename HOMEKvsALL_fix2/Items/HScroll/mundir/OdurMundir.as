#include "Hitters.as";

// regen hp back to
const f32 max_range = 64.00f;
const string max_prop = "regen maximum";
const string rate_prop = "regen rate";
void onInit(CBlob@ this)
{
	if (!this.exists(max_prop))
		this.set_f32(max_prop, this.getInitialHealth());

	if (!this.exists(rate_prop))
		this.set_f32(rate_prop, 0.5f);

	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	if (isServer() && this.get_bool("mundir") && getGameTime() < this.get_u32("mundir duration"))
	{
		CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (blob is null) continue;
				if (!blob.hasTag("player") && !blob.hasTag("esau_clone")) continue;
				
				if (!this.getMap().rayCastSolid(blob.getPosition(), this.getPosition()))
				{
					if (blob !is null)
					{
						blob.server_Heal(this.get_f32(rate_prop));
					}
				}
			}
		}
	}
}
	
void onTick(CSprite@ this)
{
	if ( this.getBlob().get_bool("mundir") && getGameTime() < this.getBlob().get_u32("mundir duration"))
	{
		for (int i = 0; i < 17; i++)
        {
            Vec2f offset = Vec2f(max_range, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = -offset;
            vel.Normalize();
            vel *= 0.5f;
            vel.RotateByDegrees(XORRandom(3600) * 0.1f);
			if (!getMap().rayCastSolid(this.getBlob().getPosition(), this.getBlob().getPosition() + offset))
			{
				CParticle@ p = ParticlePixel(this.getBlob().getPosition() + offset, vel, SColor(255, 252, 187, 8), true, 4);
				if (p !is null)
				{
					p.gravity = Vec2f(0,0);
					p.collides = false;
				}
			}
        }
	}
}
	

		
