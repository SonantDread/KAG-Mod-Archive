#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("fog");

	this.getShape().SetGravityScale(0.10f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 30 + XORRandom(15);
	
	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.50f);
	
	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());
	this.server_SetTimeToDie(45 + XORRandom(60));
}

void onTick(CBlob@ this)
{
	if (getNet().isServer() && this.getPosition().y < 0) this.server_Die();
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ blob = blobsInRadius[i];
			if (blob.hasTag("flesh") && !blob.hasTag("gas immune") && !blob.hasTag("mob"))
			{
				blob.set_u8("evilfog value", Maths::Clamp(blob.get_u8("evilfog value") + 1, 0, 64));
			
				if (getNet().isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.225f, Hitters::burn);
			
				if (!blob.hasTag("evilfogged"))
				{
					blob.set_u32("evilfog time", getGameTime());
					blob.AddScript("EvilFogEffect.as");
					blob.getSprite().AddScript("EvilFogEffect.as");
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("fog");
}
 
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}
 
// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null) return;
	// if (blob.hasTag("gas")) return;
// }