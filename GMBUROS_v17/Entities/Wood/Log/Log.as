#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onInit(CBlob@ this)
{
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(60);

		this.server_setTeamNum(-1);

		dictionary harvest;
		harvest.set('mat_wood', 10);
		this.set('harvest', harvest);
	}

	this.Tag("pushedByDoor");
}