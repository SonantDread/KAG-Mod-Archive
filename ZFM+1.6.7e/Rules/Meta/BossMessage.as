// Message

void onInit(CBlob@ this)
{
	Sound::Play("/Roundabout.ogg");
	client_AddToChat("An ancient curse is lifted and the Abomination rises with it...", SColor(255, 255, 0, 0));
	this.server_Die();	
}