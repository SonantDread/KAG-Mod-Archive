// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaugh.ogg");
	client_AddToChat("This time you won't survive it.", SColor(255, 0, 0, 0));
	this.server_Die();	
}