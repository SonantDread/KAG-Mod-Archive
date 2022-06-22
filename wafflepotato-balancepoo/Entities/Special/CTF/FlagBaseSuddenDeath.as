
// CRules properties + defaults
const u16 default_zone_cooldown = 60; // seconds between zone expansions
const u8 default_max_expands = 15; // maximum expansion triggers
const string cooldown_prop = "suddendeath_zone_interval";
const string max_expands_prop = "suddendeath_zone_max_times";

const u16 max_tile_checks_per_tick = -1; // for performance if necessary
const u8 ticks_to_shred = 5; // ticks between tile shreds
const u8 normal_tickrate = 30;

// Tag and property names

const string tick_tag = "flagzone_active";
const string shredding_tag = "zone_go_brrt";
const string sudden_death_tag = "sudden_death_zone";

const string expand_count_prop = "expand_zone_count";
const string timer_prop = "time_to_expand_zone";
const string index_prop = "i_zone_tile";

void onInit(CBlob@ this)
{
	ScriptData@ script = this.getCurrentScript();
	script.tickFrequency = normal_tickrate;
	script.tickIfTag = tick_tag;

	// Set defaults to rules
	CRules@ rules = getRules();
	this.set_u32(timer_prop, 0);
	if (!rules.exists(cooldown_prop))
	{
		rules.set_u16(cooldown_prop, default_zone_cooldown);
	}
	if (!rules.exists(max_expands_prop) && default_max_expands < 255)
	{
		rules.set_u8(max_expands_prop, default_max_expands);
	}

	this.set_u8(expand_count_prop, 0);

	this.addCommandID("update_zone");

	this.addCommandID("expand_zone");
	this.addCommandID("shrink_zone");
	this.addCommandID("start_sudden_death");
	this.addCommandID("stop_sudden_death");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("update_zone"))
	{
		CMap@ map = this.getMap();

		// read params
		Vec2f upperleft_change = params.read_Vec2f();
		Vec2f lowerright_change = params.read_Vec2f();
		if (params.read_bool()) // replacing old zone
			map.RemoveSectorsAtPosition(this.getPosition(), "no build");
		CMap::Sector@ zone = getMyZone(this, this.getMap());

		zone.upperleft -= upperleft_change;
		zone.lowerright += lowerright_change;
		ParticleZombieLightning(this.getPosition());
		// Sound::Play("EvilLaughShort1.ogg");
	}

	// Pretty much everything else in this script is for server

	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("expand_zone"))
		{
			ExpandFlagZone(this, true);
		}
		if (cmd == this.getCommandID("shrink_zone"))
		{
			Vec2f change(-1, -1);
			u8 shrink_times;
			if (params.saferead_u8(shrink_times))
			{
				change *= shrink_times;
			}
			ExpandFlagZone(this, false, change, change);
		}
		if (cmd == this.getCommandID("start_sudden_death"))
		{
			this.Tag(tick_tag);
			this.Tag(sudden_death_tag);
			this.set_u8(expand_count_prop, 0);
			this.set_u32(timer_prop, 0);
		}
		else if (cmd == this.getCommandID("stop_sudden_death"))
		{
			this.Untag(sudden_death_tag);
			if (not this.hasTag(shredding_tag))
				this.Untag(tick_tag);
			// otherwise it will untag after zone goes brrt
		}
	}
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.hasTag(shredding_tag)) // tickrate should be 4
		{
			ZoneNextTile(this);
		}
		else if (this.hasTag(sudden_death_tag))
		{
			CRules@ rules = getRules();
			if (getGameTime() > this.get_u32(timer_prop))
			{
				u8 max_expands = rules.get_u8(max_expands_prop);
				if (max_expands < 255 && this.get_u8(expand_count_prop) < max_expands)
				{
					this.SendCommand(this.getCommandID("expand_zone"));
					this.set_u32(timer_prop,
								  getGameTime() + rules.get_u16(cooldown_prop) * 30);
				}
				else
				{
					this.SendCommand(this.getCommandID("stop_sudden_death"));
				}
			}
		}
	}
	else // only need to tick on server
	{
		this.Untag(tick_tag);
		this.getCurrentScript().tickFrequency = 0;
	}
}

// -change from upperleft, +change to lowerright of zone (in blocks, works kinda weird with halves)
void ExpandFlagZone(CBlob@ this, bool shred = true, Vec2f upperleft_change = Vec2f(1, 1),
													Vec2f lowerright_change = Vec2f(1, 1))
{
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();

	CMap::Sector@ zone = getMyZone(this, map);
	if (zone is null)
	{
		// Reset zone
		@zone = map.server_AddSector(pos + Vec2f(-12, -32), pos + Vec2f(12, 16),
									"no build", "", this.getNetworkID());
		for (int x = -12; x < 12; x += 8)
		{
			for (int y = -32; y < 8; y += 8)
			{
				map.server_SetTile(pos + Vec2f(x, y), CMap::tile_empty);
			}
		}
		return;
	}

	// Make sure shred is over before expanding
	while (this.hasTag(shredding_tag))
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
	this.add_u8(expand_count_prop, 1);

	if (shred && getNet().isServer())
		StartZoneShred(this);
}

// Setup zone to begin breaking tiles at zone edges over time
void StartZoneShred(CBlob@ this)
{
	this.set_u16(index_prop, 0);
	this.Tag(tick_tag);
	this.Tag(shredding_tag);
	this.getCurrentScript().tickFrequency = ticks_to_shred;
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
		while (this.hasTag(shredding_tag) && tiles_checked < max_tile_checks_per_tick)
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

			int i = this.get_u16(index_prop);

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
				this.Untag(shredding_tag);
				this.getCurrentScript().tickFrequency = normal_tickrate;
				if (not this.hasTag(sudden_death_tag))
					this.Untag(tick_tag);
			}
			else
			{
				this.set_u16(index_prop, i);
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
			break;
	}
	return zone;
}
