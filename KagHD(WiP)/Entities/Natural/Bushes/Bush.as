// Bush logic

#include "../Scripts/canGrow.as";

void onInit( CBlob@ this )
{
    this.set_bool("grown", true);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

//void onDie( CBlob@ this )
//{
//	//TODO: make random item
//}


//sprite

void onInit( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
    this.animation.frame = (netID % this.animation.getFramesCount());
    this.SetFacingLeft( ((netID % 13) % 2) == 0 );
	//this.getCurrentScript().runFlags |= Script::remove_after_this;	// wont be sent on network
	this.SetZ(10.0f);
}

