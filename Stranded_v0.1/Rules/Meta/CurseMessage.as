// Message

void onInit(CBlob@ this)
{
	Sound::Play("/survive.ogg");
	client_AddToChat("A player random has been cursed.  Hardmode can get harder?", SColor(255, 255, 0, 0));
	this.server_Die();	
}