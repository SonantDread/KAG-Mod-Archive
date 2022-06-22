#include "SplashWater.as";
#include "ShieldCommon.as";

bool isOwnerBlob(CBlob@ this, CBlob@ that)
{
	//easy check
	if (this.getDamageOwnerPlayer() is that.getPlayer())
		return true;

	if (!this.exists("explosive_parent")) { return false; }

	return (that.getNetworkID() == this.get_u16("explosive_parent"));
}
void makeSmallExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png",
	                 pos, Vec2f(0, 0.5f), 0.0f, 1.0f,
	                 3 + XORRandom(3),
	                 -0.1f, true);
}

void makeLargeExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/Explosion.png",
	                 pos, Vec2f(0, 0.5f), 0.0f, 1.0f,
	                 3 + XORRandom(3),
	                 -0.1f, true);
}

void Explode(CBlob@ this, f32 radius, f32 damage)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	f32 map_damage_radius = 0.0f;
	if (this.exists("map_damage_radius"))
	{
		map_damage_radius = this.get_f32("map_damage_radius");
	}

	f32 map_damage_ratio = 0.5f;

	if (this.exists("map_damage_ratio"))
	{
		map_damage_ratio = this.get_f32("map_damage_ratio");
	}

	bool map_damage_raycast = true;

	if (this.exists("map_damage_raycast"))
	{
		map_damage_raycast = this.get_bool("map_damage_raycast");
	}

	const bool bomberman = this.hasTag("bomberman_style");

	//actor damage
	u8 hitter = Hitters::explosion;

	if (this.exists("custom_hitter"))
	{
		hitter = this.get_u8("custom_hitter");
	}

	bool should_teamkill = this.exists("explosive_teamkill") && this.get_bool("explosive_teamkill");

	const int r = (radius * (2.0 / 3.0));

	if (hitter == Hitters::water)
	{
		int tilesr = (r / map.tilesize) * 0.5f;
		Splash(this, tilesr, tilesr, 0.0f);
		return;
	}

	//

	makeLargeExplosionParticle(pos);


	if (getNet().isServer())
	{
        Vec2f m_pos = (pos / map.tilesize);
        m_pos.x = Maths::Floor(m_pos.x);
        m_pos.y = Maths::Floor(m_pos.y);
        m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);

		//hit map if we're meant to
		if (map_damage_radius > 0.1f)
		{
			int tile_rad = int(map_damage_radius / map.tilesize) + 1;
			f32 rad_thresh = map_damage_radius * map_damage_ratio;

			//explode outwards
			for (int x_step = 0; x_step <= tile_rad; ++x_step)
			{
				for (int y_step = 0; y_step <= tile_rad; ++y_step)
				{
					Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);

					for (int i = 0; i < 4; i++)
					{
						if (i == 1)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						if (i == 2)
						{
							if (y_step == 0) { continue; }

							offset.y = -offset.y;
						}

						if (i == 3)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						f32 dist = offset.Length();

						if (dist < map_damage_radius)
						{
                            Vec2f tpos = m_pos + offset;
                            TileType tile = map.getTile(tpos).type;
                            if (tile == CMap::tile_empty)
                                continue;

							//do we need to raycast?
							bool canHit = !map_damage_raycast || (dist < 0.1f);

							if (!canHit)
							{
								Vec2f v = offset;
								v.Normalize();
								v = v * (dist - map.tilesize);
                                canHit = true;
                                HitInfo@[] hitInfos;
                                if(map.getHitInfosFromRay(m_pos, v.Angle(), v.Length(), this, hitInfos))
                                {
                                    for (int i = 0; i < hitInfos.length; i++)
                                    {
					if ( XORRandom(3) == 0){ makeSmallExplosionParticle(tpos); }
                                        HitInfo@ hi = hitInfos[i];
                                        CBlob@ b = hi.blob;
                                        // m_pos == position ignores blobs that are tiles when the explosion starts in the same tile
                                        if (b !is null && b !is this && b.isCollidable() && b.getShape().isStatic() && m_pos != b.getPosition())
                                        {
                                            if (b.isPlatform())
                                            {
                                                // bad but only handle one platform
                                                ShapePlatformDirection@ plat = b.getShape().getPlatformDirection(0);
                                                Vec2f dir = plat.direction;
                                                if (!plat.ignore_rotations)
                                                {
                                                    dir.RotateBy(b.getAngleDegrees());
                                                }

                                            
     
                                                continue;

                                            }
                                        }

                                        if(map.isTileSolid(hi.tile))
                                        {
                                            canHit = true;
                                            continue;
                                        }
                                    }

                                }
							}

							if (canHit)
							{
								if (canExplosionDamage(map, tpos, tile))
								{
									if (!map.isTileBedrock(tile))
									{
										if (dist >= rad_thresh ||
										        !canExplosionDestroy(map, tpos, tile))
										{
											map.server_DestroyTile(tpos, 1.0f, this);
										}
										else
										{
											map.server_DestroyTile(tpos, 100.0f, this);
										}
									}
								}
							}
						}
					}
				}
			}

			//end loops
		}

		//hit blobs
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, radius, @blobs);

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			if (hit_blob is this)
				continue;

			HitBlob(this, m_pos, hit_blob, radius, damage, hitter, false, should_teamkill);
		}
	}


}


bool canExplosionDamage(CMap@ map, Vec2f tpos, TileType t)
{
	CBlob@ blob = map.getBlobAtPosition(tpos); // TODO: make platform get detected
	bool hasValidFrontBlob = false;
	bool isBackwall = (t == CMap::tile_castle_back || t == CMap::tile_castle_back_moss || t == CMap::tile_wood_back);
	if (blob !is null)
	{
		string name = blob.getName();
		hasValidFrontBlob = (name == "wooden_door" || name == "stone_door" || name == "trap_block" || name == "wooden_platform" || name == "bridge");
	}
	return map.getSectorAtPosition(tpos, "no build") is null &&
	       (t != CMap::tile_ground_d0 && t != CMap::tile_stone_d0) && //don't _destroy_ ground, hit until its almost dead tho
		   !(hasValidFrontBlob && isBackwall); // don't destroy backwall if there is a door or trap block
}

bool canExplosionDestroy(CMap@ map, Vec2f tpos, TileType t)
{
	return !(map.isTileGroundStuff(t));
}

bool HitBlob(CBlob@ this, Vec2f mapPos, CBlob@ hit_blob, f32 radius, f32 damage, const u8 hitter,
             const bool bother_raycasting = true, const bool should_teamkill = false)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Vec2f hit_blob_pos = hit_blob.getPosition();
	Vec2f wall_hit;
	Vec2f hitvec = hit_blob_pos - pos;

	if (bother_raycasting) // have we already checked the rays?
	{
		// no wall in front

		if (map.rayCastSolidNoBlobs(pos, hit_blob_pos, wall_hit)) { return false; }

		// no blobs in front

		HitInfo@[] hitInfos;
		if (map.getHitInfosFromRay(pos, -hitvec.getAngle(), hitvec.getLength(), this, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob !is null) // blob
				{
                    // mapPos == position ignores blobs that are tiles when the explosion starts in the same tile
					if (hi.blob is this || hi.blob is hit_blob || !hi.blob.isCollidable() || mapPos == hi.blob.getPosition())
					{
						continue;
					}

                    CBlob@ b = hi.blob;
                    if (b.isPlatform())
                    {
                        ShapePlatformDirection@ plat = b.getShape().getPlatformDirection(0);
                        Vec2f dir = plat.direction;
                        if (!plat.ignore_rotations)
                        {
                            dir.RotateBy(b.getAngleDegrees());
                        }

                        // Does the platform block damage
                        Vec2f hitvec_dir = -hitvec;
                        if (hit_blob.isPlatform())
                        {
                            hitvec_dir = hitvec;
                        }

                        if(Maths::Abs(dir.AngleWith(hitvec_dir)) < plat.angleLimit)
                        {
                            return false;
                        }
                        continue;
                    }

					// only shield and heavy things block explosions
					if (hi.blob.hasTag("heavy weight") ||
					        hi.blob.getMass() > 500 || hi.blob.getShape().isStatic() ||
					        (hi.blob.hasTag("shielded") && blockAttack(hi.blob, hitvec, 0.0f)))
					{
						return false;
					}
				}
			}
		}
	}

	f32 scale;
	Vec2f bombforce = getBombForce(this, radius, hit_blob_pos, pos, hit_blob.getMass(), scale);
	f32 dam = damage * scale;

	//explosion particle
	makeSmallExplosionParticle(hit_blob_pos);

	//hit the object
	this.server_Hit(hit_blob, hit_blob_pos,
	                bombforce, dam,
	                hitter, hitter == Hitters::water || //hit with water
	                isOwnerBlob(this, hit_blob) ||	//allow selfkill with bombs
	                should_teamkill || hit_blob.hasTag("dead") || //hit all corpses ("dead" tag)
					hit_blob.hasTag("explosion always teamkill") // check for override with tag
	               );
	return true;
}
