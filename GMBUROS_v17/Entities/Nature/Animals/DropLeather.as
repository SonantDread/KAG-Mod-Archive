
void onDie(CBlob@ this)
{
	if (getNet().isServer() && this.getHealth() < 0.0f){

		for (uint step = 0; step < 4; ++step)
		{
			CBlob@ l = server_CreateBlob("bison_leather", -1, this.getPosition());
			if (l !is null)
			{
				l.setVelocity(Vec2f((XORRandom(16) - 8) * 0.5f, -2 - XORRandom(8) * 0.5f));
			}
		}
	}
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
