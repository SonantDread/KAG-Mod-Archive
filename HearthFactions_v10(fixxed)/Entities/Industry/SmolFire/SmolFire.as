#include "Hitters.as";
void onInit(CBlob@ this)
{
	//Light
	this.SetLight(true);
	this.SetLightRadius(80.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 70 == 0)
    {
    	Vec2f pos = this.getPosition();
		this.server_Hit(this, pos, Vec2f(0, 0), 0.25f, Hitters::builder, true); // hurt fire
    }
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	bool isServer = getNet().isServer();
	
	if (blob !is null)
	{
		if (blob.getName() == "log")
		{
			blob.server_Die();
			if (isServer)
			{
				this.server_Heal(4.0f);
			}
		}
		if (blob.getName() == "rawmeat")
		{
			blob.server_Die();
			server_CreateBlob("cookedmeat",-1,this.getPosition());
		}
		if (blob.getName() == "corn")
		{
			blob.server_Die();
			server_CreateBlob("cornonthecob",-1,this.getPosition());
		}
		if (blob.getName() == "egg")
		{
			blob.server_Die();
			server_CreateBlob("cookedegg",-1,this.getPosition());
		}
		if (blob.getName() == "fishy")
		{
			blob.server_Die();
			server_CreateBlob("cookedfish",-1,this.getPosition());
		}
		if (blob.getName() == "carrot")
		{
			blob.server_Die();
			server_CreateBlob("roastedcarrot",-1,this.getPosition());
		}
	}
}