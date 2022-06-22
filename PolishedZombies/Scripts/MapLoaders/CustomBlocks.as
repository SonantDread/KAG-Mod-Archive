/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		custom_start = 383,

		// Tile gold from 384 to 391
		tile_goldB = 384,
		tile_goldB_d0 = 385,
		tile_goldB_d1 = 386,
		tile_goldB_d2 = 387,
		tile_goldB_d3 = 388,
		tile_goldB_d4 = 389,
		tile_goldB_d5 = 390,
		tile_goldB_d6 = 391,
		tile_goldB_d7 = 392,
		tile_goldB_d8 = 393,
		tile_goldB_d9 = 394,
		tile_goldB_d10 = 395,
		tile_goldB_d11 = 396,
		tile_goldB_d12 = 397,
		tile_goldB_d13 = 398,
	};
};

namespace map_colors
{
	enum CustomColor
	{
		tile_goldB		= 0xFFEAB127,
	}
}

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	switch (pixel.color)
	{
		case map_colors::tile_goldB:		map.SetTile(offset, CMap::tile_goldB);			break;
		default:	break;
	};
}