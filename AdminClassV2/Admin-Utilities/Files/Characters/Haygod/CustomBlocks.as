#include "LoaderUtilities.as"
namespace CMap
{
	enum CustomTiles
	{
		tile_steel = 400,
		tile_steel_d0 = 401,
		tile_steel_d1 = 402,
		tile_steel_d2 = 403,
		tile_steel_d3 = 404,
		tile_steel_d4 = 405,
		tile_steel_d5 = 406,
		
		tile_mossy_wood = 416,
		tile_mossy_wood_d0 = 200,
		tile_mossy_wood_d1 = 201,
		tile_mossy_wood_d2 = 202,
		tile_mossy_wood_d3 = 203,
		tile_mossy_wood_d4 = 204,
		
		tile_castle_gold = 407,
		tile_castle_gold_d0 = 408,
		tile_castle_gold_d1 = 409,
		tile_castle_gold_d2 = 410,
		tile_castle_gold_d3 = 411,
		tile_castle_gold_d4 = 412,
		tile_castle_gold_d5 = 413,
		
		tile_birk_godl = 423,
		tile_birk_godl_d0 = 424,
		tile_birk_godl_d1 = 425,
		tile_birk_godl_d2 = 426,
		tile_birk_godl_d3 = 427,
		
		tile_dark_castle_block = 432,
		tile_dark_castle_block_d0 = 442,
		tile_dark_castle_block_d1 = 443,
		tile_dark_castle_block_d2 = 444,
		tile_dark_castle_block_d3 = 445,
		tile_dark_castle_block_d4 = 446,
		tile_dark_castle_block_d5 = 447,
		
		tile_sandewel = 448,
		tile_sandewel_d0 = 449,
		tile_sandewel_d1 = 450,
		tile_sandewel_d2 = 451,
		tile_sandewel_d3 = 452,
	};
};

									   
void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	/*{
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION ); 
		
	}
	{
		map.RemoveTileFlag( offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
	}*/
}

