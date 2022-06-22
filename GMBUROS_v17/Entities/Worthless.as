
#define SERVER_ONLY;

int TimeToDie = 5*30;

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(TimeToDie);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.server_SetTimeToDie(TimeToDie);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.server_SetTimeToDie(TimeToDie);
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.server_SetTimeToDie(TimeToDie);
}