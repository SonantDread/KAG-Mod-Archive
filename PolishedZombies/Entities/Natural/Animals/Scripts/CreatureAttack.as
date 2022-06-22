#include "Hitters.as";
#include "KnockedCommon.as";

void onInit(CBlob@ this)
{
	if (!this.exists("attack frequency"))
		this.set_u8("attack frequency", 30);

	if (!this.exists("attack distance"))
		this.set_f32("attack distance", 0.5f);

	if (!this.exists("attack damage"))
		this.set_f32("attack damage", 1.0f);

	if (!this.exists("attack hitter"))
		this.set_u8("attack hitter", Hitters::bite);

	if (!this.exists("attack sound"))
		this.set_string("attack sound", "ZombieBite");

	if (!this.exists("block hit chance"))
		this.set_u16("block hit chance", 10);

	this.getCurrentScript().removeIfTag	= "dead";
}

void onTick(CBlob@ this)
{
	if (!getNet().isServer())
		return;

	if (isKnocked(this))
		return;

	if (getGameTime() >= this.get_u32("next_attack"))
	{
		Vec2f pos = this.getPosition();
		f32 radius = this.getRadius();
		f32 attack_distance = radius + this.get_f32("attack distance") + 0.25f;
		CMap@ map = this.getMap();
		f32 aimangle = (this.getAimPos() - pos).Angle();

		
		HitInfo@[] hitInfos;

		if (map.getHitInfosFromArc(pos, aimangle, 135.0f, radius + attack_distance, this, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ blob = hi.blob;
				if (blob !is null && (blob.getTeamNum() != this.getTeamNum() || this.hasTag("starving")))
				{
					Vec2f hitvel = Vec2f(this.isFacingLeft() ? -1.0 : 1.0, 0.0f);
					
					this.server_Hit(blob, blob.getPosition(), hitvel, this.get_f32("attack damage"), this.get_u8("attack hitter"), true);
				}
				else
				{
					int chance = XORRandom(this.get_u16("block hit chance"));
					int prob = getRules().get_u8("day_number") / 5;
					
					if(prob < 0)
						prob = 0;

					if(chance <= prob)
					{
						TileType tile = hi.tile;
						if (tile != CMap::tile_bedrock)
						{
							Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
							Vec2f offset = (tpos - pos);
							f32 tileangle = offset.Angle();
							f32 dif = Maths::Abs(aimangle - tileangle);
							if (dif > 180)
								dif -= 360;
							if (dif < -180)
								dif += 360;

							dif = Maths::Abs(dif);

							if (dif < 20.0f)
							{
								int check_x = -(offset.x > 0 ? -1 : 1);
								int check_y = -(offset.y > 0 ? -1 : 1);
								if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
								        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
									continue;

								map.server_DestroyTile(hi.hitpos, this.get_f32("attack damage") * 0.1, this);
							}
						}
					}
				}
			}
		}

		if (aimangle >= 0.0f && aimangle <= 180.0f)
		{
			f32 tilesize = map.tilesize;
			int steps = Maths::Ceil(2 * radius / tilesize);
			int sign = this.isFacingLeft() ? -1 : 1;

			for (int y = 0; y < steps; y++)
			{
				for (int x = 0; x < steps; x++)
				{
					Vec2f tilepos = pos + Vec2f(x * tilesize * sign, y * tilesize);
					TileType tile = map.getTile(tilepos).type;

					if (map.isTileGrass(tile))
					{
						map.server_DestroyTile(tilepos, this.get_f32("attack damage") * 0.3, this);
					}
				}
			}
		}

		u8 attackfreq = this.get_u8("attack frequency");

		if(this.hasTag("starving"))
			attackfreq = 25;

		this.set_u32("next_attack", getGameTime() + attackfreq);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (this.hasTag("starving") && hitBlob.hasTag("flesh"))
	{
		this.set_f32("hunger level", this.get_f32("hunger level") + 40);
	}

	if (damage > 0.0f)
	{
		this.getSprite().PlayRandomSound(this.get_string("attack sound"));
	}
}