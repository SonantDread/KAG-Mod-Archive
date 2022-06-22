
// CRules property defaults

namespace FlagZone
{
	const u16 COOLDOWN = 60; // seconds between zone expansions
	const s16 MAX_EXPANDS = 15; // maximum expansion triggers

	const u16 MAX_CHECKS = -1; // max tile checks per tick, for performance if necessary
	const u8 SHRED_TICKRATE = 5; // ticks between tile shreds
	const u8 NORMAL_TICKRATE = 30;

	// CRules properties controlling sudden death flags
	const string RULES_COOLDOWN = "flagzone_cooldown";		// u16 - seconds between expands
	const string RULES_MAX_TIMES = "flagzone_max_expands";	// u8 - if 255 or nonexistent, infinite
}


void server_ToggleSuddenDeathFlags()
{
	if (!isServer()) return;

	if (isSuddenDeath(getRules()))
		server_StopSuddenDeathFlags();
	else
		server_StartSuddenDeathFlags();
}

// Stop all flagzones from expanding on cooldown
void server_StopSuddenDeathFlags()
{
	if (!isServer()) return;

	CBlob@[] flags;
	if (getBlobsByName("flag_base", @flags))
	{
		for (int i = 0; i < flags.length; i++)
		{
			StopAutoExpanding(flags[i]);
		}
	}
}

// Have all (mirrored) flagzones start expanding on cooldown
void server_StartSuddenDeathFlags(bool only_mirrored_flags = true)
{
	if (!isServer()) return;

	CBlob@[] flags;
	if (getBlobsByName("flag_base", @flags))
	{
		// Figure out which flags are matched
		for (int i = 0; i < flags.length; ++i)
		{
			CBlob@ flag = flags[i];
			bool activate_flag = true;
			if (only_mirrored_flags)
			{
				activate_flag = (getOppositeFlag(flag, getMap()) !is null);
			}

			if (activate_flag)
			{
				StartAutoExpanding(flag);
			}
		}
	}
}

bool isSuddenDeath(CRules@ this)
{
	return getRules().hasTag("sudden_death_flags");
}


// Flagbase blob functions ------------------------------------------------------------------------

// -change from upperleft, +change to lowerright of zone (in blocks, works kinda weird with halves)
void ExpandFlagZone(CBlob@ this, bool shred = true, Vec2f upperleft_change = Vec2f(1, 1),
													Vec2f lowerright_change = Vec2f(1, 1))
{
	CMap@ map = this.getMap();

	CMap::Sector@ zone = getMyZone(this, map);
	if (zone is null)
	{
		// Reset zone
		@zone = ResetFlagZone(this, map);
		return;
	}

	// Make sure shred is over before expanding
	while (this.hasTag("shred_zone"))
		ZoneNextTile(this);

	// Replace the "no build" zone with another type that allows breaking
	// zone.name = "no_build_new"; // This doesn't work idk why
	bool new_type = false;
	if (zone.name == "no build")
	{
		new_type = true;
		@zone = map.server_AddSector(zone.upperleft, zone.lowerright,
									 "no_build_new", "", zone.ownerID);
	}

	CBitStream params;
	params.write_Vec2f(upperleft_change * 8);
	params.write_Vec2f(lowerright_change * 8);
	params.write_bool(new_type);
	this.SendCommand(this.getCommandID("update_zone"), params);
	this.add_u8("expand_count", 1);

	if (shred && getNet().isServer())
		StartZoneShred(this);
}

// Shrink a zone by 1 block in all directions
void ShrinkFlagZone(CBlob@ this, int times = 1)
{
	ExpandFlagZone(this, false, Vec2f(-1, -1) * times, Vec2f(-1, -1) * times);
}

// Have this flagzone start expanding on cooldown
void StartAutoExpanding(CBlob@ this)
{
	IncreaseActiveFlagCount(this);

	this.Tag("tick_zone");
	this.Tag("auto_zone");
	this.set_u8("expand_count", 0);
	this.set_u32("time_to_expand", getGameTime());
}

// Stop this flagzone from expanding on cooldown
void StopAutoExpanding(CBlob@ this)
{
	DecreaseActiveFlagCount(this);

	this.Untag("auto_zone");
	if (!this.hasTag("shred_zone"))
		this.Untag("tick_zone");
	// otherwise it will untag after zone goes brrt
}

// Resets to the basic flag zone and returns it
CMap::Sector@ ResetFlagZone(CBlob@ this, CMap@ map)
{
	Vec2f pos = this.getPosition();

	while (this.hasTag("shred_zone"))
		ZoneNextTile(this);
	StopAutoExpanding(this);

	// Remove the dynamic flag zone
	this.SendCommand(this.getCommandID("remove_zone"));

	CMap::Sector@ zone = getMyZone(this, map);
	if (zone !is null) return zone;

	// Add the basic flag zone
	@zone = map.server_AddSector(pos + Vec2f(-12, -32), pos + Vec2f(12, 16),
								"no build", "", this.getNetworkID());
	for (int x = -12; x < 12; x += 8)
	{
		for (int y = -32; y < 8; y += 8)
		{
			map.server_SetTile(pos + Vec2f(x, y), CMap::tile_empty);
		}
	}
	return zone;
}


// Internal functions -----------------------------------------------------------------------------

// Check and decrease rules' active (autoexpanding) flag count if necessary
void DecreaseActiveFlagCount(CBlob@ this)
{
	if (this.hasTag("auto_zone"))
	{
		CRules@ rules = getRules();
		if (rules.exists("active_flag_count"))
		{
			rules.add_u8("active_flag_count", -1);
			// print("-1 -> " + getRules().get_u8("active_flag_count"));
			if (rules.get_u8("active_flag_count") == 0)
			{
				// print("That's the last of em...");
				rules.Untag("sudden_death_flags");
			}
		}
	}
}

// Check and increase rules' active (autoexpanding) flag count if necessary
void IncreaseActiveFlagCount(CBlob@ this)
{
	CRules@ rules = getRules();
	rules.Tag("sudden_death_flags");
	if (!this.hasTag("auto_zone"))
	{
		if (!rules.exists("active_flag_count"))
		{
			rules.set_u8("active_flag_count", 1);
		}
		else
		{
			rules.add_u8("active_flag_count", 1);
		}
		// print("+1 -> " + getRules().get_u8("active_flag_count"));
	}
}

// Setup zone to begin breaking tiles at zone edges over time
void StartZoneShred(CBlob@ this)
{
	this.set_u16("tiles_zoned", 0);
	this.Tag("tick_zone");
	this.Tag("shred_zone");
	this.Tag("use_shred_tickrate");
}

// Try to find + shred the next tile (when the zone is going brrt)
void ZoneNextTile(CBlob@ this)
{
	if (getNet().isServer())
	{
		CMap@ map = this.getMap();
		CMap::Sector@ zone = getMyZone(this, map);

		// Find and shred next tile
		u16 tiles_checked = 0;
		while (this.hasTag("shred_zone") && tiles_checked < FlagZone::MAX_CHECKS)
		{
			Vec2f ul = zone.upperleft;
			Vec2f lr = zone.lowerright;

			Vec2f target_pos((lr.x + ul.x)/2, ul.y); // start at center top

			ul /= 8;
			lr /= 8;
			lr.x--;
			lr.y--;

			u16 width = lr.x - ul.x + 1;
			u16 height = lr.y - ul.y + 1;
			u16 num_blocks = width * 2 + height * 2 - 4;

			int i = this.get_u16("tiles_zoned");

			// next tile in pattern - alternate left/right, go from top to bottom
			Vec2f delta_pos();
			if (i < width) // top
			{
				delta_pos.x += (i % 2 == 0 ? 1 : -1) * (i+1)/2;
			}
			else if (i < width + 2*height - 2) // sides
			{
				delta_pos.x = (i % 2 == 1 ? -width/2 : width/2);
				delta_pos.y += (i-width+2)/2;
			}
			else // bottom
			{
				delta_pos.y = height-1;
				delta_pos.x += (i % 2 == 0 ? 1 : -1) * (num_blocks-i)/2;
			}

			i++;

			if (i >= num_blocks) // End shredding
			{
				this.Untag("shred_zone");
				if (not this.hasTag("auto_zone"))
					this.Untag("tick_zone");
				else
					this.Tag("use_normal_tickrate");
			}
			else
			{
				this.set_u16("tiles_zoned", i);
			}


			delta_pos *= 8;
			target_pos += delta_pos;

			if (ZoneShredTile(map, target_pos))
				break;
			else
				tiles_checked++;
		}
	}
}

// Shred tile at pos if it's a shreddable block, return true if shredded
bool ZoneShredTile(CMap@ map, Vec2f pos)
{
	CMap::Tile tile = map.getTile(pos);

	if (map.isTileCastle(tile.type))
	{
		map.server_SetTile(pos, XORRandom(3) == 0 ? CMap::tile_castle_back_moss
												  : CMap::tile_castle_back);
	}
	else if (map.isTileWood(tile.type))
	{
		map.server_SetTile(pos, CMap::tile_wood_back);
	}
	else if (tile.blobid1 != 0 || tile.blobid2 != 0)
	{
		CBlob@ blob;
		@blob = getBlobByNetworkID(tile.blobid1);
		if (blob !is null)
			blob.server_Die();
		@blob = getBlobByNetworkID(tile.blobid2);
		if (blob !is null)
			blob.server_Die();
	}
	else // Nothing happened
	{
		return false;
	}
	return true;
}

CMap::Sector@ getMyZone(CBlob@ this, CMap@ map)
{
	CMap::Sector@ zone = null;
	CMap::Sector@[] zones_here;
	map.getSectorsAtPosition(this.getPosition(), @zones_here);
	for (int i = 0; i < zones_here.length; ++i)
	{
		@zone = zones_here[i];
		if (zone.ownerID == this.getNetworkID())
			return zone;
	}
	return null;
}

CBlob@ getOppositeFlag(CBlob@ flag, CMap@ map)
{
	int mapcenter = map.tilemapwidth * map.tilesize / 2;
	Vec2f opposite_pos = flag.getPosition();
	opposite_pos.x = 2 * mapcenter - opposite_pos.x;

	CBlob@[] blobs;
	map.getBlobsAtPosition(opposite_pos, @blobs);
	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getName() == flag.getName())
		{
			return blobs[i];
		}
	}
	return null;
}
