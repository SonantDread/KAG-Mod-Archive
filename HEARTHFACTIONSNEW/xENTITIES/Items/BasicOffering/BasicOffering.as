// Basic Offering script

#include "FireParticle.as"

void onInit(CBlob@ this)
{
	this.Tag("ignore_arrow");
	this.Tag("offerable");

	// minimap stuff
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);

	this.getCurrentScript().tickFrequency = 20;
}

void onTick(CBlob@ this)
{
	if (XORRandom(10) == 0)
	{
		makeSmokeParticle(this.getPosition(), -0.06f);
	}
}