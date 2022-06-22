
///Welcome to 2+ years of cancer code
///If you survive reading this, I salute you
///Parts of this straight up do nothing
///Parts probably don't even work and I'm not aware of it

#include "BasePNGLoader.as";
#include "SaveBlobs.as";
#include "CMap.as";
#include "TimeCommon.as";
#include "GetPlayerData.as";
#include "ClanCommon.as";

int minutes = 24; //48
int offSetRate = 0;//DayLength/2;
float tickrate = 30*60*minutes;

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	
	if(isServer() && getGameTime() >= map.tilemapwidth*3){
		
		int Ticker = (getGameTime()+offSetRate) % tickrate;
		int LongTicker = (getGameTime()+offSetRate) % (tickrate*3);
		
		if(Ticker == 0 || Ticker == (tickrate/4) || Ticker == (tickrate/2) || Ticker == (tickrate/4*3)){
			SavePlayerData("PlayerData.cfg");
			SaveMap(map,"MainMap.png");
			if(Ticker == 0)SaveMap(map,"backups/backup"+Time()+".png");
			SaveSpecialBlobs("SavedBlobs.cfg");
			SaveClans("SavedClans.cfg");
		}

		if(Ticker >= 0 && Ticker < map.tilemapwidth && LongTicker < map.tilemapwidth){
			int x = Ticker;
			
			if(x == 0)print("Starting Earthquake");

			bool canStart = false; //The loop goes from bottom upwards, so the 'canstart' is set to true when it can actually start pulling stuff down (so underground ruins aren't crushed)
			bool canStartNext = false;
			bool canSeeSky = false;
			int FloorY = map.tilemapheight-1;
			int EndY = 0;
			
			for(int y = FloorY;y >= 0;y--){
				if(y == FloorY){
					map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground_back);
					continue;
				}
			
				int tile = map.getTile(Vec2f(x*8,y*8-8)).type;
				
				if(!canSeeSky){
					if(!map.rayCastSolid(Vec2f(x*8,y*8-8), Vec2f(x*8,0))){
						canSeeSky = true;
						EndY = y-1;
					}
				}
				
				if(map.isTileGrass(tile)){ //Check above us for grass
					if(!map.isTileGround(map.getTile(Vec2f(x*8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8,y*8)).type)){ //If we aren't dirt
						map.server_SetTile(Vec2f(x*8,y*8-8), CMap::tile_empty); //Clear grass
						
						if(isTileMossy(map.getTile(Vec2f(x*8,y*8)).type) && y*8 <= getLandHeight(x*8))map.server_SetTile(Vec2f(x*8,y*8), tile); //If we're mossy, move the grass down
						else map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_empty); //Otherwise clear the block
					}
					continue; //move onto next block
				}
				
				if(tile == CMap::tile_empty) //If above us is open air
				if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type) || map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8)).type))continue; //If we are grass or dirt, then skip
				
				if(canSeeSky)//Checks to see if we're surface level,
				if(map.isTileGroundBack(tile))if(checkForGround(map.getTile(Vec2f(x*8,y*8)).type)){//checks if there is background block above us, and checks if we're dirt.
					map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground);
					continue;//Then it continues, which basically just leaves the dirt as is
				}  
				
				if(map.isTileGround(tile) && XORRandom(map.tilemapheight-y) <= 1)tile = CMap::tile_stone;
				else if(map.isTileStone(tile) && XORRandom(map.tilemapheight-y) <= 0)tile = CMap::tile_thickstone;
				else if(map.isTileThickStone(tile) && XORRandom((map.tilemapheight-y)*1.5f) <= 0)tile = CMap::tile_gold;
				else if(map.isTileThickStone(tile) && XORRandom((map.tilemapheight-y)*1.5f) <= 0)tile = CMap::tile_stone_hard;
				else if(map.isTileGold(tile) && XORRandom(500) == 0)tile = CMap::tile_gold_gem_weak;
				else if(tile == CMap::tile_gold_gem_weak && XORRandom(100) == 0)tile = CMap::tile_gold_gem;
				else if(tile == CMap::tile_gold_gem && XORRandom(100) == 0)tile = CMap::tile_gold_gem_strong;
				else if(tile == CMap::tile_gold_gem && XORRandom(100) == 0)tile = CMap::tile_gold_gem_unstable;
				
				if(!canStart){
					if(y == FloorY && !map.isTileBackground(map.getTile(Vec2f(x*8,y*8)))){ //If we're on the lowest block, and it's solid, then delete it by starting.
						canStart = true;
						FloorY = y;
					}
					if(map.getTile(Vec2f(x*8,y*8)).type == CMap::tile_empty){
						canStart = true;
						FloorY = y;
					}
					if(map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8)).type)){ ///This if statement basically bypasses the next two, due to water ruin shenanigans
						canStart = true;
						FloorY = y;
					}
					if(checkForGround(map.getTile(Vec2f(x*8,y*8)).type)){
						canStart = true;
						FloorY = y;
					}
					if(map.isInWater(Vec2f(x*8,y*8)) && checkForGround(tile)){
						canStart = true;
						FloorY = y;
					}
					if(y < map.tilemapheight/4*3){ ///If we're above the a point of the map, just shifteverything down, crushing the lowest block
						canStartNext = true;
						y = map.tilemapheight-2;
						FloorY = y;
					}
				}
				
				if(canStartNext){
					canStart = true;
					canStartNext = false;
				} else
				if(canStart){
					map.server_SetTile(Vec2f(x*8,y*8), tile);
					
					if(map.rayCastSolidNoBlobs(Vec2f(x*8+4,y*8),Vec2f(x*8+4,0))){
						bool water = map.isInWater(Vec2f(x*8,y*8-8));
						map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8), water);
						if(water){
							map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8-8), false);
							map.server_setFloodWaterWorldspace(Vec2f(x*8+8,y*8-8), false);
						}
					}
				}
			}
			
			if(XORRandom(100) == 0)
			for(int y = Maths::Min(FloorY,map.tilemapheight-2);y >= 0;y--)
			if(!map.rayCastSolidNoBlobs(Vec2f(x*8+4,y*8),Vec2f(x*8+4,0))){
				int tile = map.getTile(Vec2f(x*8,y*8-8)).type;

				if(x > 0)
				if(y >= float(map.tilemapheight)/3)
				if(!map.isInWater(Vec2f(x*8,y*8)))
				if(map.isTileGroundBack(map.getTile(Vec2f(x*8,y*8)).type))
				if(checkForGround(map.getTile(Vec2f(x*8,y*8+8)).type) && checkForGround(map.getTile(Vec2f(x*8-8,y*8)).type) && checkForGround(map.getTile(Vec2f(x*8+8,y*8)).type)){
					map.server_SetTile(Vec2f(x*8-8,y*8), CMap::tile_empty);
					map.server_SetTile(Vec2f(x*8+8,y*8), CMap::tile_empty);
					map.server_setFloodWaterWorldspace(Vec2f(x*8-8,y*8), true);
					map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8), true);
					map.server_setFloodWaterWorldspace(Vec2f(x*8+8,y*8), true);
					
					map.server_setFloodWaterWorldspace(Vec2f(x*8-8,y*8-8), true);
					map.server_setFloodWaterWorldspace(Vec2f(x*8,y*8-8), true);
					map.server_setFloodWaterWorldspace(Vec2f(x*8+8,y*8-8), true);
				}
			}
			
			

			CBlob@[] blobs;
			getBlobs(@blobs);
			
			for(int i = 0;i < blobs.length;i++){
				CBlob @blob = blobs[i];
				Vec2f pos = blob.getPosition();
				
				if(!blob.isAttached())
				if((pos.y >= EndY*8 || blob.hasTag("building")) && pos.y <= FloorY*8)
				if((pos.x >= x*8 && pos.x < x*8+8 && !blob.hasTag("building"))
				|| (pos.x >= x*8-8 && pos.x < x*8 && blob.hasTag("building"))){

					bool shift = true;
					
					if((map.getTile(pos).type == CMap::tile_empty && !map.isTileBackgroundNonEmpty(map.getTile(pos+Vec2f(0,8))) && !blob.hasTag("building")) || map.isTileGrass(map.getTile(pos).type))shift = false;
					
					if(blob.getName() == "spikes")
					if(!map.isTileSolid(map.getTile(pos+Vec2f(0,8)).type) && !map.isTileSolid(map.getTile(pos+Vec2f(0,-8)).type))
						shift = true;	///^ Magical code that doesn't always work for some reason ^ Or maybe it does, who can say for sure
					
					if(blob.hasTag("building")){
						if(checkForGround(map.getTile(pos+Vec2f(0,16)).type) || checkForGround(map.getTile(pos+Vec2f(8,16)).type) || checkForGround(map.getTile(pos+Vec2f(-8,16)).type))shift = false;
					} else
					if(checkForGround(map.getTile(pos+Vec2f(0,8)).type))shift = false;
					
					if(shift){
						bool killed = false;
						
						if(blob !is null){
							if(blob.getShape() !is null)if(blob.getName() == "wooden_door" || blob.getName() == "stone_door" || blob.getName() == "trap_block" || blob.getName() == "wooden_platform" || blob.getName() == "ladder"){
							
								blob.getShape().UpdateStaticBody();
								
								if(blob.getName() == "ladder")if(map.isTileGroundStuff(map.getTile(pos+Vec2f(0,8)).type))map.server_SetTile(pos+Vec2f(0,8), CMap::tile_ground_back);
								
								CBlob @new = server_CreateBlob(blob.getConfig(),blob.getTeamNum(),pos+Vec2f(0,8));
								if(new !is null){
									new.setAngleDegrees(blob.getAngleDegrees());
									new.server_SetHealth(blob.getHealth());
									new.getShape().SetStatic(true);
									blob.server_Die();
									killed = true;
								}
							
							}
						}
						
						if(!killed){
							blob.setPosition(pos+Vec2f(0,+8));
							if(pos.y >= map.tilemapheight*8-24)blob.server_Die();
						}
					}
				}
			}
			
			map.RemoveAllSectors();
		}
	
		if(Ticker >= map.tilemapwidth && Ticker < map.tilemapwidth*2){
			int x = Ticker-map.tilemapwidth;
			if(Ticker == map.tilemapwidth*1)print("Starting Mudslide");
			
			for(int y = 0;y < map.tilemapheight-6;y++){
				Vec2f pos = Vec2f(x*8+8,y*8);
				if(x % 2 == 1)pos = Vec2f(x*8-8,y*8);

				if(!map.rayCastSolid(pos, Vec2f(pos.x,0)) || map.isInWater(pos)){
					MudSlide(pos);
				}
			}
		}
		
		
		if(Ticker >= map.tilemapwidth*2 && Ticker < map.tilemapwidth*3){
			int x = Ticker-map.tilemapwidth*2;
			if(Ticker == map.tilemapwidth*2)print("Starting Waterdamage");
			
			for(int y = 0;y < map.tilemapheight/2+XORRandom(map.tilemapheight/4);y++){
				if(map.isInWater(Vec2f(x*8,y*8))){
					if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8-8,y*8)).type))map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground_back);
					
					int waterToRight = 0;
					int waterToLeft = 0;
					for(int w = 0;w < 20;w ++){
						if(x+w < map.tilemapwidth)
						if(map.isInWater(Vec2f(x*8+w*8,y*8))){
							waterToRight++;
						}
					}
					for(int w = 0;w < 20;w ++){
						if(x+w >= 0)
						if(map.isInWater(Vec2f(x*8-w*8,y*8))){
							waterToLeft++;
						}
					}
					
					if(waterToRight <= 0 || XORRandom(waterToRight) <= 2)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8-8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8-8,y*8)).type))map.server_SetTile(Vec2f(x*8-8,y*8), CMap::tile_ground_back);
					if(waterToLeft <= 0 || XORRandom(waterToLeft) <= 2)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8+8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8+8,y*8)).type))map.server_SetTile(Vec2f(x*8+8,y*8), CMap::tile_ground_back);
					if(XORRandom(6) == 0)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8+8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8,y*8+8)).type))map.server_SetTile(Vec2f(x*8,y*8+8), CMap::tile_ground_back);
				}
			}
		}
		
	}
}

void MudSlide(Vec2f tilePos){
	CMap@ map = getMap();

	bool canAcceptDirt = false;
	
	if(map.isTileBackgroundNonEmpty(map.getTile(tilePos)))canAcceptDirt = true;
	else if(map.isInWater(tilePos))canAcceptDirt = true;
	else {
		if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, 8))))
		for(uint i = 0; i < 8; i++){
			if(map.isTileGroundBack(map.getTile(tilePos+Vec2f(i*8,0)).type))canAcceptDirt = true;
			if(map.isTileGroundBack(map.getTile(tilePos-Vec2f(i*8,0)).type))canAcceptDirt = true;
		}
	}
	
	if(canAcceptDirt)
	if(!map.isTileGrass(map.getTile(tilePos).type))
	{
		if(checkForGround(map.getTile(tilePos + Vec2f(-8, 0)).type) || checkForGround(map.getTile(tilePos + Vec2f(8, 0)).type)) //Checks for any native ground tile to eiher the left or right
		for(int i = tilePos.y/8;i < map.tilemapheight;i++){
			if(map.isTileSolid(map.getTile(Vec2f(tilePos.x,i*8+8))) || CheckPosBlocked(Vec2f(tilePos.x,i*8+8))){
				if(!CheckPosBlocked(Vec2f(tilePos.x,i*8)))//|| !canReplaceWithDirt(map.getTile(Vec2f(tilePos.x,i*8)).type)
				{
					//if(!map.isInWater(Vec2f(tilePos.x,i*8-8)) || XORRandom(map.tilemapheight) < i)
					
					if(map.isTileGroundBack(map.getTile(tilePos).type))map.server_SetTile(Vec2f(tilePos.x,i*8), CMap::tile_ground);
					else map.server_SetTile(Vec2f(tilePos.x,i*8), CMap::tile_ground_back);

					break;
				}
			}
		}
		
		if(!CheckPosBlocked(tilePos))
		if(XORRandom(100) == 0) //Tiny chance for dirt growth up into dirt background
		if(map.isTileGroundBack(map.getTile(tilePos).type))
		if(checkForGround(map.getTile(tilePos + Vec2f(0, 8)).type))map.server_SetTile(tilePos, CMap::tile_ground);
		
	}

	if(tilePos.y > getLandHeight(tilePos.x)){
		if(map.getTile(tilePos).type == CMap::tile_empty && (checkForGround(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileGroundBack(map.getTile(tilePos + Vec2f(0, 8)).type))){
			map.server_SetTile(tilePos, CMap::tile_ground_back);
		}
	}
}

bool CheckPosBlocked(Vec2f middle){
	
	CMap @map = getMap();
	
	if(map.getSectorAtPosition(middle+Vec2f(4,4), "no build") !is null)return true;
	
	if(map.getBlobAtPosition(middle+Vec2f(4,4)) !is null){
		return true;
	}
	
	for(uint i = 0; i < 12; i++){ ///Tree check since their hitbox doesn't match their size
		CBlob @tree = map.getBlobAtPosition(middle+Vec2f(4,4+i*8));
		
		if(map.isTileSolid(middle+Vec2f(4,4+i*8)))break;
		
		if(tree !is null){
			if(tree.getName() == "tree_bushy" || tree.getName() == "tree_pine"){
				return true;
			}
		}
	}
	
	/*
	CBlob@[] blobsInRadius;
	if (map.getBlobsInRadius(middle, map.tilesize, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (!b.isAttached())
			{
				Vec2f bpos = b.getPosition();

				const string bname = b.getName();

				bool cantBuild = isBlocking(b);

				// cant place on any other blob
				if (cantBuild &&
					!b.hasTag("dead") &&
					!b.hasTag("material") &&
					!b.hasTag("projectile"))
				{
					f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
					bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
					f32 width = rotated ? b.getHeight() : b.getWidth();
					f32 height = rotated ? b.getWidth() : b.getHeight();
					if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
						&& (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
					{
						return true;
					}
				}
			}
		}
	}
	*/
	return false;
}

bool isBlocking(CBlob@ blob)
{
	string name = blob.getName();
	if (name == "heart" || name == "log" || name == "food" || name == "fishy" || name == "steak" || name == "grain")
		return false;

	return blob.isCollidable() || blob.getShape().isStatic();
}

bool checkForGround(int tile){
	CMap @map = getMap();
	
	if(tile >= CMap::tile_stone_hard && tile <= CMap::tile_stone_hard+23)return true;
	if(tile >= CMap::tile_gold_gem_weak && tile <= CMap::tile_gold_gem_unstable+19)return true;
	return map.isTileGround(tile) || map.isTileStone(tile) || map.isTileThickStone(tile) || map.isTileGold(tile);
}

bool canReplaceWithDirt(int tile){
	CMap @map = getMap();
	
	if(tile >= CMap::tile_castle_back && tile <= CMap::tile_castle_back+15)return false;
	if(tile >= CMap::tile_castle_back_moss && tile <= CMap::tile_castle_back_moss+4)return false;
	
	return !map.isTileSolid(tile);
}

bool isTileMossy(int tile){
	
	if(tile >= CMap::tile_castle_moss && tile <= CMap::tile_castle_moss+7)return true;
	
	return false;
}

f32 getLandHeight(f32 x){
	int h = getMap().tilemapheight;
	
	f32 variance = Maths::Sin(f32(x)/8/50)*h/8*8;
	variance += Maths::Sin(f32(x)/8/15)*h/16*8;
	variance += Maths::Sin(f32(x)/8/6)*h/32*8-h/32*8;
	
	return ((h/4+h/8)*8+variance);
}