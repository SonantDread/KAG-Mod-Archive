
///Welcome to 2+ years of cancer code
///If you survive reading this, I salute you
///Parts of this straight up do nothing
///Parts probably don't even work and I'm not aware of it

#include "BasePNGLoader.as";
#include "SaveMap.as";

float tickrate = 30*60*15;

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	
	if(isServer() && getGameTime() >= map.tilemapwidth*2){
		
		int x = getGameTime() % tickrate;

		if(x < map.tilemapwidth){
		
			if(x == 0)SaveMap(map,"MainMap.png");
			
			if(x == 1)SaveMap(map,"backups/backup"+Time()+".png");
			
			//if(x == 2)SaveSpecialBlobs("Blobs.cfg");

			bool canStart = false;
			int FloorY = map.tilemapheight-2;
			
			for(int y = FloorY;y >= 0;y--){
				int tile = map.getTile(Vec2f(x*8,y*8-8)).type;
				
				if(tile == CMap::tile_empty)if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type) || map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8)).type))continue;
				if(map.isTileGroundBack(tile))if(map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8)).type))continue;
				
				if(!map.isTileGrass(tile)){
					if(map.isTileGround(tile) && XORRandom(map.tilemapheight-y) <= 1)tile = CMap::tile_stone;
					else if(map.isTileStone(tile) && XORRandom(map.tilemapheight-y) <= 0)tile = CMap::tile_thickstone;
					else if(map.isTileThickStone(tile) && XORRandom((map.tilemapheight-y)*2) <= 0)tile = CMap::tile_gold;
					
					if(!canStart){
						if(checkForGround(map.getTile(Vec2f(x*8,y*8)).type) && y <= map.tilemapheight-3){
							canStart = true;
						}
						if(map.isInWater(Vec2f(x*8,y*8)) && checkForGround(tile) && y <= map.tilemapheight-3){
							canStart = true;
						}
					}
					if(canStart){ //Do not 'else' this, it needs to be able to happen after the above check
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
				} else {
					if(!map.isTileGround(map.getTile(Vec2f(x*8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8,y*8)).type))
						map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_empty);
					else
						map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground);
				}
			}
			
			if(XORRandom(100) == 0)
			for(int y = FloorY;y >= 0;y--)
			if(!map.rayCastSolidNoBlobs(Vec2f(x*8+4,y*8),Vec2f(x*8+4,0))){
				int tile = map.getTile(Vec2f(x*8,y*8-8)).type;

				if(x > 0)
				if(y >= float(map.tilemapheight)/4)
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
				if(pos.y >= 8)
				if(pos.x >= x*8 && pos.x < x*8+8){

					bool shift = true;
					
					if((map.getTile(pos).type == CMap::tile_empty && !map.isTileBackgroundNonEmpty(map.getTile(pos+Vec2f(0,8)))) || map.isTileGrass(map.getTile(pos).type))shift = false;
					
					if(blob.getName() == "spikes")
					if(!map.isTileSolid(map.getTile(pos+Vec2f(0,8)).type) && !map.isTileSolid(map.getTile(pos+Vec2f(0,-8)).type))
						shift = true;	///^ Magical code that doesn't always work for some reason ^ Or maybe it does, who can say for sure
						
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
		
		
		if(getGameTime() >= map.tilemapwidth){
			x = (getGameTime()-map.tilemapwidth+3) % tickrate;
		
			if(x < map.tilemapwidth){
				for(int y = 0;y < map.tilemapheight/2+XORRandom(map.tilemapheight/4);y++){
					if(map.isInWater(Vec2f(x*8,y*8))){
						if(map.isTileGrass(map.getTile(Vec2f(x*8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8-8,y*8)).type))map.server_SetTile(Vec2f(x*8,y*8), CMap::tile_ground_back);
						if(XORRandom(2) == 0)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8-8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8-8,y*8)).type))map.server_SetTile(Vec2f(x*8-8,y*8), CMap::tile_ground_back);
						if(XORRandom(2) == 0)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8+8,y*8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8+8,y*8)).type))map.server_SetTile(Vec2f(x*8+8,y*8), CMap::tile_ground_back);
						if(XORRandom(6) == 0)if(map.isTileGroundStuff(map.getTile(Vec2f(x*8,y*8+8)).type) && !map.isTileGroundBack(map.getTile(Vec2f(x*8,y*8+8)).type))map.server_SetTile(Vec2f(x*8,y*8+8), CMap::tile_ground_back);
					}
				}
			}
			
			x = (getGameTime()-map.tilemapwidth) % tickrate;
		
			if(x < map.tilemapwidth){
				for(int y = 0;y < map.tilemapheight-6;y++){
					if(!map.isInWater(Vec2f(x*8,y*8))){
						if(x % 2 == 0)MudSlide(x*8+8,y*8);
						else MudSlide(x*8-8,y*8);
					}
				}
			}
		}
		
	}
}

void MudSlide(int x, int y){
	CMap@ map = getMap();

	Vec2f tilePos = Vec2f(x,y);
	
	bool canAcceptDirt = false;
	
	if(map.isTileBackgroundNonEmpty(map.getTile(tilePos)))canAcceptDirt = true;
	else {
		if(map.isTileSolid(map.getTile(tilePos + Vec2f(0, 8))))
		for(uint i = 0; i < 8; i++){
			if(map.isTileGroundBack(map.getTile(tilePos+Vec2f(i*8,0)).type))canAcceptDirt = true;
			if(map.isTileGroundBack(map.getTile(tilePos-Vec2f(i*8,0)).type))canAcceptDirt = true;
		}
	}
	
	if(map.getSectorAtPosition(tilePos, "no build") is null)
	if(canAcceptDirt)
	if(!CheckPosBlocked(tilePos))
	if(!map.isTileGrass(map.getTile(tilePos).type))
	{
	
		bool skip = true;
	
		if(checkForGround(map.getTile(tilePos + Vec2f(-8, 0)).type) || checkForGround(map.getTile(tilePos + Vec2f(8, 0)).type)) //Checks for any native ground tile to eiher the left or right
		for(int i = tilePos.y/8;i < map.tilemapheight;i++){
			if(CheckPosBlocked(Vec2f(x,i*8)) || map.isTileSolid(Vec2f(x,i*8)))
			{
				if(!skip){
					if(map.getTile(Vec2f(x,i*8-8)).type == CMap::tile_empty)map.server_SetTile(Vec2f(x,i*8-8), CMap::tile_ground_back); //Set to ground obviously
					else {
						if(!map.isInWater(Vec2f(x,i*8-8)) || XORRandom(5) == 0)
						map.server_SetTile(Vec2f(x,i*8-8), CMap::tile_ground); //Set to ground obviously
					}
				}
				break;
			}
			skip = false;
		}
		
		if(XORRandom(100) == 0) //Tiny chance for dirt growth up into dirt background
		if(map.isTileGroundBack(map.getTile(tilePos).type))
		if(checkForGround(map.getTile(tilePos + Vec2f(0, 8)).type))map.server_SetTile(tilePos, CMap::tile_ground);
		
	}
}

bool CheckPosBlocked(Vec2f middle){
	
	CMap @map = getMap();
	
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
	return map.isTileGround(tile) || map.isTileStone(tile) || map.isTileThickStone(tile) || map.isTileGold(tile);
}