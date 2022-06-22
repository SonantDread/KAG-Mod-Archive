#include "MakeMat.as";
#include "ParticleSparks.as";
#include "LoaderUtilities.as";

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (damage <= 0.0f) return;		

	CMap@ map = getMap();

	if (getNet().isClient())
	{
		TileType tile = map.getTile(worldPoint).type;
		// hit bedrock
		if (map.isTileBedrock(tile))
		{
			this.getSprite().PlaySound("/metal_stone.ogg", 0.7f, 1.0f);
			sparks(worldPoint, velocity.Angle(), damage);
		}
	}

	if (getNet().isServer())
	{
		TileType tile = map.getTile(worldPoint).type;

		map.server_DestroyTile(worldPoint, damage, this);

		f32 Multiplier = this.exists("mining_multiplier") ? this.get_f32("mining_multiplier") : 1.00f;
		
		f32 depth = 1 - ((worldPoint.y / 8) / map.tilemapheight);
		
		// print("" + depth);
		// print("Map height: " +  map.tilemapheight + "Y: " + worldPoint.y);
				
		if (map.isTileStone(tile))
		{
			if (map.isTileThickStone(tile)){
				MakeMat(this, worldPoint, "mat_stone", (10 + XORRandom(5)) * Multiplier);
				
				if (depth < 0.90f && XORRandom(100) < 70) MakeMat(this, worldPoint, "mat_copper", (1 + XORRandom(10 * (1 - depth))) * Multiplier);
				if (depth < 0.60f && XORRandom(100) < 60) MakeMat(this, worldPoint, "mat_iron", (5 + XORRandom(8)) * Multiplier);
				if (depth < 0.10f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_mithril", (2 + XORRandom(6)) * Multiplier);
				// if (depth < 0.20f && XORRandom(100) < 5) MakeMat(this, worldPoint, "mat_wilmet", (1 + XORRandom(3)) * Multiplier);
			} 
			else 
			{
				MakeMat(this, worldPoint, "mat_stone", (4 + XORRandom(4)) * Multiplier);
				if (depth > 0.40f && depth < 0.80f && XORRandom(100) < 50) MakeMat(this, worldPoint, "mat_copper", (2 + XORRandom(7 * (1 - depth))) * Multiplier);
				if (depth < 0.60f && XORRandom(100) < 30) MakeMat(this, worldPoint, "mat_iron", (3 + XORRandom(6)) * Multiplier);
			}
						
			// int chance = XORRandom(200);
			// print("" + chance);
						
			if (XORRandom(200) == 0) 
			{
				CBlob@[] blobs;
				getBlobsByName("methanefissure", @blobs);
				
				if (blobs.length < 8)
				{
					map.server_DestroyTile(worldPoint, 200, this);
					server_CreateBlob("methanedeposit", -1, worldPoint);
				}
			}
		}
		else if (map.isTileGold(tile))
		{
			MakeMat(this, worldPoint, "mat_gold", (2 + XORRandom(4)) * Multiplier);
			
			if (depth < 0.10f && XORRandom(100) < 35) MakeMat(this, worldPoint, "mat_mithril", (3 + XORRandom(8)) * Multiplier * (1.2f - depth));
			// if (depth < 0.20f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_wilmet", (1 + XORRandom(2)) * Multiplier * (1 - depth));
		}
		else if (map.isTileGround(tile))
		{
			// MakeMat(this, worldPoint, "mat_sand", 2 * Multiplier);
			MakeMat(this, worldPoint, "mat_dirt", (1 + XORRandom(3)) * Multiplier);
			if (depth < 0.80f && XORRandom(100) < 10) MakeMat(this, worldPoint, "mat_copper", (1 + XORRandom(3)) * Multiplier);
			if (depth < 0.35f && XORRandom(100) < 60 * (1 - depth)) MakeMat(this, worldPoint, "mat_sulphur", (1 + XORRandom(5)) * Multiplier * (1.3f - depth));
		}

		if (map.isTileSolid(tile))
		{
			if (map.isTileCastle(tile))
			{
				MakeMat(this, worldPoint, "mat_stone", 1);
			}
			else if (map.isTileWood(tile))
			{
				MakeMat(this, worldPoint, "mat_wood", 1);
			}
		}
	}
}
