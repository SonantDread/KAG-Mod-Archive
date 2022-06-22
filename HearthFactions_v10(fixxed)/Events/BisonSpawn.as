// BisonSpawn.as; is called on gamestart or when a key building is built, which starts the event chain.
s32 bison_time = 0;

void onInit(CBlob@ this)
{
	bison_time = 0;
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 1800 == 0) //everymin 1800
    {
    	if (bison_time == 8)
    	{
    		if(isServer())
			{
				CBlob@ b = server_CreateBlob("bison");
				if (b !is null)
				{			
					CMap@ map = getMap();
					f32 mapWidth = (map.tilemapwidth * map.tilesize);	
					f32 mapHeight = (map.tilemapheight * map.tilesize);

					b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
					b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
				}
				CBlob@ b2 = server_CreateBlob("chicken");
				if (b2 !is null)
				{			
					CMap@ map = getMap();
					f32 mapWidth = (map.tilemapwidth * map.tilesize);	
					f32 mapHeight = (map.tilemapheight * map.tilesize);

					b2.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
					b2.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
				}
			}
    		bison_time = 0;
    	}
    }

    // bison_time updater/counter.
	if (getGameTime() % 1800 == 0)
    {
        bison_time += 1;
    }
}