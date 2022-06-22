
#include "Hitters.as"
#include "CustomBlocks.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f && (hitterBlob !is this || customData == Hitters::crush))  //sound for anything actually painful
	{
		f32 capped_damage = Maths::Min(damage, 2.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case Hitters::drown:
			case Hitters::burn:
			case Hitters::fire:
				showblood = false;
				break;

			case Hitters::sword:
				Sound::Play("SwordKill", this.getPosition());
				break;

			case Hitters::stab:
				if (this.getHealth() > 0.0f && damage > 2.0f)
				{
					this.Tag("cutthroat");
				}
				break;

			default:
				if (customData != Hitters::bite)
					Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;
	    //if(!CustomEmitEffectExists("Bloodcollide"))
	    //{ 
	    //    SetupCustomEmitEffect( "Bloodcollide", "FleshHitEffects.as", "BloodTiles", 10, 0, 120);
	    //    //SetupCustomEmitEffect( name, scriptfile, scriptfunction, u8 hard_freq, u8 chance_freq, u16 timeout )
	    //}
	     u8 emiteffect = GetCustomEmitEffectID("Bloodcollide");
		{
			if (capped_damage > 1.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 0.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				f32 angle = (velocity).Angle();

				for (f32 count = 0.0f ; count < capped_damage + 0.6f; count += 0.1f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * capped_damage * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * capped_damage;
 
					
					CParticle@ b1     = ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));

				    if(b1 !is null)
				    {
				    	b1.diesoncollide = true;
				    	if (XORRandom(3)==0)
				    	b1.AddDieFunction("FleshHitEffects.as", "BloodTiles");

				    }

				    CParticle@ b2     = ParticleBlood(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0));

				    if(b2 !is null)
				    {
				    	b2.diesoncollide = true;
				    	if (XORRandom(3)==0)
				    	b2.AddDieFunction("FleshHitEffects.as", "BloodTiles");
				    }
				}
			}
		}
	}

	return damage;
}

void BloodTiles(CParticle@ p)
{	
	CMap@ map = getMap();
	Vec2f tilepos = p.position;
	Vec2f tilespace = map.getTileSpacePosition(tilepos);
	int offset = map.getTileOffsetFromTileSpace(tilespace);
	TileType tile = map.getTile( offset ).type;
	TileType tilebelow = map.getTile( offset+map.tilemapwidth ).type;

	if ((tile >= CMap::tile_grass && tile <= CMap::tile_grass+3) || (tile >= CMap::tile_littlebloodgrass && tile <= CMap::tile_heapsbloodgrassground_d0))
	{
		switch(tile)
		{
			case CMap::tile_grass:   map.server_SetTile(tilepos, CMap::tile_littlebloodgrass);   map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_littlebloodgrassground);   break;
			case CMap::tile_grass+1: map.server_SetTile(tilepos, CMap::tile_littlebloodgrass+1); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_littlebloodgrassground_d0);   break;
			case CMap::tile_grass+2: map.server_SetTile(tilepos, CMap::tile_littlebloodgrass+2); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_littlebloodgrassground);   break;
			case CMap::tile_grass+3: map.server_SetTile(tilepos, CMap::tile_littlebloodgrass+3); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_littlebloodgrassground_d0);   break;

			case CMap::tile_littlebloodgrass:   map.server_SetTile(tilepos, CMap::tile_mediumbloodgrass);   map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_mediumbloodgrassground);   break;
			case CMap::tile_littlebloodgrass+1: map.server_SetTile(tilepos, CMap::tile_mediumbloodgrass+1); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_mediumbloodgrassground_d0);   break;
			case CMap::tile_littlebloodgrass+2: map.server_SetTile(tilepos, CMap::tile_mediumbloodgrass+2); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_mediumbloodgrassground);   break;
			case CMap::tile_littlebloodgrass+3: map.server_SetTile(tilepos, CMap::tile_mediumbloodgrass+3); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_mediumbloodgrassground_d0);   break;			

			case CMap::tile_mediumbloodgrass:   map.server_SetTile(tilepos, CMap::tile_heapsbloodgrass);   map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_heapsbloodgrassground);   break;
			case CMap::tile_mediumbloodgrass+1: map.server_SetTile(tilepos, CMap::tile_heapsbloodgrass+1); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_heapsbloodgrassground_d0);   break;
			case CMap::tile_mediumbloodgrass+2: map.server_SetTile(tilepos, CMap::tile_heapsbloodgrass+2); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_heapsbloodgrassground);   break;
			case CMap::tile_mediumbloodgrass+3: map.server_SetTile(tilepos, CMap::tile_heapsbloodgrass+3); map.server_SetTile(tilepos+Vec2f(0,8), CMap::tile_heapsbloodgrassground_d0);   break;
			
			
		}
	}	
 	else if (map.isTileGround(tilebelow) || (tilebelow >= CMap::tile_littlebloodground && tilebelow < CMap::tile_mediumbloodground_d3))
 	{	
 		const Vec2f offset(0,8);
 		switch(tilebelow)
		{ 		
			case CMap::tile_ground:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground);   break;
			case CMap::tile_ground+1:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground_d0); break;
			case CMap::tile_ground+2:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground);   break;
			case CMap::tile_ground+3:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground_d0); break;
			case CMap::tile_ground+4:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground);   break;
			case CMap::tile_ground+5:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground_d0); break;
			case CMap::tile_ground+6:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodground);   break;

			case CMap::tile_ground+7:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodgrassground);   break;
			case CMap::tile_ground+8:   map.server_SetTile(tilepos+offset, CMap::tile_littlebloodgrassground_d0); break;

			case CMap::tile_littlebloodground:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodground);   break;
			case CMap::tile_littlebloodground_d0:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodground_d0); break;
			case CMap::tile_littlebloodground_d1:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodground_d1); break;
			case CMap::tile_littlebloodground_d2:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodground_d2); break;
			case CMap::tile_littlebloodground_d3:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodground_d3); break;

			case CMap::tile_mediumbloodground:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodground);   break;
			case CMap::tile_mediumbloodground_d0:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodground_d0); break;
			case CMap::tile_mediumbloodground_d1:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodground_d1); break;
			case CMap::tile_mediumbloodground_d2:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodground_d2); break;
			case CMap::tile_mediumbloodground_d3:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodground_d3); break;

			case CMap::tile_littlebloodgrassground:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodgrassground);   break;
			case CMap::tile_littlebloodgrassground_d0:   map.server_SetTile(tilepos+offset, CMap::tile_mediumbloodgrassground_d0); break;

			case CMap::tile_mediumbloodgrassground:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodgrassground);   break;
			case CMap::tile_mediumbloodgrassground_d0:   map.server_SetTile(tilepos+offset, CMap::tile_heapsbloodgrassground_d0); break;
		}
 	}
}

