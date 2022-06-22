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

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	if(oldTileType > CMap::custom_start)
	{
		switch(oldTileType)
		{
			case CMap::tile_goldbrick:
				return CMap::tile_goldbrick_d1;
			
			case CMap::tile_goldbrick_d0:
			case CMap::tile_ladder_n:
			case CMap::tile_fake_dirt:
			case CMap::tile_fake_castle:
			case CMap::tile_fake_wood:
			case CMap::tile_fake_goldbrick:
				return CMap::tile_empty;

			case CMap::tile_ladder_ground_n:
				return CMap::tile_ground_back;

			case CMap::tile_ladder_castle_n:
				return CMap::tile_castle_back;

			case CMap::tile_ladder_wood_n:
				return CMap::tile_wood_back;

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
		if(tile_new >= CMap::tile_goldbrick && tile_new <= CMap::tile_goldbrick_d0)
		{
			if(isClient())
			{
				Vec2f pos = map.getTileWorldPosition(index);
				if(tile_new == CMap::tile_goldbrick)
				{
					Sound::Play("build_wall2.ogg", pos);
					if((((pos.y/map.tilesize) % 2)+pos.x/map.tilesize) % 2 == 1)
					{
						map.SetTile(index, CMap::tile_goldbrick+1);
					}
				}
				else if(tile_new >= CMap::tile_goldbrick_d1 && tile_new <= CMap::tile_goldbrick_d0)
				{
					Sound::Play("dig_stone"+(XORRandom(3)+1)+".ogg", pos);
					TileParticles::Gold(pos, true);
				}
			}
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.SetTileSupport(index, 12);
		}
		else if(tile_new >= CMap::tile_ladder_n && tile_new <= CMap::tile_ladder_wood_n)
		{
			if(isClient())
			{
				Vec2f pos = map.getTileWorldPosition(index);
				Sound::Play("build_ladder.ogg", pos);
			}
			if(tile_new == CMap::tile_ladder_n)
			{
				if(tile_old == CMap::tile_ground_back)
				{
					map.SetTile(index, CMap::tile_ladder_ground_n);
					map.SetTileDirt(index, CMap::tile_ground_back);
				}
				else if(tile_old == CMap::tile_castle_back || tile_old == CMap::tile_castle_back_moss)
				{
					map.SetTile(index, CMap::tile_ladder_castle_n);
				}
				else if(tile_old == CMap::tile_wood_back)
				{
					map.SetTile(index, CMap::tile_ladder_wood_n);
				}
				else
				{
					map.AddTileFlag(index, Tile::LIGHT_SOURCE);
				}
			}
			else
			{
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE);
			}
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES | Tile::FLAMMABLE);
			map.SetTileSupport(index, 10);
		}
		else if(tile_new >= CMap::tile_fake_dirt && tile_new <= CMap::tile_fake_goldbrick)
		{
			if(isClient())
			{
				Vec2f pos = map.getTileWorldPosition(index);
				if(tile_new == CMap::tile_fake_dirt)
				{
					Sound::Play("dig_dirt"+(XORRandom(3)+1)+".ogg", pos);
				}
				else if(tile_new == CMap::tile_fake_castle || tile_new == CMap::tile_fake_goldbrick)
				{
					Sound::Play("build_wall2.ogg", pos);
				}
				else if(tile_new == CMap::tile_fake_wood)
				{
					Sound::Play("build_wood.ogg", pos);
				}
			}
			map.SetTileSupport(index, 16);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
			map.AddTileFlag(index, Tile::WATER_PASSES);
		}
	}
	else if(tile_new < 256 && tile_old > CMap::custom_start)
	{
		if(isClient())
		{
			Vec2f pos = map.getTileWorldPosition(index);
			if(tile_old >= CMap::tile_goldbrick && tile_old <= CMap::tile_goldbrick_d0)
			{
				Sound::Play("destroy_gold.ogg", pos);
				TileParticles::Gold(pos, false);
			}
			else if(tile_old >= CMap::tile_ladder_n && tile_old <= CMap::tile_ladder_wood_n)
			{
				Sound::Play("destroy_ladder.ogg", pos);
				TileParticles::Wood(pos, true);
			}
			else if(tile_old == CMap::tile_fake_dirt)
			{
				Sound::Play("dig_dirt"+(XORRandom(3)+1)+".ogg", pos);
				TileParticles::Dirt(pos, false);
			}
			else if(tile_old == CMap::tile_fake_castle)
			{
				Sound::Play("destroy_wall.ogg", pos);
				TileParticles::Castle(pos, false);
			}
			else if(tile_old == CMap::tile_fake_wood)
			{
				Sound::Play("destroy_wood.ogg", pos);
				TileParticles::Wood(pos, false);
			}
			else if(tile_old == CMap::tile_fake_goldbrick)
			{
				Sound::Play("destroy_gold.ogg", pos);
				TileParticles::Gold(pos, false);
			}
		}
	}
}