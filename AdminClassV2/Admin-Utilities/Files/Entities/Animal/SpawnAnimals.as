#define SERVER_ONLY

const int max_piglet = 1;
const string piglet_name = "piglet";
const string birb_name = "birb";
const string bunny_name = "bunny";

void onTick(CRules@ this)
{
	if (getGameTime() % 29 != 0) return;
	if (XORRandom(2) == 0) return;

	CMap@ map = getMap();
	if (map is null || map.tilemapwidth < 2) return; //failed to load map?

	CBlob@[] piglet;
	getBlobsByName(piglet_name, @piglet);
	CBlob@[] birb;
	getBlobsByName(piglet_name, @birb);
		CBlob@[] bunny;
	getBlobsByName(piglet_name, @bunny);

	if (piglet.length < max_piglet)
	{
		if (piglet.length > 2 && XORRandom(8) < 1) //breed piglet (under 25% chance)
		{
			uint first = XORRandom(piglet.length);
			uint second = XORRandom(piglet.length);

			CBlob@ first_piglet = piglet[first];
			CBlob@ second_piglet = piglet[second];

			if (first != second && //not the same piglet
			        first_piglet.getDistanceTo(second_piglet) < 32 && //close
			        !first_piglet.hasTag("dead") && //both parents alive
			        !second_piglet.hasTag("dead"))
			{
				CBlob@ babby_piglet = server_CreateBlobNoInit(piglet_name);
				if (babby_piglet !is null)
				{
					babby_piglet.server_setTeamNum(-1);
					babby_piglet.setPosition((first_piglet.getPosition() + second_piglet.getPosition()) * 0.5f);
					babby_piglet.Init();
				}
			}
		}
		else //spawn from nowhere
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f end;

			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				Vec2f pos = Vec2f(x, y);
				TileType tile = map.getTile(Vec2f(x, y + 8)).type;
				
				if (map.isTileGroundStuff(tile) && !map.isInWater(pos)) 
				{
					server_CreateBlob(piglet_name, -1, pos);
				}
			}
		}
	}

	
	if (birb.length < max_piglet) 
	{
		if (birb.length > 2 && XORRandom(4) < 1) //breed birb (25% chance)
		{
			uint first = XORRandom(birb.length);
			uint second = XORRandom(birb.length);

			CBlob@ first_birb = birb[first];
			CBlob@ second_birb = birb[second];

			if (first != second && //not the same birb
			        first_birb.getDistanceTo(second_birb) < 32 && //close
			        !first_birb.hasTag("dead") && //both parents alive
			        !second_birb.hasTag("dead"))
			{
				CBlob@ babby_birb = server_CreateBlobNoInit(birb_name);
				if (babby_birb !is null)
				{
					babby_birb.server_setTeamNum(-1);
					babby_birb.setPosition((first_birb.getPosition() + second_birb.getPosition()) * 0.5f);
					babby_birb.Init();
				}
			}
		}
		else //spawn from nowhere
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f end;

			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				Vec2f pos = Vec2f(x, y);
				TileType tile = map.getTile(Vec2f(x, y + 8)).type;
				
				if (map.isTileGroundStuff(tile) && !map.isInWater(pos)) 
				{
					server_CreateBlob(birb_name, -1, pos);
				}
			}
		}
	}
	
	if (bunny.length < max_piglet) 
	{
		if (bunny.length > 2 && XORRandom(4) < 1) //breed bunny (25% chance)
		{
			uint first = XORRandom(bunny.length);
			uint second = XORRandom(bunny.length);

			CBlob@ first_bunny = bunny[first];
			CBlob@ second_bunny = bunny[second];

			if (first != second && //not the same birb
			        first_bunny.getDistanceTo(second_bunny) < 32 && //close
			        !first_bunny.hasTag("dead") && //both parents alive
			        !second_bunny.hasTag("dead"))
			{
				CBlob@ babby_bunny = server_CreateBlobNoInit(bunny_name);
				if (babby_bunny !is null)
				{
					babby_bunny.server_setTeamNum(-1);
					babby_bunny.setPosition((first_bunny.getPosition() + second_bunny.getPosition()) * 0.5f);
					babby_bunny.Init();
				}
			}
		}
		else //spawn from nowhere
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;

			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f end;

			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				Vec2f pos = Vec2f(x, y);
				TileType tile = map.getTile(Vec2f(x, y + 8)).type;
				
				if (map.isTileGroundStuff(tile) && !map.isInWater(pos)) 
				{
					server_CreateBlob(bunny_name, -1, pos);
				}
			}
		}
	}
}