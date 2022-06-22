u32 next_rain = 1000;
u32 next_meteor = 1000;

void onInit(CRules@ this)
{
	this.set_bool("raining", false);
	
	u32 time = getGameTime();
	next_rain = time + 2500 + XORRandom(40000);
	next_meteor = time + (30*60*(30+XORRandom(30)));
}

void onRestart(CRules@ this)
{
	this.set_bool("raining", false);

	u32 time = getGameTime();
	next_rain = time + 2500 + XORRandom(40000);
	next_meteor = time + (30*60*(30+XORRandom(30)));

	// print("Rain start: " + start_rain + "; Length: " + (end_rain - start_rain));
}

void onTick(CRules@ this)
{
	if (getNet().isServer())
	{
		u32 time = getGameTime();
		if (time >= next_rain)
		{
			u32 length = 200 + XORRandom(250);

			if (!this.get_bool("raining"))
			{
				CBlob@ rain = server_CreateBlob("rain", 255, Vec2f(0, 0));
				rain.server_SetTimeToDie(length);
			}

			next_rain = time + length + 20000 + XORRandom(100000);
		}
		/*
		if (time >= next_meteor)
		{
			server_CreateBlob("meteor", 255, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, 0.0f));
			next_meteor = time + (30*60*(30+XORRandom(30)));
		}*/
	}
}
