
void onInit(CBlob@ this)
{
	this.set_u32("next_squeak", XORRandom(300));
}

void onTick(CBlob@ this)
{
	if((getGameTime() + this.get_u32("next_squeak")) % 400 == 1 && !this.hasTag("dead"))
	{
		Sound::Play("Squeak"+(XORRandom(4)+1)+".ogg", this.getPosition());
		this.set_u32("next_squeak", XORRandom(200));
	}
}