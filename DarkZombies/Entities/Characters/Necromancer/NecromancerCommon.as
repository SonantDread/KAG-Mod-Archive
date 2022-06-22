//Necromancer Include

#include "BuildBlock.as";
#include "PlacementCommon.as";
#include "CheckSpam.as";
#include "GameplayEvents.as";
#include "Requirements.as";

const f32 allow_overlap = 2.0f;

shared class HitData
{
	u16 blobID;
	Vec2f tilepos;
};

Vec2f getBuildingOffsetPos(CBlob@ blob, CMap@ map, Vec2f required_tile_space)
{
	Vec2f halfSize = required_tile_space * 0.5f;

	Vec2f pos = blob.getPosition();
	pos.x = int(pos.x / map.tilesize);
	pos.x *= map.tilesize;
	pos.x += map.tilesize * 0.5f;

	pos.y -= required_tile_space.y * map.tilesize * 0.5f - map.tilesize;
	pos.y = int(pos.y / map.tilesize);
	pos.y *= map.tilesize;
	pos.y += map.tilesize * 0.5f;

	Vec2f offsetPos = pos - Vec2f(halfSize.x , halfSize.y) * map.tilesize;
	Vec2f alignedWorldPos = map.getAlignedWorldPos(offsetPos);
	return alignedWorldPos;
}

CBlob@ server_BuildBlob(CBlob@ this, BuildBlock[]@ blocks, uint index)
{
	if(index >= blocks.length)
	{
		return null;
	}

	this.set_u32("cant build time", 0);

	CInventory@ inv = this.getInventory();
	BuildBlock@ b = @blocks[index];

	this.set_TileType("buildtile", 0);

	CBlob@ anotherBlob = inv.getItem(b.name);
	if(getNet().isServer() && anotherBlob !is null)
	{
		this.server_Pickup(anotherBlob);
		this.set_u8("buildblob", 255);
		return null;
	}

	if(canBuild(this, blocks, index))
	{
		Vec2f pos = this.getPosition();

		if(b.buildOnGround)
		{
			const bool onground = this.isOnGround();

			bool fail = !onground;

			CMap@ map = getMap();

			Vec2f space = Vec2f(b.size.x / 8, b.size.y / 8);
			Vec2f offsetPos = getBuildingOffsetPos(this, map, space);

			if(!fail)
			{
				// check every tile space of the built blob for "no build sector" or "solid tile"
				for(f32 step_x = 0.0f; step_x < space.x ; ++step_x)
				{
					for(f32 step_y = 0.0f; step_y < space.y ; ++step_y)
					{
						Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
						Vec2f v = offsetPos + temp;
						if (map.getSectorAtPosition(v , "no build") !is null || map.isTileSolid(v))
						{
							fail = true;
							break;
						}
					}
				}
				// if we still havent failed
				// check if we're making a building
				// -> need to do some additional checking
				if(!fail && b.name == "building")
				{
					Vec2f tl = Vec2f(offsetPos.x, offsetPos.y);
					Vec2f br = Vec2f(offsetPos.x + b.size.x, offsetPos.y + b.size.y);

					Vec2f b_pos = Vec2f(tl.x + (b.size.x * 0.5f), tl.y + (b.size.y * 0.5f));
					Vec2f b_half = Vec2f(b.size.x, b.size.y) * 0.5f;

					CBlob@[] overlapping;
					map.getBlobsInBox(tl, br, @overlapping);
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ o_blob = overlapping[i];
						CShape@ o_shape = o_blob.getShape();
						if (o_blob !is null &&
						        o_shape !is null &&
						        !o_blob.isAttached() &&
						        o_shape.isStatic() &&
						        !o_shape.getVars().isladder)
						{
							//check if any of those blobs are overlapping
							Vec2f o_pos = o_blob.getPosition();
							Vec2f o_half = Vec2f(o_shape.getWidth(), o_shape.getHeight()) * 0.5f;
							Vec2f dif = Vec2f(Maths::Abs(o_pos.x - b_pos.x), Maths::Abs(o_pos.y - b_pos.y));
							Vec2f total = o_half + b_half;
							Vec2f sep = total - dif;
							if(sep.x > allow_overlap && sep.y > allow_overlap)
							{
								//check if they aren't on the ignore list
								//done here to avoid a bunch of string comp earlier
								string o_name = o_blob.getName();
								if(o_name != "bush" && !o_blob.hasTag("projectile"))
								{
									fail = true;
									break;
								}
							}
						}
					}
				}
			}

			if(fail)
			{
				if (this.isMyPlayer())
				{
					Sound::Play("/NoAmmo");
				}
				this.set_Vec2f("building space", space);
				this.set_u32("cant build time", getGameTime());
				return null;
			}

			pos = offsetPos + space * map.tilesize * 0.5f;

			this.getSprite().PlaySound("/Construct");
			// take inv here instead of in onDetach
			server_TakeRequirements(inv, b.reqs);
			SendGameplayEvent(createBuiltBlobEvent(this.getPlayer(), b.name));
		}

		if(getNet().isServer())
		{
			CBlob@ blockBlob = server_CreateBlob(b.name, this.getTeamNum(), pos);
			if (blockBlob !is null)
			{
				this.server_Pickup(blockBlob);
				this.set_u8("buildblob", index);
				if(b.temporaryBlob)
				{
					blockBlob.Tag("temp blob");
				}
				return blockBlob;
			}
		}
	}
	return null;
}

bool canBuild(CBlob@ this, BuildBlock[]@ blocks, uint index)
{
	if(index >= blocks.length)
	{
		return false;
	}

	BuildBlock@ block = @blocks[index];

	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if(bc is null)
	{
		return false;
	}

	bc.missing.Clear();
	bc.hasReqs = hasRequirements(this.getInventory(), block.reqs, bc.missing);

	return bc.hasReqs;
}

void ClearCarriedBlock(CBlob@ this)
{
	// clear variables
	this.set_u8("buildblob", 255);
	this.set_TileType("buildtile", 0);

	// remove carried block, if any
	CBlob@ carried = this.getCarriedBlob();
	if(carried !is null && carried.hasTag("temp blob"))
	{
		carried.Untag("temp blob");
		carried.server_Die();
	}
}

namespace SpellType
{
enum type
{
	summoning,
	other
};
}

shared class Spell
{
	string typeName;
	string name;
	string icon;
	u8 type;
	s32 mana;

	s32 fullChargeTime;
	s32 readyTime;
	s32 cooldownTime;


	s32 ready_time;

	s32 cast_period;
	s32 cast_period_1;
	s32 cast_period_2;
	s32 full_cast_period;

	bool needs_full;

	Spell(string i_typeName, string i_name, string i_icon, u8 i_type, s32 i_mana, s32 i_cast_period, s32 i_cooldownTime, bool fully_loaded = false)
	{
		typeName = i_typeName;
		name = i_name;
		icon = i_icon;
		type = i_type;
		mana = i_mana;
		cooldownTime = i_cooldownTime;

		cast_period = i_cast_period;
		cast_period_1 = cast_period/3;
		cast_period_2 = 2*cast_period/3;
		full_cast_period = cast_period*3;

		needs_full = fully_loaded;
	}
};

const string[] zombieTypes = {"Zombie", "Skeleton", "Wraith"};

namespace NecroParams
{
	enum Aim {
		not_aiming = 0,
		charging,
		cast_1,
		cast_2,
		cast_3,
		extra_ready,
		}

	const ::f32 shoot_max_vel = 8.0f;

	const ::Spell[] spells = {
		Spell("Skeleton", "Skeleton", "$Skeleton$", SpellType::summoning, 1, 15, 0, true),
		Spell("Zombie", "Zombie", "$Zombie$", SpellType::summoning, 4, 25, 30, true),
		Spell("Wraith", "Wraith", "$Wraith$", SpellType::summoning, 10, 40, 30, true),
		Spell("ZombieKnight", "Zombie Knight", "$ZK$", SpellType::summoning, 20, 100, 120, true),
		Spell("orb", "Orb", "$Orb$", SpellType::other, 2, 40, 120),
		Spell("zombie_rain", "Zombie Rain", "$ZombieRain$", SpellType::other, 40, 150, 240),
		Spell("teleport", "Teleportation", "$Teleport$", SpellType::other, 30, 10, 480, true),
		Spell("meteor_rain", "Meteor Rain", "$MeteorRain$", SpellType::other, 40, 180, 240),
		Spell("skeleton_rain", "Skeleton Rain", "$SkeletonRain$", SpellType::other, 20, 90, 120)
	};
}

shared class NecromancerInfo
{
	s32 charge_time;
	u8 charge_state;
	s32 mana;
	s32 maxMana;
	u8 fletch_cooldown;
	u8 primarySpellID;
	u8 secondarySpellID;

	NecromancerInfo()
	{
		charge_time = 0;
		charge_state = 0;
		maxMana = 100;
		mana = maxMana;
		fletch_cooldown = 0;
		primarySpellID = 1;
		secondarySpellID = 5;
	}
};

void SetPrimarySpell( CBlob@ this, const u8 id )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return;
	}
	necromancer.primarySpellID = id;
}

void SetSecondarySpell( CBlob@ this, const u8 id )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return;
	}
	necromancer.secondarySpellID = id;
}

u8 getPrimarySpellID( CBlob@ this )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return 0;
	}
	return necromancer.primarySpellID;
}

u8 getSecondarySpellID( CBlob@ this )
{
	NecromancerInfo@ necromancer;
	if (!this.get( "necromancerInfo", @necromancer ))
	{
		return 0;
	}
	return necromancer.secondarySpellID;
}
