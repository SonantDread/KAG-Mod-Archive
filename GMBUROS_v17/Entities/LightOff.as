
#define CLIENT_ONLY;

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.SetLight(false);
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.SetLight(true);
}
