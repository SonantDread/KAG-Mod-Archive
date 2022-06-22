// BisonSpawn.as; is called on gamestart or when a key building is built, which starts the event chain.
s32 bison_time = 0;
SColor color = SColor(255, 214, 19, 25);

void onInit(CBlob@ this)
{
	bison_time = 0;
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 1800 == 0) //everymin 1800 
    {
    	if (bison_time == 10) //10
    	{
    		if(isServer())
			{
				if (XORRandom(3) == 0)
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
				}
				if (XORRandom(3) == 0)
				{
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
				if (XORRandom(7) == 0) // about every hour lol
				{
					CBlob@ b = server_CreateBlob("beast");

					client_AddToChat("A blood crazed beast is lurking...", color);
					print("// Beast has spawned!");

					if (b !is null)
					{			
						CMap@ map = getMap();
						f32 mapWidth = (map.tilemapwidth * map.tilesize);	
						f32 mapHeight = (map.tilemapheight * map.tilesize);

						b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
						b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
					}
				}
			}
    		bison_time = 0;
    	}
    	bison_time += 1;
    }
}