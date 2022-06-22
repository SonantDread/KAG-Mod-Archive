// Message

void onInit(CBlob@ this)
{
	client_AddToChat("The Horrors are coming...", SColor(255, 255, 0, 0));
	this.server_Die();	
}