// Torch

#include "MechanismsCommon.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 26, 182, 227));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$bluetorch on$", "Bluetorch.png", Vec2f(13, 8), 2);
	AddIconToken("$bluetorch off$", "Bluetorch.png", Vec2f(13, 8), 1);
	
	this.addCommandID("toggle");

	AddIconToken("$lever_0$", "Lever.png", Vec2f(13, 8), 2);
	AddIconToken("$lever_1$", "Lever.png", Vec2f(13, 8), 1);

	// used by BuilderHittable.as
	this.Tag("builder always hit");
	
	// used by BlobPlacement.as
	this.Tag("place ignore facing");

	// used by KnightLogic.as
	this.Tag("ignore sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);

	// background, let water overlap
	this.getShape().getConsts().waterPasses = true;
}