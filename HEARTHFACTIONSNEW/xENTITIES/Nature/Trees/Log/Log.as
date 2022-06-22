#include "Hitters.as"

const bool dangerous_logs = false;

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(8);

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onInit(CBlob@ this)
{
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(600 + XORRandom(60));

		this.server_setTeamNum(-1);

		dictionary harvest;
		harvest.set('mat_wood', 30); //1
		this.set('harvest', harvest);
	}
}

void onDie(CBlob@ this)
{
	//if (getNet().isServer())
	//{
		//CBlob@ blob = server_CreateBlob( "mat_wood", this.getTeamNum(), this.getPosition() );
		//if (blob !is null)
		//{
		//	blob.server_SetQuantity(15); //15
		//}
	//}
}