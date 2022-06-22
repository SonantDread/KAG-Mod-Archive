#include "CreatureDeath.as";

void dropZombies(CBlob@ this)
{
	if (!getNet().isServer())
		return;
	
	if (!this.hasTag("dropped zombies")) //double check
	{
		int r = XORRandom(3);

		this.Tag("dropped zombies");
		if (r==0)
		{
			server_CreateBlob("bloodzombie", -1, this.getPosition());
			server_CreateBlob("zombie", -1, this.getPosition());
			server_CreateBlob("plantzombie", -1, this.getPosition());
		}
		else if (r==1)
		{
			server_CreateBlob("crawler", -1, this.getPosition());
			server_CreateBlob("crawler", -1, this.getPosition());
			server_CreateBlob("crawler", -1, this.getPosition());
		}
		else if (r==2)
		{
			server_CreateBlob("zombie2", -1, this.getPosition());
			server_CreateBlob("zombie2", -1, this.getPosition());
			server_CreateBlob("zombie2", -1, this.getPosition());
		}
		else if (r==3)
		{
			server_CreateBlob("zombie", -1, this.getPosition());
			server_CreateBlob("zombieknight", -1, this.getPosition());
			server_CreateBlob("zombie2", -1, this.getPosition());
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.get_u32( "death time" ) + VANISH_BODY_SECS * getTicksASecond() > getGameTime() ) //we want hands dropping only if the body is killed, not when it revives naturally
	{
		dropZombies(this);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}
