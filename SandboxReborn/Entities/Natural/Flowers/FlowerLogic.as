// Flowers logic

#include "PlantGrowthCommon.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0); //random facing
	this.getSprite().ReloadSprites(uint(XORRandom(8)), 0); //random colour

	this.getCurrentScript().tickFrequency = 15;
	this.getSprite().SetZ(10.0f);

	this.set_u8(growth_chance, default_growth_chance);
	this.set_u8(growth_time, default_growth_time);
}


void onTick(CBlob@ this)
{
	bool grown = this.hasTag(grown_tag);
	if (grown)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}
