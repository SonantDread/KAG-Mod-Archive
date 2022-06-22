// Inkblot logic

#include "../Scripts/canGrow.as";

void onInit(CBlob@ this)
{
	this.set_bool("grown", true);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.Tag("builder always hit");
}

//void onDie( CBlob@ this )
//{
//	//TODO: make random item
//}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	this.SetFacingLeft(((netID % 13) % 2) == 0);
	//this.getCurrentScript().runFlags |= Script::remove_after_this;	// wont be sent on network
	this.SetZ(100.0f);
}