// LoaderUtilities.as

#include "DummyCommon.as";

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


TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(oldTileType > CMap::custom_start)
	{
		switch(oldTileType)
		{
			case CMap::tile_goldB:
				return CMap::tile_goldB_d0;

			case CMap::tile_goldB_d0:
			case CMap::tile_goldB_d1:
			case CMap::tile_goldB_d2:
			case CMap::tile_goldB_d3:
			case CMap::tile_goldB_d4:
			case CMap::tile_goldB_d5:
			case CMap::tile_goldB_d6:
			case CMap::tile_goldB_d7:
			case CMap::tile_goldB_d8:
			case CMap::tile_goldB_d9:
			case CMap::tile_goldB_d10:
			case CMap::tile_goldB_d11:
			case CMap::tile_goldB_d12:
				return oldTileType + 1;

			case CMap::tile_goldB_d13:
				return CMap::tile_empty;

			default:
				return oldTileType+1;
		}
	}
	return oldTileType;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(isDummyTile(tile_new) && tile_new <= CMap::custom_start)
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
	else if(tile_new > CMap::custom_start)
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case CMap::tile_goldB:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient())
					Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_goldB_d0:
			case CMap::tile_goldB_d1:
			case CMap::tile_goldB_d2:
			case CMap::tile_goldB_d3:
			case CMap::tile_goldB_d4:
			case CMap::tile_goldB_d5:
			case CMap::tile_goldB_d6:
			case CMap::tile_goldB_d7:
			case CMap::tile_goldB_d8:
			case CMap::tile_goldB_d9:
			case CMap::tile_goldB_d10:
			case CMap::tile_goldB_d11:
			case CMap::tile_goldB_d12:
			case CMap::tile_goldB_d13:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient())
					Sound::Play("dig_stone.ogg", map.getTileWorldPosition(index), 1.0f, 0.7f);
				break;
		}
	}
	else if(tile_new < 256 && tile_old > CMap::custom_start)
	{
		switch(tile_new)
		{
			case CMap::tile_empty:
			case CMap::tile_ground_back:
				if (tile_old == CMap::tile_goldB_d13 && isClient())
					Sound::Play("destroy_stone.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
		}
	}
}