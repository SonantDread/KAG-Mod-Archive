// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaughShort2.ogg");
	client_AddToChat("After long years asleep he woke up. You have braved many attacks, but now you meet death.", SColor(255, 0, 0, 0));
	this.server_Die();	
}