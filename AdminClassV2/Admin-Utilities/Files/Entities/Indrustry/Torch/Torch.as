// Torch

#include "MechanismsCommon.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$torch on$", "Torch.png", Vec2f(13, 8), 0);
	AddIconToken("$torch off$", "Torch.png", Vec2f(13, 8), 3);
	
	// used by BuilderHittable.as
	this.Tag("builder always hit");
	
	// used by BlobPlacement.as
	this.Tag("place ignore facing");

	// used by KnightLogic.as
	this.Tag("ignore sword");

	// used by TileBackground.as
	//this.set_TileType("background tile", CMap::tile_wood_back);

	// background, let water overlap
	this.getShape().getConsts().waterPasses = true;
	
	this.Tag("dont deactivate");
	this.Tag("fire source");	
	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic();
}
