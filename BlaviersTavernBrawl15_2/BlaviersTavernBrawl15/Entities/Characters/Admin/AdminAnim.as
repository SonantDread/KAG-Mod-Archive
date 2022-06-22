#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

void onInit(CSprite@ this)
{
	const string texname = "Grandpa.png";
	this.ReloadSprite(texname);
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	blob.SetFacingLeft(blob.getAimPos().x < blob.getPosition().x);
}