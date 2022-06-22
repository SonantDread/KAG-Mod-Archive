// Paper script

#include "FireParticle.as"

void onInit(CBlob@ this)
{
	this.Tag("ignore_arrow");

	// minimap stuff
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
}

void onTick(CBlob@ this)
{
	if (XORRandom(2) == 0)
	{
		makeSmokeParticle(this.getPosition(), -0.05f);

		this.getSprite().SetEmitSoundPaused(false);
	}
}