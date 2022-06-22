#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint ){
	this.Untag("attached");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint ){ this.Tag("attached");}