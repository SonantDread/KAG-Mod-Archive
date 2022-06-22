// LoaderUtilities.as

#include "DummyCommon.as";
#include "CMap.as";
#include "BlockCommon.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	if(oldTileType >= 300){
		for(int i = 0;i < Blocks.length;i++){
			BlockInfo @Block = Blocks[i];
			if(oldTileType >= Block.BeginIndex && oldTileType <= Block.EndIndex){
				int newBlock = oldTileType;
				if(oldTileType >= Block.BeginIndex && oldTileType < Block.EndIndex){

					newBlock = oldTileType+1;
					Sound::Play(Block.hit_sound, this.getTileWorldPosition(index), 1.0f, 1.0f);	
				} else {
					newBlock = Block.TransformIndex;
					Sound::Play(Block.destroy_sound, this.getTileWorldPosition(index), 1.0f, 1.0f);	
				}
				
				if(newBlock == Block.EndIndex+1)newBlock = Block.TransformIndex;
				
				return newBlock;
			}
		}
	}
	
	return oldTileType;
}


void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
	/*
	if(getNet().isServer())
	if(tile_new == CMap::tile_castle){
		if(map.getTile(index+1).type == CMap::tile_castle){
			map.server_SetTile(map.getTileWorldPosition(index), CMap::tile_left_slab);
			tile_new = CMap::tile_left_slab;
			map.server_SetTile(map.getTileWorldPosition(index+1), CMap::tile_right_slab);
		}
		if(map.getTile(index-1).type == CMap::tile_castle){
			map.server_SetTile(map.getTileWorldPosition(index), CMap::tile_right_slab);
			tile_new = CMap::tile_right_slab;
			map.server_SetTile(map.getTileWorldPosition(index-1), CMap::tile_left_slab);
		}
	}*/
	
	if(tile_new >= 300){
		for(int i = 0;i < Blocks.length;i++){
			BlockInfo @Block = Blocks[i];
			if(tile_new >= Block.BeginIndex && tile_new <= Block.EndIndex){
				map.SetTileSupport(index, Block.support);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES | Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
				map.AddTileFlag(index, Block.flags);
				if(tile_old < Block.BeginIndex || tile_old > Block.EndIndex){
					Sound::Play(Block.place_sound, map.getTileWorldPosition(index), 1.0f, 1.0f);
				}
				break;
			}
		}
	}
}