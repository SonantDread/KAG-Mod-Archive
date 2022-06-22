#include "CMap.as";


class BlockInfo
{
	string name;
	int BeginIndex;
	int EndIndex;
	int TransformIndex;
	int support;
	uint flags;
	
	string place_sound;
	string hit_sound;
	string destroy_sound;
	
	BlockInfo(string name, int BeginIndex, int EndIndex, int TransformIndex, int support, uint flags, string place_sound, string hit_sound, string destroy_sound)
	{
		this.name = name;
		
		this.BeginIndex = BeginIndex;
		this.EndIndex = EndIndex;
		this.TransformIndex = TransformIndex;
		
		this.support = support;
		this.flags = flags;
		
		this.hit_sound = hit_sound;
		this.destroy_sound = destroy_sound;
		this.place_sound = place_sound;
	}
};

BlockInfo[] Blocks = {
	BlockInfo("gold_brick", CMap::tile_gold_brick, CMap::tile_gold_brick+7, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "goldsack_take.ogg"),
	BlockInfo("left_slab", CMap::tile_left_slab, CMap::tile_left_slab+5, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "PickStone1.ogg", "destroy_wall.ogg"),
	BlockInfo("right_slab", CMap::tile_right_slab, CMap::tile_right_slab+5, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "PickStone1.ogg", "destroy_wall.ogg"),
	BlockInfo("gold_pile", CMap::tile_gold_pile, CMap::tile_gold_pile+4, CMap::tile_empty, 4, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES, "goldsack_take.ogg", "goldsack_take.ogg", "goldsack_take.ogg"),
	
	BlockInfo("hard_stone", CMap::tile_stone_hard, CMap::tile_stone_hard+23, CMap::tile_thickstone, 4, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "destroy_stone.ogg"),
	
	BlockInfo("gold_gem_weak", CMap::tile_gold_gem_weak, CMap::tile_gold_gem_weak+5, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "goldsack_take.ogg"),
	BlockInfo("gold_gem", CMap::tile_gold_gem, CMap::tile_gold_gem+7, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "goldsack_take.ogg"),
	BlockInfo("gold_gem_strong", CMap::tile_gold_gem_strong, CMap::tile_gold_gem_strong+12, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "goldsack_take.ogg"),
	BlockInfo("gold_gem_unstable", CMap::tile_gold_gem_unstable, CMap::tile_gold_gem_unstable+19, CMap::tile_empty, 10, Tile::SOLID | Tile::COLLISION, "build_wall.ogg", "dig_stone1.ogg", "goldsack_take.ogg")
};