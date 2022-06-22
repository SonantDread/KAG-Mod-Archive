
#define SERVER_ONLY;

int MinutesToDie = 5*30;

void onInit(CBlob@ this)
{
	this.set_u32("time_expire_created",getGameTime());
	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
	if(this.get_u32("time_expire_created")+(MinutesToDie*60*30) < getGameTime()){
		this.server_Die();
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.set_u32("time_expire_created",getGameTime());
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.set_u32("time_expire_created",getGameTime());
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.set_u32("time_expire_created",getGameTime());
}