// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Hitters.as";
#include "BasePNGLoader.as";

namespace CMap
{
	enum NewTiles
	{
		tile_goldbullion = 272,
		tile_goldbullion_d0,
		tile_goldbullion_d1,
		tile_goldbullion_d2,
		tile_goldbullion_d3,
	};
};

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
	if(map.getTile(index).type > 271)
	{
		switch(oldTileType)
		{
			case CMap::tile_goldbullion:
			{
				return CMap::tile_goldbullion_d0;
			}
			case CMap::tile_goldbullion_d0:
			case CMap::tile_goldbullion_d1:
			case CMap::tile_goldbullion_d2:
			{
				return map.getTile(index).type+1;
			}
			case CMap::tile_goldbullion_d3:
			{
				//OnGoldTileDestroyed(map, index);
				return CMap::tile_empty;
			}
		}
	}
	return map.getTile(index).type;
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
	switch(tile_new)
	{
		
		case CMap::tile_empty:
		case CMap::tile_ground_back:
		{
			if(tile_old == CMap::tile_goldbullion_d3)
				OnGoldTileDestroyed(map, index);
			break;
		}
		case CMap::tile_goldbullion:
		{
			map.SetTileSupport(index, 4);
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES );
			if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			break;
		}
		case CMap::tile_goldbullion_d0:
		case CMap::tile_goldbullion_d1:
		case CMap::tile_goldbullion_d2:
		case CMap::tile_goldbullion_d3:
		{
			map.SetTileSupport(index, 4);
			OnGoldTileHit(map, index);
			break;
		}
	}
}

void OnGoldTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		GoldParticles(pos, 5 + XORRandom(5));
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnGoldTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		GoldParticles(pos, 10 + XORRandom(5));
		Sound::Play("destroy_gold.ogg", pos, 1.0f, 1.0f);
	}
}

void GoldParticles(Vec2f at, int amount)
{
	//int amount = 15 + XORRandom(5);

	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
		vel.y = -Maths::Abs(vel.y) + Maths::Abs(vel.x) / 4.0f - 2.0f - float(XORRandom(100)) / 100.0f;
		//SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 148, 27, 27) : SColor(255, 196, 207, 161);
		at += Vec2f(2.0f, 2.0f);
		SColor[] colors = {	SColor(255, 196, 135, 58),
							SColor(255, 255, 214, 125),
							SColor(255, 234, 177, 39),
							SColor(255, 132, 71, 21),
							SColor(255, 85, 42, 17),
							SColor(255, 19, 13, 29)};
		ParticlePixel(at, vel, colors[XORRandom(6)], true);
	}
}