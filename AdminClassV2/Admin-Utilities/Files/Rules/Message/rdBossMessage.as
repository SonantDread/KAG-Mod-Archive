// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaughShort1.ogg");
	client_AddToChat("He arrived ! Prepare for the final battle !", SColor(255, 0, 0, 0));
	this.server_Die();	
}