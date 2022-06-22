// Message

void onInit(CBlob@ this)
{
	Sound::Play("/EvilNotice.ogg");
	client_AddToChat("This night won't be fun, get ready.", SColor(255, 0, 0, 0));
	this.server_Die();
}