// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaughShort1.ogg");
	client_AddToChat("You hear a very heavy bark in the distance. The death of the two entities creates a rage in the fauna..", SColor(255, 0, 0, 0));
	this.server_Die();	
}