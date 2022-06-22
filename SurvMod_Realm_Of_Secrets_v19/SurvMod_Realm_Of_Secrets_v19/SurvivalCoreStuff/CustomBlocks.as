
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
		tile_whatever = 300
	};
};

const SColor color_black_market(0xff130d1d);
const SColor color_ghost_stone(0xff9db184);
const SColor color_mech_hall(0xffffbe0a);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if(color_black_market == pixel){
		server_CreateBlob("black_market", -1, getMap().getTileWorldPosition(offset));
		//autotile(offset);
	}
	if(color_ghost_stone == pixel){
		server_CreateBlob("ghost_stone", -1, getMap().getTileWorldPosition(offset));
		//autotile(offset);
	}
	if(color_mech_hall == pixel){
		server_CreateBlob("old_hall", -1, getMap().getTileWorldPosition(offset)+Vec2f(8,-8));
		//autotile(offset);
	}
}