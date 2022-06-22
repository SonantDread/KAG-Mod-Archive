
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

#include "LoaderColors.as";
#include "BlockCommon.as";
 
namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_whatever = 300
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	for(int i = 0;i < Blocks.length;i++){
		BlockInfo @Block = Blocks[i];
		for(int j = Block.BeginIndex;j <= Block.EndIndex;j++){
			
			if(j-255 > 0){
		
				if(pixel == SColor(255,5,10,j-255)){
					map.SetTile(offset, j);
					return;
				}
			
			}
		}
	}
}

SColor HandleCustomTileSave(TileType tile)
{
	if(tile >= 255){
		for(int i = 0;i < Blocks.length;i++){
			BlockInfo @Block = Blocks[i];
			if(tile >= Block.BeginIndex && tile <= Block.EndIndex){
				//print("Saving with Tile colour:"+(tile-255));
				return SColor(255,5,10,tile-255);
			}
		}
	}
	return map_colors::unused;
}