
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
		custom_start = 271,

		tile_goldbrick = 272,
		tile_goldbrick_d1 = 274,
		tile_goldbrick_d0 = 277,

		tile_ladder_n = 278,
		tile_ladder_ground_n = 279,
		tile_ladder_castle_n = 280,
		tile_ladder_wood_n = 281,

		tile_fake_dirt = 282,
		tile_fake_castle = 283,
		tile_fake_wood = 284,
		tile_fake_goldbrick = 285,
	};
};

namespace map_colors
{
	enum CustomColor
	{
		tile_goldbrick		= 0xFFEAB127,
		tile_ladder			= 0xFF633610,
		tile_ladder_ground	= 0xFF512C0D,
		tile_ladder_castle	= 0xFF432F11,
		tile_ladder_wood	= 0xFF453911,
		tile_fake_dirt		= 0xFF703911,
		tile_fake_castle	= 0xFF515B4E,
		tile_fake_wood		= 0xFFA87312,
		tile_fake_goldbrick	= 0xFF9E761A
	}
}

//const f32 FULL_DAMAGE = 10.0f;

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	switch (pixel.color)
	{
		case map_colors::tile_goldbrick:		map.SetTile(offset, CMap::tile_goldbrick);			break;
		case map_colors::tile_ladder:			map.SetTile(offset, CMap::tile_ladder_n);			break;
		case map_colors::tile_ladder_ground:	map.SetTile(offset, CMap::tile_ladder_ground_n);	break;
		case map_colors::tile_ladder_castle:	map.SetTile(offset, CMap::tile_ladder_castle_n);	break;
		case map_colors::tile_ladder_wood:		map.SetTile(offset, CMap::tile_ladder_wood_n);		break;
		case map_colors::tile_fake_dirt:		map.SetTile(offset, CMap::tile_fake_dirt);			break;
		case map_colors::tile_fake_castle:		map.SetTile(offset, CMap::tile_fake_castle);		break;
		case map_colors::tile_fake_wood:		map.SetTile(offset, CMap::tile_fake_wood);			break;
		case map_colors::tile_fake_goldbrick:	map.SetTile(offset, CMap::tile_fake_goldbrick);		break;
		default:	break;
	};
}

namespace TileParticles
{
	SColor[] gold = {0xFFFFD67D, 0xFFEAB127, 0xFFEAB127, 0xFF844715, 0xFF552A11};
	SColor[] castle = {0xFFC4CFA1, 0xFF97A792, 0xFF7E8C79, 0xFF647160, 0xFF4F583A};
	SColor[] dirt = {0xFF844715, 0xFF552A11, 0xFF3B1406, 0xFF211912, 0xFF9F6125};
	SColor[] wood = {0xFFC4873A, 0xFF9F6125, 0xFF844715, 0xFF552A11, 0xFF3B1406};

	void Gold(Vec2f pos, bool hit_or_break) // true - hit
	{
		int amount = hit_or_break ? 8 : 18;
		Vec2f tile_half = Vec2f(getMap().tilesize/2, getMap().tilesize/2);
		Vec2f mid = pos + tile_half;
		for(int i = 0; i < amount; i++)
		{
			Vec2f side = Vec2f(((XORRandom(2) == 1) ? -1 : 1)*tile_half.x, ((XORRandom(2) == 1) ? -1 : 1)*tile_half.y);
			Vec2f particle_pos = mid+side;
			ParticlePixel(particle_pos, (particle_pos-mid)*(0.8*(float(XORRandom(20)+10)/35.0f)), gold[XORRandom(gold.size())], false);
		}
	}
	void Castle(Vec2f pos, bool hit_or_break) // true - hit
	{
		int amount = hit_or_break ? 8 : 18;
		Vec2f tile_half = Vec2f(getMap().tilesize/2, getMap().tilesize/2);
		Vec2f mid = pos + tile_half;
		for(int i = 0; i < amount; i++)
		{
			Vec2f side = Vec2f(((XORRandom(2) == 1) ? -1 : 1)*tile_half.x, ((XORRandom(2) == 1) ? -1 : 1)*tile_half.y);
			Vec2f particle_pos = mid+side;
			ParticlePixel(particle_pos, (particle_pos-mid)*(0.8*(float(XORRandom(20)+10)/35.0f)), castle[XORRandom(castle.size())], false);
		}
	}
	void Dirt(Vec2f pos, bool hit_or_break) // true - hit
	{
		int amount = hit_or_break ? 8 : 18;
		Vec2f tile_half = Vec2f(getMap().tilesize/2, getMap().tilesize/2);
		Vec2f mid = pos + tile_half;
		for(int i = 0; i < amount; i++)
		{
			Vec2f side = Vec2f(((XORRandom(2) == 1) ? -1 : 1)*tile_half.x, ((XORRandom(2) == 1) ? -1 : 1)*tile_half.y);
			Vec2f particle_pos = mid+side;
			ParticlePixel(particle_pos, (particle_pos-mid)*(0.8*(float(XORRandom(20)+10)/35.0f)), dirt[XORRandom(dirt.size())], false);
		}
	}
	void Wood(Vec2f pos, bool hit_or_break) // true - hit
	{
		int amount = hit_or_break ? 8 : 18;
		Vec2f tile_half = Vec2f(getMap().tilesize/2, getMap().tilesize/2);
		Vec2f mid = pos + tile_half;
		for(int i = 0; i < amount; i++)
		{
			Vec2f side = Vec2f(((XORRandom(2) == 1) ? -1 : 1)*tile_half.x, ((XORRandom(2) == 1) ? -1 : 1)*tile_half.y);
			Vec2f particle_pos = mid+side;
			ParticlePixel(particle_pos, (particle_pos-mid)*(0.8*(float(XORRandom(20)+10)/35.0f)), wood[XORRandom(wood.size())], false);
		}
	}
}