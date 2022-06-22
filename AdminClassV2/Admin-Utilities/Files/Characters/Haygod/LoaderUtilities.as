// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
//#include "BasePNGLoader.as";
#include "CustomBlocks.as";


/*namespace zplace_colors
{
	enum color
	{

		color_steel = 0xff5f5f5f,
		color_dark = 0xffadaa96,
	};
}

	void handlePixel(const SColor &in pixel, int offset) override
	{

		PNGLoader::handlePixel(pixel, offset);
switch (pixel.color)
	{
			

		case zplace_colors::color_steel:
		{
			map.SetTile(offset, CMap::tile_steel);
			break;
		}
		case zplace_colors::color_steel:
		{
			map.SetTile(offset, CMap::tile_dark_castle_block);
			break;
		}
	}
}*/






const SColor c_white = SColor(255, 255, 255, 255);
const SColor c_black = SColor(255, 0, 0, 0);
const SColor c_missing = SColor(255, 255, 0, 255);

const SColor c_sky = SColor(255, 111, 216, 122);

const SColor c_sky_top = SColor(0xff39cede);
const SColor c_sky_bottom = SColor(0xffcaa58a);

const SColor c_dirt = SColor(255, 69, 39, 31);
const SColor c_dirt_bg = SColor(255, 115, 87, 49);
const SColor c_stone = SColor(255, 164, 145, 68);
const SColor c_thickStone = SColor(255, 114, 111, 107);
const SColor c_bedrock = SColor(255, 51, 58, 65);
const SColor c_gold = SColor(255, 231, 171, 40);

const SColor c_castle = SColor(0xff424242);
const SColor c_castle_moss = SColor(0xff2d322e);
const SColor c_wood = SColor(0xff713919);
const SColor c_grass = SColor(0xff6CCA01);
const SColor color_minimap_gold         (0xffffbd34);



SColor[] fire_colors =
{
	SColor(0xfff3ac5c),
	SColor(0xffdb5743),
	SColor(0xff7e3041)
};

void CalculateMinimapColour(CMap@ this, u32 offset, TileType type, SColor &out col)
{
	const int w = this.tilemapwidth;
	const int h = this.tilemapheight;

	const int x = offset % w;
	const int y = offset / w;
	const Vec2f pos = Vec2f(x * 8, y * 8);

	const f32 heightGradient = y / f32(h);

	const Tile tile = this.getTile(offset);

	bool air = type == CMap::tile_empty;

	const u8 flags = tile.flags;
	bool bg = flags & Tile::BACKGROUND != 0;
	bool solid = flags & Tile::SOLID != 0;

	// if (this.isTileGround(tile) || this.isTileStone(tile) || this.isTileBedrock(tile) || this.isTileGold(tile) || this.isTileThickStone(tile) || this.isTileCastle(tile) || this.isTileWood(tile))

	if (!air)
	{
		TileType l = this.getTile(offset - 1).type;
		TileType r = this.getTile(offset + 1).type;
		TileType u = this.getTile(offset - w).type;
		TileType d = this.getTile(offset + w).type;

		// TODO: Shove damage frame numbers into an enum
		switch(type)
		{
			// DIRT
			case CMap::tile_ground:
			case CMap::tile_ground_d1:
			case 30:
			case CMap::tile_ground_d0:
				col = c_dirt;
				if (this.isTileGrass(u))
				{
					col = col.getInterpolated(c_grass, 0.50f);
				}
			break;

			// DIRT BACKGROUND
			case CMap::tile_ground_back:
				col = c_dirt_bg;
				//col = col.getInterpolated(c_dirt, heightGradient);
			break;

			// THICKSTONE
			case CMap::tile_thickstone:
			case CMap::tile_thickstone_d1:
			case 215:
			case 216: // OTHER DAMAGE FRAMES
			case 217:
			case CMap::tile_thickstone_d0:
				col = c_thickStone;
			break;

			// STONE
			case CMap::tile_stone:
			case CMap::tile_stone_d1:
			case 101:
			case 102:
			case 103:
			case CMap::tile_stone_d0:
				col = c_stone;
			break;

			// BEDROCK
			case CMap::tile_bedrock:
				col = c_bedrock;
			break;

			// GOLD
			case CMap::tile_gold:
			case 90:
			case 92:
			case 93:
			case 94:
				col = c_thickStone;
			break;

			// MOSS
			case CMap::tile_castle_moss:
			case 225:
			case 226:
			case 227:
			case 228:
			case 229:
			case 230:
			case 231:
			case 232:
			case 233:
			case 234:
			case 235:
			case 236:
			case 237:
			case 238:
			case 239:
			case 340:
				col = c_castle_moss;
			break;

			// CASTLE
			case CMap::tile_castle:
			case CMap::tile_castle_d1:
			case 59:
			case 60:
			case 61:
			case 62:
			case CMap::tile_castle_d0:
			case 64:
			case 65:
			case 66:
			case 67:
			case 68:
			case 69:
			case 70:
			case 71:
			case 72:
			case 73:
			case 74:
			case 75:
			case 76:
			case 77:
			case 78:
			case 79:
				col = c_castle;
			break;

			// WOOD
			case CMap::tile_wood:
			case 199:
			case CMap::tile_wood_d1:
			case 201:
			case 202:
			case CMap::tile_wood_d0:
			case CMap::tile_wood_back:
			case 206:
			case 207:
				col = c_wood;
			break;

			// GRASS
			case CMap::tile_grass:
			case 26:
			case 27:
			case 28:
				col = c_grass;
				col = col.getInterpolated(c_white, (x % 2) * 1.00f);
			break;


		}


		if (!solid)
		{
			col = col.getInterpolated(c_white, 0.85f);
			if (l == CMap::tile_empty || r == CMap::tile_empty || u == CMap::tile_empty || d == CMap::tile_empty) col = col.getInterpolated(c_black, 0.70f);
			// else
			// {
				// col = col.getInterpolated(c_black, 1.00f - ((x + y) % 2) * 0.10f);
			// }
		}
		else if (!this.isTileSolid(l) || !this.isTileSolid(r) || !this.isTileSolid(u) || !this.isTileSolid(d))
		{
			col = col.getInterpolated(c_black, 0.70f);
		}

		col = col.getInterpolated(c_white, 1.00f - ((1.00f - heightGradient) * 0.25f));
	}
	else
	{
		// col = c_sky;
		col = c_sky_bottom;
		col = col.getInterpolated(c_sky_top, heightGradient);
		col = col.getInterpolated(c_sky, 0.75f);
	}

	if (this.isInWater(pos)) col = col.getInterpolated(SColor(0xff1d85ab), 0.5f);
	// if (this.isTileInFire(x, y)) col = col.getInterpolated(fire_colors[XORRandom(fire_colors.length)], 0.5f);
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
		/*if(map.getTile(offset).type == CMap::tile_matter)
		{
			CBitStream params;
			params.write_Vec2f(map.getTileWorldPosition(offset));
			rules.SendCommand(rules.getCommandID("remove_tile"), params);
		}*/
	}

	// print("collapse");

	return true;
}


TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{	
			//STEEL BRICK
			case CMap::tile_steel: {OnSteelTileHit(map, index); return CMap::tile_steel_d0;}		
			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4: {OnSteelTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_steel_d5: { OnSteelTileDestroyed(map, index); return CMap::tile_empty;}

			// MOSSY WOOD
			case CMap::tile_mossy_wood: {OnWoodTileHit(map, index); return CMap::tile_mossy_wood_d0;}		
			case CMap::tile_mossy_wood_d0:
			case CMap::tile_mossy_wood_d1:
			case CMap::tile_mossy_wood_d2:
			case CMap::tile_mossy_wood_d3: {OnWoodTileHit(map, index); return oldTileType + 1;}
			case CMap::tile_mossy_wood_d4: { OnWoodTileDestroyed(map, index); return CMap::tile_empty;}				

			//CASTLE GOLD BLOCK
			case CMap::tile_castle_gold: {OnGoldTileHit(map, index); return CMap::tile_castle_gold_d0;}		
			case CMap::tile_castle_gold_d0:
			case CMap::tile_castle_gold_d1:
			case CMap::tile_castle_gold_d2:
			case CMap::tile_castle_gold_d3:
			case CMap::tile_castle_gold_d4: {OnGoldTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_castle_gold_d5: { OnGoldTileDestroyed(map, index); return CMap::tile_empty;} 
			
			
			//CASTLE GOLD BLOCK
			case CMap::tile_birk_godl: {OnGoldTileHit(map, index); return CMap::tile_birk_godl_d0;}		
			case CMap::tile_birk_godl_d0:
			case CMap::tile_birk_godl_d1:
			case CMap::tile_birk_godl_d2: {OnGoldTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_birk_godl_d3: { OnGoldTileDestroyed(map, index); return CMap::tile_empty;}
			
			//DARK CASTLE BLOCK
			case CMap::tile_dark_castle_block: {OnSteelTileHit(map, index); return CMap::tile_dark_castle_block_d0;}		
			case CMap::tile_dark_castle_block_d0:
			case CMap::tile_dark_castle_block_d1:
			case CMap::tile_dark_castle_block_d2:
			case CMap::tile_dark_castle_block_d3:
			case CMap::tile_dark_castle_block_d4: {OnSteelTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_dark_castle_block_d5: { OnSteelTileDestroyed(map, index); return CMap::tile_empty;}
			
			// SANDEWEL
			case CMap::tile_sandewel: {OnGoldTileHit(map, index); return CMap::tile_sandewel_d0;}		
			case CMap::tile_sandewel_d0:
			case CMap::tile_sandewel_d1:
			case CMap::tile_sandewel_d2: {OnGoldTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_sandewel_d3: { OnGoldTileDestroyed(map, index); return CMap::tile_empty;}
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	//switch(tile_new)
	//{
	//	case CMap::tile_empty:
	//	map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
	//	break;
	//}

	if (map.getTile(index).type == 23 || map.getTile(index).type == 24) //grassy ground not updating properly
	{
		map.SetTileSupport(index, 10);
		{
			map.RemoveTileFlag( index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
			map.AddTileFlag( index, Tile::SOLID | Tile::COLLISION );
			
			if(XORRandom(2) == 0)
			map.AddTileFlag( index, Tile::MIRROR );
		}
	}

	if (map.getTile(index).type > 255) //custom solids
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			// steel brick
			case CMap::tile_steel:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3: 
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}			
			// mossy wood
			case CMap::tile_mossy_wood:
			{
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
				if (getNet().isClient()) Sound::Play("build_wood.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_mossy_wood_d0:
			case CMap::tile_mossy_wood_d1:
			case CMap::tile_mossy_wood_d2:
			case CMap::tile_mossy_wood_d3:
			case CMap::tile_mossy_wood_d4:
			{
				OnWoodTileHit(map, index);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
				break;
			}	

			//CASTLE GOLD BLOCK
			case CMap::tile_castle_gold:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_castle_gold_d0:
			case CMap::tile_castle_gold_d1:
			case CMap::tile_castle_gold_d2:
			case CMap::tile_castle_gold_d3: 
			case CMap::tile_castle_gold_d4:
			case CMap::tile_castle_gold_d5:
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}
			
			// gold brick
			case CMap::tile_birk_godl:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_birk_godl_d0:
			case CMap::tile_birk_godl_d1:
			case CMap::tile_birk_godl_d2:
			case CMap::tile_birk_godl_d3: 
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}	

			// DARK CASTLE BLOCK
			case CMap::tile_dark_castle_block:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_dark_castle_block_d0:
			case CMap::tile_dark_castle_block_d1:
			case CMap::tile_dark_castle_block_d2:
			case CMap::tile_dark_castle_block_d3: 
			case CMap::tile_dark_castle_block_d4:
			case CMap::tile_dark_castle_block_d5:
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}
			
			// SANDEWEL
			case CMap::tile_sandewel:
			{
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_sandewel_d0:
			case CMap::tile_sandewel_d1:
			case CMap::tile_sandewel_d2:
			case CMap::tile_sandewel_d3: 
			{
				OnGoldTileHit(map, index);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			}

			
		}
	}
	
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
}

void OnGoldTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		goldtilesparks(pos, -180+XORRandom(180), 1.0f);
	
		Sound::Play("dig_stone1.ogg", pos, 0.5f, 0.5f+(XORRandom(10)*0.002));
	}
}

void OnGoldTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_stone.ogg", pos, 0.5f, 0.5f+(XORRandom(10)*0.002));
	}
}

void OnWoodTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::FLAMMABLE);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND);
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		woodtilesparks(pos, -180+XORRandom(180), 1.0f);
	
		Sound::Play("WoodHit"+ (XORRandom(3) + 1)+".ogg", pos, 0.5f, 1.0f);
	}
}

void OnWoodTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_wood"+ (XORRandom(3) + 1)+".ogg", pos, 0.5f, 1.0f);
		
	}
}

void OnSteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		steeltilesparks(pos, -180+XORRandom(180), 1.0f);
	
		Sound::Play("dig_stone"+ (XORRandom(3) + 1)+".ogg", pos, 0.5f, 1.0f);
	}
}

void OnSteelTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_stone"+ (XORRandom(3) + 1)+".ogg", pos, 0.5f, 1.0f);
	}
}