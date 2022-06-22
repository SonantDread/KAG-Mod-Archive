// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilLaughShort1.ogg");
	client_AddToChat("After seeing the death of her companion, her friend will take revenge with her huge axe.", SColor(255, 0, 0, 0));
	this.server_Die();	
}