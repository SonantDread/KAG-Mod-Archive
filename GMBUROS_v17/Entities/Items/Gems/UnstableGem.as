
#include "Magic.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 240.0f;
}

void onTick(CBlob@ this)
{
    if(XORRandom(10) == 0)this.SetLightRadius(16+XORRandom(16));
	
	if(XORRandom(100) == 0){
		MagicExplosion(this.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 1.0f);
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob){
	this.doTickScripts = true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid || this.isInInventory())
	{
		return;
	}

	f32 vellen = this.getShape().vellen;

	if (vellen > 2.5f)
	{
		MagicExplosion(this.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 2.0f);
	}
}