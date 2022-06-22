#include "canGrow.as";
#include "MakeSeed.as";
#include "Hitters.as";

const string[] forest_seeds =
{
	"tree_pine",
	"tree_bushy",
	"tree_large",
	"bush"
};

const string[] seeds =
{
	"tree_pine",
	"tree_bushy",
	"bush",
	"grain_plant",
	"flowers"
};

const string[] field_seeds =
{
	"bush",
	"grain_plant",
	"flowers"
};

const Vec2f[] dir =
{
	Vec2f(8, 0),
	Vec2f(-8, 0),
	Vec2f(0, 8)
};


void DecayStuff(int times){
	for(int i = 0;i < times;i++){
		Decay();
	}
}

void Decay()
{
	CMap@ map = getMap();
	
	Vec2f tilePos = Vec2f(XORRandom(map.tilemapwidth) * map.tilesize,XORRandom(map.tilemapheight) * map.tilesize);
	
	uint16 tile = map.getTile(tilePos).type;
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 32, @blobs);
	
	bool overgrow = false;
	bool forest = false;
	bool wheat_field = false;
	
	for(int i = 0;i < blobs.length;i++){
		string name = blobs[i].getName();
		if(name == "tree_bushy"){overgrow = true;forest = true;}
		else if(name == "tree_pine"){overgrow = true;forest = true;}
		else if(name == "tree_large"){overgrow = true;forest = true;}
		else if(name == "grain_plant"){
			overgrow = true;
			wheat_field = true;
		}
		else if(name == "flowers")overgrow = true;
		else if(name == "bush"){
			overgrow = true;
			if(XORRandom(1000) == 0){
				server_CreateBlob("big_bush",-1,blobs[i].getPosition());
				blobs[i].server_Die();
			}
		}
	}
	
	int moss = 0;
	for(int i = -2;i <= 2 && !overgrow;i++)
	for(int j = -2;j <= 2 && !overgrow;j++){
		if(map.isTileGrass(map.getTile(tilePos+Vec2f(i*8,j*8)).type))overgrow = true;
	}
	
	for(int i = -1;i <= 1;i++)
	for(int j = -1;j <= 1;j++){
		if(map.isTileGrass(map.getTile(tilePos+Vec2f(i*8,j*8)).type))moss++;
		else if(map.getTile(tilePos+Vec2f(i*8,j*8)).type == CMap::tile_castle_moss)moss++;
		else if(map.getTile(tilePos+Vec2f(i*8,j*8)).type == CMap::tile_castle_back_moss)moss++;
	}
	if(moss > 0)overgrow = true;
	
	
	if(overgrow){
		if(moss <= 3 && getBlobsInRadius(map, tilePos, "light", 320) == 0){
			if(map.isTileCastle(tile)) //Mossy tiles
			{
				map.server_SetTile(tilePos, CMap::tile_castle_moss);
			}
			else if(map.getTile(tilePos).type == CMap::tile_castle_back) //Mossy tiles
			{
				map.server_SetTile(tilePos, CMap::tile_castle_back_moss);
			}
		}
		
		if(!map.isInWater(tilePos))
		{	//Grass tiles
			if(map.getTile(tilePos).type == CMap::tile_empty && (map.isTileGround(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileStone(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileThickStone(map.getTile(tilePos + Vec2f(0, 8)).type) || (isTileSolidMossy(map.getTile(tilePos + Vec2f(0, 8)).type) && moss <= 3))) 
			{
				map.server_SetTile(tilePos, CMap::tile_grass + XORRandom(3));
			}
			
			if(XORRandom(10) == 0)
			if(map.getTile(tilePos).type == CMap::tile_grass && (map.isTileGround(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileStone(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileThickStone(map.getTile(tilePos + Vec2f(0, 8)).type))) 
			{
				if((tilePos.x/8) % 100 < 50){
					if(wheat_field){
						server_MakeSeed(tilePos + Vec2f(0, -8), "grain_plant");
					} else
					server_MakeSeed(tilePos + Vec2f(0, -8), field_seeds[XORRandom(field_seeds.length)]);
				} else {
					if(forest){
						server_MakeSeed(tilePos + Vec2f(0, -8), forest_seeds[XORRandom(forest_seeds.length)]);
					} else
					if(XORRandom(2) == 0)server_MakeSeed(tilePos + Vec2f(0, -8), seeds[XORRandom(seeds.length)]);
				}
			}
		}
		
		/*
		if(map.getTile(tilePos).type == CMap::tile_empty) //empty
		{
			if(map.isTileGroundStuff(map.getTile(tilePos + Vec2f(0, 8)).type) || map.isTileGroundBack(map.getTile(tilePos + Vec2f(0, 8)).type))if(XORRandom(10) == 0 && tilePos.y > 50*8)map.server_SetTile(tilePos, CMap::tile_ground_back);
			if(map.isTileGroundStuff(map.getTile(tilePos + Vec2f(0, -8)).type) || map.isTileGroundBack(map.getTile(tilePos + Vec2f(0, -8)).type))map.server_SetTile(tilePos, CMap::tile_ground_back);
			if(map.isTileGroundStuff(map.getTile(tilePos + Vec2f(-8, 0)).type) || map.isTileGroundBack(map.getTile(tilePos + Vec2f(-8, 0)).type))if(XORRandom(2) == 0)map.server_SetTile(tilePos, CMap::tile_ground_back);
			if(map.isTileGroundStuff(map.getTile(tilePos + Vec2f(8, 0)).type) || map.isTileGroundBack(map.getTile(tilePos + Vec2f(8, 0)).type))if(XORRandom(2) == 0)map.server_SetTile(tilePos, CMap::tile_ground_back);
		}*/
	}
	
	if (map.isTileWood(tile) && tile != CMap::tile_wood_d0) //Damage wood
	{
		if(map.isInWater(tilePos+Vec2f(8,0))
		|| map.isInWater(tilePos+Vec2f(0,8))
		|| map.isInWater(tilePos+Vec2f(-8,0)))
		map.server_DestroyTile(tilePos, 0.5f);
	}
	
	{
		if(map.getTile(tilePos).type == CMap::tile_empty && map.getTile(tilePos + Vec2f(0, 8)).type == CMap::tile_empty && map.getTile(tilePos + Vec2f(0, 16)).type == CMap::tile_empty){
			int type = map.getTile(tilePos + Vec2f(0, -8)).type;
			if(isTileSolidMossy(type)) //Grow ivy
			{
				if(getBlobsInRadius(map, tilePos+Vec2f(0,16), "ivy", 12) == 0)server_CreateBlob("ivy",-1,tilePos+Vec2f(0,16));
			}
		}
	}
}

bool isTileMossy(int tile){
	
	if(tile >= CMap::tile_castle_moss && tile <= CMap::tile_castle_moss+7)return true;
	
	return false;
}

bool isTileSolidMossy(int tile){
	
	if(tile >= CMap::tile_castle_moss && tile <= CMap::tile_castle_moss+2)return true;
	
	return false;
}

u32 getBlobsInRadius(CMap@ map, const Vec2f pos, const string tag, const f32 radius = 8.0f)
{
	CBlob@[] blobs;
	map.getBlobsInRadius(pos, radius, @blobs);

	u32 counter = 0;
	
	if(tag != "light"){
		for (int i = 0; i < blobs.length; i++)
		{
			if (blobs[i].hasTag(tag) || blobs[i].getName() == tag) counter++;
		}
	} else {
		for (int i = 0; i < blobs.length; i++)
		{
			if(blobs[i].isLight()){
				if(blobs[i].getLightRadius()*0.8f > (blobs[i].getPosition()-pos).Length())
				counter++;
			}
		}
	}

	return counter;
}
