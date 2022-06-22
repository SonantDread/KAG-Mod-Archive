#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Explosion.as";
#include "Hitters.as";
#include "CustomBlocks.as";
//#include "MatterSparks.as";

void CalculateMinimapColour( CMap@ this, u32 offset, TileType tile, SColor &out col)
{
    if (this.isTileSolid(tile) || (tile >= 384 && tile <= 430))
	{
		TileType leftside = this.getTile( offset - 1).type;
		TileType rightside = this.getTile( offset + 1).type;
		TileType upside = this.getTile( offset - this.tilemapwidth).type;
		TileType downside = this.getTile( offset + this.tilemapwidth).type;
		if(
		(!this.isTileSolid(leftside) && leftside < 256) ||
		(!this.isTileSolid(rightside) && rightside < 256) ||
		(!this.isTileSolid(upside) && upside < 256) ||
		(!this.isTileSolid(downside) && downside < 256)
		)
		col = SColor(0xff844715);
		else
		col = SColor(0xffC4873A);
	}
	else if (!this.isTileSolid(tile) && tile != 0 && !isGrassTile(tile))
	{
		TileType leftside = this.getTile( offset - 1).type;
		TileType rightside = this.getTile( offset + 1).type;
		TileType upside = this.getTile( offset - this.tilemapwidth).type;
		TileType downside = this.getTile( offset + this.tilemapwidth).type;
		if(
		(leftside == 0) ||
		(rightside == 0) ||
		(downside == 0) ||
		(upside == 0)
		)
		{
			if(this.isInWater(this.getTileWorldPosition(offset)))
				col = SColor(0xff789B8C);
			else
				col = SColor(0xffC4873A);
		}
		else
		{
			if(this.isInWater(this.getTileWorldPosition(offset)))
				col = SColor(0xff90AE9D);
			else
				col = SColor(0xffF3AC5C);
		}
	}
	else if (this.getTile(offset).type == 0 || isGrassTile(tile))
	{
		if(this.isInWater(this.getTileWorldPosition(offset)))
			col = SColor(0xffBDC5B4);
		else
			col = SColor(0xffEDCCA6);
	}
}

bool isGrassTile(u16 tile)
{
    return tile >= 25 && tile <= 28;
}

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(map.getTile(offset).type > 255)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
		CRules@ rules = getRules();
		if(map.getTile(offset).type == CMap::tile_matter)
		{
			CBitStream params;
			params.write_Vec2f(map.getTileWorldPosition(offset));
			rules.SendCommand(rules.getCommandID("remove_tile"), params);
		}
	}
	
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{
			case CMap::tile_iron:
				return CMap::tile_iron_d0;
				
			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
				return oldTileType + 1;

			case CMap::tile_iron_d8:
				return CMap::tile_empty;


			case CMap::tile_glass:
				return CMap::tile_glass_d0;

			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				
				map.server_SetTile(pos, CMap::tile_glass_d0);

				for (u8 i = 0; i < 4; i++)
				{
					glass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_glass_d0;
			}

			case CMap::tile_glass_d0:
				return CMap::tile_empty;


			case CMap::tile_plasteel:
				return CMap::tile_plasteel_d0;

			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
				return oldTileType + 1;

			case CMap::tile_plasteel_d14:
				return CMap::tile_empty;


			case CMap::tile_matter:
				return CMap::tile_matter_d0;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
				return oldTileType + 1;
				
			case CMap::tile_matter_d2:
				return CMap::tile_empty;
				
			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				return CMap::tile_brick_v0; //v to d


			case CMap::tile_bglass:
				return CMap::tile_bglass_d0;

			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				
				map.server_SetTile(pos, CMap::tile_bglass_d0);
				
				for (u8 i = 0; i < 4; i++)
				{
					bglass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bglass_d0;
			}

			case CMap::tile_bglass_d0:
				return CMap::tile_empty;


			case CMap::tile_biron:
				return CMap::tile_biron_d0;

			case CMap::tile_biron_u:
			case CMap::tile_biron_d:
			case CMap::tile_biron_m:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				
				map.server_SetTile(pos, CMap::tile_biron_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				
				OnBIronTileUpdate(false, true, map, map.getTileWorldPosition(index));
				return CMap::tile_biron_d0;
			}

			case CMap::tile_biron_d0:
			case CMap::tile_biron_d1:
			case CMap::tile_biron_d2:
			case CMap::tile_biron_d3:
			case CMap::tile_biron_d4:
			case CMap::tile_biron_d5:
			case CMap::tile_biron_d6:
			case CMap::tile_biron_d7:
				return oldTileType + 1;

			case CMap::tile_biron_d8:
				return CMap::tile_empty;


			case CMap::tile_bplasteel:
			case CMap::tile_bplasteel_v0:
				return CMap::tile_bplasteel_d0;
				
			case CMap::tile_bplasteel_d0:
			case CMap::tile_bplasteel_d1:
			case CMap::tile_bplasteel_d2:
			case CMap::tile_bplasteel_d3:
			case CMap::tile_bplasteel_d4:
			case CMap::tile_bplasteel_d5:
			case CMap::tile_bplasteel_d6:
			case CMap::tile_bplasteel_d7:
			case CMap::tile_bplasteel_d8:
			case CMap::tile_bplasteel_d9:
			case CMap::tile_bplasteel_d10:
			case CMap::tile_bplasteel_d11:
			case CMap::tile_bplasteel_d12:
			case CMap::tile_bplasteel_d13:
				return oldTileType + 1;

			case CMap::tile_bplasteel_d14:
				return CMap::tile_empty;


			case CMap::tile_tnt:
			{
				OnTNTTileHit(map, index, damage, map.isInFire(map.getTileWorldPosition(index)));
				return CMap::tile_empty;
			}
			
			case CMap::tile_concrete:
				return CMap::tile_concrete_d0;

			case CMap::tile_concrete_v0:
			case CMap::tile_concrete_v1:
			case CMap::tile_concrete_v2:
			case CMap::tile_concrete_v3:
			case CMap::tile_concrete_v4:
			case CMap::tile_concrete_v5:
			case CMap::tile_concrete_v6:
			case CMap::tile_concrete_v7:
			case CMap::tile_concrete_v8:
			case CMap::tile_concrete_v9:
			case CMap::tile_concrete_v10:
			case CMap::tile_concrete_v11:
			case CMap::tile_concrete_v12:
			case CMap::tile_concrete_v13:
			case CMap::tile_concrete_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				
				map.server_SetTile(pos, CMap::tile_concrete_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

				for (u8 i = 0; i < 4; i++)
				{
					concrete_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_concrete_d0;
			}
			
			case CMap::tile_concrete_d0:
			case CMap::tile_concrete_d1:
			case CMap::tile_concrete_d2:
			case CMap::tile_concrete_d3:
			case CMap::tile_concrete_d4:
			case CMap::tile_concrete_d5:
			case CMap::tile_concrete_d6:
				return oldTileType + 1;

			case CMap::tile_concrete_d7:
			{
				return CMap::tile_empty;
			}
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (tile_new == CMap::tile_ground && getNet().isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

	switch(tile_new)
	{
		case CMap::tile_empty:
		case CMap::tile_ground_back:
		{
			if(tile_old == CMap::tile_iron_d8 || tile_old == CMap::tile_biron_d8)
				OnIronTileDestroyed(map, index);
			else if (tile_old == CMap::tile_bglass_d0 || tile_old == CMap::tile_glass_d0)
				OnGlassTileDestroyed(map, index);
			else if (tile_old == CMap::tile_plasteel_d14 || tile_old == CMap::tile_bplasteel_d14)
				OnPlasteelTileDestroyed(map, index);
			else if (tile_old == CMap::tile_concrete_d7)
				OnConcreteTileDestroyed(map, index);
			else if (tile_old == CMap::tile_matter_d2)
				OnMatterTileDestroyed(map, index);
			break;
		}
	}
	
	CRules@ rules = getRules();
	if(tile_new == CMap::tile_matter)
	{
		CBitStream params;
		params.write_Vec2f(map.getTileWorldPosition(index));
		rules.SendCommand(rules.getCommandID("add_tile"), params);
	}
	if(tile_old == CMap::tile_matter)
	{
		CBitStream params;
		params.write_Vec2f(map.getTileWorldPosition(index));
		rules.SendCommand(rules.getCommandID("remove_tile"), params);
	}
	

	if (map.getTile(index).type > 255)
	{
		u32 id = tile_new;

		map.SetTileSupport(index, 10);

		switch(tile_new)
		{		
			case CMap::tile_iron:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:	
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
			case CMap::tile_iron_d8:
				OnIronTileHit(map, index);
				break;


			case CMap::tile_glass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				glass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
				
			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				break;
				
			case CMap::tile_glass_d0:
				OnGlassTileHit(map, index);
				break;


			case CMap::tile_plasteel:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
						
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
			case CMap::tile_plasteel_d14:
				OnPlasteelTileHit(map, index);
				break;
				
			case CMap::tile_matter:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_d2:
				OnMatterTileHit(map, index);
				break;
				
			case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_bglass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				bglass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
				
			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				break;
				
			case CMap::tile_bglass_d0:
				OnBGlassTileHit(map, index);
				break;
				
			case CMap::tile_biron:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				OnBIronTileUpdate(false, true, map, pos);
				
				TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;
				TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;
				bool isUp = (up >= CMap::tile_biron && up <= CMap::tile_biron_m) ? true : false;
				bool isDown = (down >= CMap::tile_biron && down <= CMap::tile_biron_m) ? true : false;

				if(isUp && isDown)
					map.SetTile(index, CMap::tile_biron_m);
				else if(isUp || isDown)
				{
					if(isUp && !isDown)
						map.SetTile(index, CMap::tile_biron_u);
					if(!isUp && isDown)
						map.SetTile(index, CMap::tile_biron_d);
				}
				else
					map.SetTile(index, CMap::tile_biron);

				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				
				break;
			}
			
			case CMap::tile_biron_u:
			case CMap::tile_biron_d:
			case CMap::tile_biron_m:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_biron_d0:
			case CMap::tile_biron_d1:
			case CMap::tile_biron_d2:
			case CMap::tile_biron_d3:
			case CMap::tile_biron_d4:
			case CMap::tile_biron_d5:
			case CMap::tile_biron_d6:
			case CMap::tile_biron_d7:
			case CMap::tile_biron_d8:
				OnBIronTileHit(map, index);
				break;
			
			case CMap::tile_bplasteel:
				if((index / map.tilemapwidth + index % map.tilemapwidth) % 2 == 0) map.SetTile(index, CMap::tile_bplasteel_v0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
						
			case CMap::tile_bplasteel_d0:
			case CMap::tile_bplasteel_d1:
			case CMap::tile_bplasteel_d2:
			case CMap::tile_bplasteel_d3:
			case CMap::tile_bplasteel_d4:
			case CMap::tile_bplasteel_d5:
			case CMap::tile_bplasteel_d6:
			case CMap::tile_bplasteel_d7:
			case CMap::tile_bplasteel_d8:
			case CMap::tile_bplasteel_d9:
			case CMap::tile_bplasteel_d10:
			case CMap::tile_bplasteel_d11:
			case CMap::tile_bplasteel_d12:
			case CMap::tile_bplasteel_d13:
			case CMap::tile_bplasteel_d14:
				OnBPlasteelTileHit(map, index);
				break;
			
			case CMap::tile_tnt:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES | Tile::FLAMMABLE);
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_concrete:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				
				concrete_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				if (getNet().isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				
				break;
			}
			
			case CMap::tile_concrete_v0:
			case CMap::tile_concrete_v1:
			case CMap::tile_concrete_v2:
			case CMap::tile_concrete_v3:
			case CMap::tile_concrete_v4:
			case CMap::tile_concrete_v5:
			case CMap::tile_concrete_v6:
			case CMap::tile_concrete_v7:
			case CMap::tile_concrete_v8:
			case CMap::tile_concrete_v9:
			case CMap::tile_concrete_v10:
			case CMap::tile_concrete_v11:
			case CMap::tile_concrete_v12:
			case CMap::tile_concrete_v13:
			case CMap::tile_concrete_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
				break;
				
			case CMap::tile_concrete_d0:
			case CMap::tile_concrete_d1:
			case CMap::tile_concrete_d2:
			case CMap::tile_concrete_d3:
			case CMap::tile_concrete_d4:
			case CMap::tile_concrete_d5:
			case CMap::tile_concrete_d6:
			case CMap::tile_concrete_d7:
				OnConcreteTileHit(map, index);
				break;
		}
	}
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void OnIronTileHit(CMap@ map, u32 index)														//
{																								//
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);										//
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );											//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);											//
		sparks(pos, 1, 1);																		//
	}																							//
}																								//
																								//
void OnBIronTileHit(CMap@ map, u32 index)														//
{																								//
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);			//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								// 
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);											//
		sparks(pos, 1, 1);																		//
	}																							//
}																								//
																								//
void OnIronTileDestroyed(CMap@ map, u32 index)													// 	8 8888 8	888888888o. 	    ,o888888o.     	b.             8 
{																								//	8 8888 8 	8888    `88. 	 . 8888     `88.   	888o.          8 
	if (getNet().isClient())																	//	8 8888 8 	8888     `88 	,8 8888       `8b  	Y88888o.       8 
	{ 																							//	8 8888 8 	8888     ,88 	88 8888        `8b 	.`Y888888o.    8 
		Vec2f pos = map.getTileWorldPosition(index);											//	8 8888 8 	8888     ,88 	88 8888        `8b 	.`Y888888o.    8 
																								//	8 8888 8 	8888.   ,88' 	88 8888         88 	8o. `Y888888o. 8 
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);										//	8 8888 8 	888888888P'  	88 8888         88 	8`Y8o. `Y88888o8 
	}																							//	8 8888 8 	8888`8b      	88 8888        ,8P 	8   `Y8o. `Y8888 
}																								//	8 8888 8 	8888 `8b.    	`8 8888       ,8P  	8      `Y8o. `Y8 
																								//	8 8888 8 	8888   `8b.  	 ` 8888     ,88'   	8         `Y8o.` 
void OnBIronTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos)				//	8 8888 8 	8888     `88.	    `8888888P'     	8            `Yo
{																								//
	TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;									//
	TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;									//
	bool isUp = (up >= CMap::tile_biron && up <= CMap::tile_biron_m) ? true : false;			//
	bool isDown = (down >= CMap::tile_biron && down <= CMap::tile_biron_m) ? true : false;		//
																								//
	if(updateThis)																				//
	{																							//
		if(isUp && isDown)																		//
			map.server_SetTile(pos, CMap::tile_biron_m);										//
		else if(isUp || isDown)																	//
		{																						//
			if(isUp && !isDown)																	//
				map.server_SetTile(pos, CMap::tile_biron_u);									//
			if(!isUp && isDown)																	//
				map.server_SetTile(pos, CMap::tile_biron_d);									//
		}																						//
		else																					//
			map.server_SetTile(pos, CMap::tile_biron);											//
	}																							//
	if(updateOthers)																			//
	{																							//
		if(isUp)																				//
			OnBIronTileUpdate(true, false, map, pos - Vec2f( 0.0f, 8.0f));						//
		if(isDown)																				//
			OnBIronTileUpdate(true, false, map, pos + Vec2f( 0.0f, 8.0f));						//
	}																							//
}																								//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void OnGlassTileHit(CMap@ map, u32 index)														//
{																								//
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);					//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);										//
		glasssparks(pos, 5 + XORRandom(5));														//
	}																							//
}																								//
																								//
void OnBGlassTileHit(CMap@ map, u32 index)														//
{																								//
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES);								//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);										//
		glasssparks(pos, 3 + XORRandom(2));														//
	}																							//
}																								//
																								//
void OnGlassTileDestroyed(CMap@ map, u32 index)													//
{																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("GlassBreak1.ogg", pos, 1.0f, 1.0f);										//
		glasssparks(pos, 5 + XORRandom(3));														//
	}																							//
}																								//
																								//
void glasssparks(Vec2f at, int amount)															//
{																								//
	switch(XORRandom(4))
	{		
		case 1:
			at += Vec2f(4, 0);
			break;
		case 2:
			at += Vec2f(0, 4);
			break;
		case 3:
			at += Vec2f(8, 4);
			break;
		case 4:
			at += Vec2f(4, 8);
			break;
	}																							//
	SColor[] colors = {	SColor(255, 217, 242, 246),												//
							SColor(255, 255, 255, 255),											//
							SColor(255, 85, 119, 130),											//
							SColor(255, 79, 145, 167),											//
							SColor(255, 48, 60, 65),											//
							SColor(255, 21, 27, 30)};											//
	for (int i = 0; i < amount; i++)															//
	{																							//
		Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);										//
		vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;	//
		ParticlePixel(at, vel, colors[XORRandom(6)], true);										//
		makeGibParticle("GlassSparks.png", at, vel, 0, XORRandom(5)-1, Vec2f(4.0f, 4.0f), 2.0f, 1, "GlassBreak1.ogg");
	}																							//
}																								//
																								//
u8 glass_GetMask(CMap@ map, Vec2f pos)															//
{																								//	     ,o888888o.   	 8 8888                  .8.            d888888o.      d888888o.   
    u8 mask = 0;																				//	    8888     `88. 	 8 8888                 .888.         .`8888:' `88.  .`8888:' `88. 
																								//	 ,8 8888       `8.	 8 8888                :88888.        8.`8888.   Y8  8.`8888.   Y8 
    for (u8 i = 0; i < 4; i++)																	//	 88 8888          	 8 8888               . `88888.       `8.`8888.      `8.`8888.     
    {																							//	 88 8888          	 8 8888              .8. `88888.       `8.`8888.      `8.`8888.    
        if (isGlassTile(map, pos + directions[i])) mask |= 1 << i;								//	 88 8888          	 8 8888             .8`8. `88888.       `8.`8888.      `8.`8888.   
    }																							//	 88 8888   8888888	 8 8888            .8' `8. `88888.       `8.`8888.      `8.`8888.  
																								//	 `8 8888       .8'	 8 8888           .8'   `8. `88888.  8b   `8.`8888. 8b   `8.`8888. 
    return mask;																				//	    8888     ,88' 	 8 8888          .888888888. `88888. `8b.  ;8.`8888 `8b.  ;8.`8888 
}																								//	     `8888888P'   	 8 888888888888 .8'       `8. `88888. `Y8888P ,88P'  `Y8888P ,88P' 
																								//
u8 bglass_GetMask(CMap@ map, Vec2f pos)															//
{																								//
    u8 mask = 0;																				//
																								//
    for (u8 i = 0; i < 4; i++)																	//
    {																							//
        if (isBGlassTile(map, pos + directions[i])) mask |= 1 << i;								//
    }																							//
																								//
    return mask;																				//
}																								//
																								//
void glass_SetTile(CMap@ map, Vec2f pos)														//
{																								//
    map.SetTile(map.getTileOffset(pos), CMap::tile_glass + glass_GetMask(map, pos));			//
																								//
    for (u8 i = 0; i < 4; i++)																	//
    {																							//
        glass_Update(map, pos + directions[i]);													//
    }																							//
}																								//
																								//
void bglass_SetTile(CMap@ map, Vec2f pos)														//
{																								//
    map.SetTile(map.getTileOffset(pos), CMap::tile_bglass + bglass_GetMask(map, pos));			//
																								//
    for (u8 i = 0; i < 4; i++)																	//
    {																							//
        bglass_Update(map, pos + directions[i]);												//
    }																							//
}																								//
																								//
void glass_Update(CMap@ map, Vec2f pos)															//
{																								//
    u16 tile = map.getTile(pos).type;															//
    if (isGlassTile(map, pos))																	//
		map.server_SetTile(pos,CMap::tile_glass+glass_GetMask(map,pos));						//
}																								//
																								//
void bglass_Update(CMap@ map, Vec2f pos)														//
{																								//
    u16 tile = map.getTile(pos).type;															//
    if (isBGlassTile(map, pos))																	//
		map.server_SetTile(pos,CMap::tile_bglass+bglass_GetMask(map,pos));						//
}																								//
																								//
bool isGlassTile(CMap@ map, Vec2f pos)															//
{																								//
    u16 tile = map.getTile(pos).type;															//
    return tile >= CMap::tile_glass && tile <= CMap::tile_glass_v14;							//
}																								//
																								//
bool isBGlassTile(CMap@ map, Vec2f pos)															//
{																								//
    u16 tile = map.getTile(pos).type;															//
    return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;							//
}																								//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void OnPlasteelTileHit(CMap@ map, u32 index)													//
{																								//
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);										//
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );											//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);											//
	}																							//
}																								//
																								//	8 888888888o   8 8888                  .8.            d888888o. 	8888888 8888888888 	8 8888888888   	8 8888888888   	8 8888         
void OnBPlasteelTileHit(CMap@ map, u32 index)													//	8 8888    `88. 8 8888                 .888.         .`8888:' `88.   	  8 8888       	8 8888         	8 8888         	8 8888         
{																								//	8 8888     `88 8 8888                :88888.        8.`8888.   Y8   	  8 8888       	8 8888         	8 8888         	8 8888         
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);			//	8 8888     ,88 8 8888               . `88888.       `8.`8888.       	  8 8888       	8 8888         	8 8888         	8 8888         
																								//	8 8888.   ,88' 8 8888              .8. `88888.       `8.`8888.      	  8 8888       	8 888888888888	8 888888888888 	8 8888         
	if (getNet().isClient())																	//	8 888888888P'  8 8888             .8`8. `88888.       `8.`8888.     	  8 8888       	8 8888         	8 8888         	8 8888         
	{ 																							//	8 8888         8 8888            .8' `8. `88888.       `8.`8888.    	  8 8888       	8 8888         	8 8888         	8 8888         
		Vec2f pos = map.getTileWorldPosition(index);											//	8 8888         8 8888           .8'   `8. `88888.  8b   `8.`8888.   	  8 8888       	8 8888         	8 8888         	8 8888         
																								//	8 8888         8 8888          .888888888. `88888. `8b.  ;8.`8888   	  8 8888       	8 8888         	8 8888         	8 8888         
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);											//	8 8888         8 888888888888 .8'       `8. `88888. `Y8888P ,88P'   	  8 8888       	8 888888888888 	8 888888888888 	8 888888888888 
	}																							//
}																								//
																								//
void OnPlasteelTileDestroyed(CMap@ map, u32 index)												//
{																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);										//
	}																							//
}																								//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void OnConcreteTileHit(CMap@ map, u32 index)													//
{																								//
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);										//
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );											//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
		for (int i = 0; i < 3; i++)																//
		{																						//
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);									//
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;//
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)					//
			: SColor(255, 110, 100, 93);														//
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);									//
		}																						//
		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 1.0f);							//
	}																							//
}																								//
																								//
void OnConcreteTileDestroyed(CMap@ map, u32 index)												//
{																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
		for (int i = 0; i < 15; i++)															//
		{																						//
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);									//
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;//
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)					//
			: SColor(255, 110, 100, 93);														//
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);									//
		}																						//
		ParticleAnimated("Smoke.png", pos+Vec2f(4, 0), 											//
		Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);												//
		Sound::Play("destroy_wall.ogg", pos, 1.0f, 1.0f);										//
	}																							//
}																								//
																								//
void concrete_SetTile(CMap@ map, Vec2f pos)														//	    ,o888888o.        ,o888888o.     b.             8     ,o888888o.    8 888888888o.   8 8888888888 8888888 8888888888 8 8888888888   
{																								//	   8888     `88.   . 8888     `88.   888o.          8    8888     `88.  8 8888    `88.  8 8888             8 8888       8 8888         
    map.SetTile(map.getTileOffset(pos), CMap::tile_concrete + concrete_GetMask(map, pos));		//	,8 8888       `8. ,8 8888       `8b  Y88888o.       8 ,8 8888       `8. 8 8888     `88  8 8888             8 8888       8 8888         
																								//	88 8888           88 8888        `8b .`Y888888o.    8 88 8888           8 8888     ,88  8 8888             8 8888       8 8888         
    for (u8 i = 0; i < 4; i++)																	//	88 8888           88 8888         88 8o. `Y888888o. 8 88 8888           8 8888.   ,88'  8 888888888888     8 8888       8 888888888888 
    {																							//	88 8888           88 8888         88 8`Y8o. `Y88888o8 88 8888           8 888888888P'   8 8888             8 8888       8 8888         
        concrete_Update(map, pos + directions[i]);												//	88 8888           88 8888        ,8P 8   `Y8o. `Y8888 88 8888           8 8888`8b       8 8888             8 8888       8 8888        
    }																							//	`8 8888       .8' `8 8888       ,8P  8      `Y8o. `Y8 `8 8888       .8' 8 8888 `8b.     8 8888             8 8888       8 8888         
}																								//	   8888     ,88'   ` 8888     ,88'   8         `Y8o.`    8888     ,88'  8 8888   `8b.   8 8888             8 8888       8 8888         
																								//	    `8888888P'        `8888888P'     8            `Yo     `8888888P'    8 8888     `88. 8 888888888888     8 8888       8 888888888888 
u8 concrete_GetMask(CMap@ map, Vec2f pos)														//
{																								//
    u8 mask = 0;																				//
																								//
    for (u8 i = 0; i < 4; i++)																	//
    {																							//
        if (isConcreteTile(map, pos + directions[i])) mask |= 1 << i;							//
    }																							//
																								//
    return mask;																				//
}																								//
																								//
void concrete_Update(CMap@ map, Vec2f pos)														//
{																								//
    u16 tile = map.getTile(pos).type;															//
    if (isConcreteTile(map, pos))																//
		map.SetTile(map.getTileOffset(pos),CMap::tile_concrete+concrete_GetMask(map,pos));		//
}																								//
																								//
bool isConcreteTile(CMap@ map, Vec2f pos)														//
{																								//
    u16 tile = map.getTile(pos).type;															//
    return tile >= CMap::tile_concrete && tile <= CMap::tile_concrete_v14;						//
}																								//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void tntsparks(Vec2f at)																		//
{																								//
	at += Vec2f(4, 0);																			//
	for (int i = 0; i < 15; i++)																//
	{																							//
		Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);										//
		vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;	//
		SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 196, 71, 30)						//
		: SColor(255, 142, 42, 9);																//
		ParticlePixel(at, vel, color, true);													//	8888888 8888888888 b.             8 8888888 8888888888
	}																							//	      8 8888       888o.          8       8 8888       
}																								//	      8 8888       Y88888o.       8       8 8888       
																								//	      8 8888       .`Y888888o.    8       8 8888       
void OnTNTTileHit(CMap@ map, u32 index, f32 damage, bool onfire)								//	      8 8888       8o. `Y888888o. 8       8 8888       
{																								//	      8 8888       8`Y8o. `Y88888o8       8 8888      
	map.AddTileFlag(index, Tile::BACKGROUND);													//	      8 8888       8   `Y8o. `Y8888       8 8888       
																								//	      8 8888       8      `Y8o. `Y8       8 8888       
	Vec2f pos = map.getTileWorldPosition(index);												//	      8 8888       8         `Y8o.`       8 8888       
	if(onfire || damage > 1.7f)																	//	      8 8888       8            `Yo       8 8888       
	{																							//
		map.server_SetTile(pos,CMap::tile_empty);												//
		map.SetTileNoise(index, 241);															//
		WorldExplode(pos, 60, 10);																//
	}																							//
	else																						//
	{																							//
		if (getNet().isClient())																//
		{																						//
			Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg",								//
				map.getTileWorldPosition(index), 1.0f, 1.0f);									//
			tntsparks(map.getTileWorldPosition(index));											//
		}																						//
	}																							//
}																								//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void OnMatterTileHit(CMap@ map, u32 index)														//
{																								//
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);										//
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);						//
																								//
	if (getNet().isClient())																	//
	{ 																							//
		Vec2f pos = map.getTileWorldPosition(index);											//
		mattersparks(pos, 5);																	//
		Sound::Play("dig_stone.ogg", pos, 0.8f, 1.2f);											//	    ,o888888o. 8888888 8888888888 8 8888        8 8 8888888888   8 888888888o.   
	}																							//	 . 8888     `88.     8 8888       8 8888        8 8 8888         8 8888    `88.  
}																								//	,8 8888       `8b    8 8888       8 8888        8 8 8888         8 8888     `88  
																								//	88 8888        `8b   8 8888       8 8888        8 8 8888         8 8888     ,88  
void OnBrickTileHit(CMap@ map, u32 index)														//	88 8888         88   8 8888       8 8888        8 8 888888888888 8 8888.   ,88'  
{																								//	88 8888         88   8 8888       8 8888        8 8 8888         8 888888888P'   
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);										//	88 8888        ,8P   8 8888       8 8888888888888 8 8888         8 8888`8b       
																								//	`8 8888       ,8P    8 8888       8 8888        8 8 8888         8 8888 `8b.     
	if (getNet().isClient())																	//	 ` 8888     ,88'     8 8888       8 8888        8 8 8888         8 8888   `8b.   
	{ 																							//	    `8888888P'       8 8888       8 8888        8 8 888888888888 8 8888     `88. 
		Vec2f pos = map.getTileWorldPosition(index);											//
																								//
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);											//
	}																							//
}																								//
																								//
const Vec2f[] directions = {	Vec2f(0, -8),													//
								Vec2f(0, 8),													//
								Vec2f(8, 0),													//
								Vec2f(-8, 0)};													//
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

void OnMatterTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		ParticleAnimated("MatterSmoke.png", pos+Vec2f(4, 4), Vec2f(0, -1), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_gold.ogg", pos, 0.8f, 1.2f);
	}
}

void mattersparks(Vec2f at, int amount)
{
	switch(XORRandom(4))
	{		
		case 1:
			at += Vec2f(4, 0);
			break;
		case 2:
			at += Vec2f(0, 4);
			break;
		case 3:
			at += Vec2f(8, 4);
			break;
		case 4:
			at += Vec2f(4, 8);
			break;
	}
	SColor[] colors = {	SColor(255, 34, 149, 42),	//greeny
						SColor(255, 255, 63, 202),	//purply
						SColor(255, 118, 218, 255),	//bluy
						SColor(255, 229, 179, 255),	//pinky
						SColor(255, 15, 20, 106),	//dark blue >:(
						SColor(255, 12, 69, 16)};	//dark green >:(
	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
		vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
		ParticlePixel(at, vel, colors[XORRandom(6)], true);
	}
}			









