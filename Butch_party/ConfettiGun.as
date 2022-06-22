#include "Hitters.as";
#include "ConfettiCommon.as";

void onInit(CBlob@ this)
{
	
}

void onTick(CBlob@ this)
{
	if(this.hasTag("thrown")){ 
		this.Untag("thrown");
		shootConfetti(this);
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint ){
	this.Tag("thrown");
	this.Untag("attached");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ){ this.Tag("attached");}

void onCollision( CBlob@ this, CBlob@ blob, bool solid ){
	if(!this.hasTag("attached") && this.getVelocity().getLength() > 1){
		shootConfetti(this,100);
	}
}
