
#include "EquipmentCommon.as"

void onInit(CBlob@ this)
{
	this.getSprite().animation.frame = XORRandom(4);
	this.server_setTeamNum(-1);
	
	this.server_SetTimeToDie(60);
	
	dictionary harvest;
	harvest.set('mat_wood', 5);
	this.set('harvest', harvest);
}