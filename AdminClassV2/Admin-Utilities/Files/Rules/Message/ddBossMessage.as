// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaughShort2.ogg");
	client_AddToChat("They approaches, you hear the cries of many villagers in the distance", SColor(255, 0, 0, 0));
	this.server_Die();	
}