// Crystalplace

#include "ProductionCommon.as";
#include "Requirements.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.getSprite().SetFacingLeft(XORRandom(2) == 0);

	this.SetLight(true);
	this.SetLightRadius(350.0f); //was 164.0
	this.SetLightColor(SColor(255, 26, 182, 227));

	this.Tag("fire source");
	this.Tag("builder always hit");
	//this.server_SetTimeToDie(60*3);
	this.getSprite().SetZ(-20.0f);

	this.addCommandID("extinguish");
}