
#include "FlagZonesCommon.as";

Vec2f[][] floating_zones;

// CRules Hooks

void onInit(CRules@ this)
{
	this.addCommandID("add_floating_zone");

	this.set_u8("active_flag_count", 0);
}

void onRestart(CRules@ this)
{
	this.Untag("sudden_death_flags");
	this.set_u8("active_flag_count", 0);
	floating_zones.clear();
	if (this.hasTag("render_floating_zones"))
	{
		// print("REMOVING SCRIPT");
		Render::RemoveScript(this.get_u16("render_floating_zones_callback"));
		this.Untag("render_floating_zones");
	}
}

// Tell them where the floating flag zones are
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (player is null) return;
	for (int i = 0; i < floating_zones.length; ++i)
	{
		CBitStream params;
		Vec2f[]@ corners = @floating_zones[i];
		// print("player=" + player.getUsername() + " zone=" + i + " ul=" + corners[0] + " lr=" + corners[1]);
		if (corners.length > 1)
		{
			params.write_Vec2f(corners[0]); // ul
			params.write_Vec2f(corners[1]); // lr
		}
		this.SendCommand(this.getCommandID("add_floating_zone"), params, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("add_floating_zone"))
	{
		// print("Got add command, client=" + isClient());
		if (!isClient()) return;

		Vec2f upperleft;
		Vec2f lowerright;
		if (!params.saferead_Vec2f(upperleft)) return;
		if (!params.saferead_Vec2f(lowerright)) return;

		// print("ul=" + upperleft + " lr=" + lowerright);

		Vec2f[][]@ new_zones;
		if (this.exists("new_zones"))
			this.get("new_zones", @new_zones);
		else
		{
			@new_zones = @Vec2f[][]();
			this.set("new_zones", @new_zones);
		}

		Vec2f[] new_zone;
		new_zone.push_back(upperleft);
		new_zone.push_back(lowerright);

		new_zones.push_back(new_zone);
		// print("new_zones=" + new_zones.length);

		this.Tag("new_floating_zones");

		// Render::addScript(Render::layer_objects,
		// 				  "FlagZonesRender.as",
		// 				  "RenderOwnerlessZone",
		// 				  0.0);

		if (!this.hasTag("render_floating_zones"))
		{
			// print("ADDING SCRIPT");
			this.Tag("render_floating_zones");
			this.Tag("remove_old_floating_zones");
			this.set_u16("render_floating_zones_callback", 
						 Render::addScript(Render::layer_objects,
										   "FlagZonesRender.as",
										   "RenderOwnerlessZone",
										   0.0));
		}
		// print("callback=" + this.get_u16("render_floating_zones_callback"));
	}
}

// CBlob Hooks

void onInit(CBlob@ this)
{
	this.addCommandID("update_zone");
	this.addCommandID("remove_zone");

	if (isClient())
	{
		// For new joiners, will remove itself if the zone is default
		Render::addBlobScript(Render::layer_objects, this,
							  "FlagZonesRender.as", "RenderFlagZoneEdges");
	}

	if (!isServer()) return;

	ScriptData@ script = this.getCurrentScript();
	script.tickFrequency = FlagZone::NORMAL_TICKRATE;
	script.tickIfTag = "tick_zone";

	// Set defaults to rules
	CRules@ rules = getRules();
	this.set_u32("time_to_expand", 0);

	if (!rules.exists("flagzone_cooldown"))
		rules.set_u16("flagzone_cooldown", FlagZone::COOLDOWN);

	if (!rules.exists("flagzone_max_expands") && FlagZone::MAX_EXPANDS > 0)
		rules.set_u8("flagzone_max_expands", FlagZone::MAX_EXPANDS);

	this.set_u8("expand_count", 0);

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("remove_zone"))
	{
		CMap@ map = this.getMap();
		map.RemoveSectorsAtPosition(this.getPosition(), "no_build_new", this.getNetworkID());
		ParticleZombieLightning(this.getPosition());
		this.Untag("keep_zone_render");
	}
	else if (cmd == this.getCommandID("update_zone"))
	{
		CMap@ map = this.getMap();

		// read params
		Vec2f upperleft_change;
		Vec2f lowerright_change;
		bool new_zone = false;
		if (!params.saferead_Vec2f(upperleft_change)) return;
		if (!params.saferead_Vec2f(lowerright_change)) return;
		params.saferead_bool(new_zone);
		if (new_zone) // replacing old zone
		{
			map.RemoveSectorsAtPosition(this.getPosition(), "no build", this.getNetworkID());
		}
		CMap::Sector@ zone = getMyZone(this, map);
		if (zone is null) return;

		Vec2f new_ul = zone.upperleft - upperleft_change;
		Vec2f new_lr = zone.lowerright + lowerright_change;

		// Remove the zone if it would shrink too much
		if (new_ul.x >= new_lr.x || new_ul.y >= new_lr.y)
		{
			map.RemoveSectorsAtPosition(this.getPosition(), zone.name, this.getNetworkID());
		}
		else
		{
			if (new_zone)
				Render::addBlobScript(Render::layer_objects, this,
									  "FlagZonesRender.as", "RenderFlagZoneEdges");
			zone.upperleft = new_ul;
			zone.lowerright = new_lr;
		}

		this.Untag("keep_zone_render");
		ParticleZombieLightning(this.getPosition());
		// Sound::Play("EvilLaughShort1.ogg");
	}
}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.hasTag("use_shred_tickrate"))
		{
			this.Untag("use_shred_tickrate");
			this.getCurrentScript().tickFrequency = FlagZone::SHRED_TICKRATE;
		}
		else if (this.hasTag("use_normal_tickrate"))
		{
			this.Untag("use_normal_tickrate");
			this.getCurrentScript().tickFrequency = FlagZone::NORMAL_TICKRATE;
		}

		if (this.hasTag("shred_zone"))
		{
			ZoneNextTile(this);
		}
		else if (this.hasTag("auto_zone"))
		{
			CRules@ rules = getRules();
			u32 expand_time = this.get_u32("time_to_expand");
			if (getGameTime() > expand_time)
			{
				u8 max_expands = rules.exists("flagzone_max_expands")
									? rules.get_u8("flagzone_max_expands")
									: 255;

				if (max_expands == 255)
				{
					ExpandFlagZone(this);
					this.set_u32("time_to_expand", 
								 expand_time + rules.get_u16("flagzone_cooldown") * 30);
				}
				else
				{
					ExpandFlagZone(this);
					this.set_u32("time_to_expand", 
								 expand_time + rules.get_u16("flagzone_cooldown") * 30);

					if (this.get_u8("expand_count") >= max_expands)
					{
						StopAutoExpanding(this);
					}
				}
			}
		}
	}
	else // only need to tick on server
	{
		this.Untag("tick_zone");
		this.getCurrentScript().tickFrequency = 0;
	}
}

void onDie(CBlob@ this)
{
	if (!isServer()) return;

	bool was_suddendeath = isSuddenDeath(getRules());

	DecreaseActiveFlagCount(this);

	CMap@ map = getMap();
	CMap::Sector@ zone = getMyZone(this, map);
	if (zone is null || zone.name == "no build")
		return;

	// Add an ownerless sector where this flag's zone used to be
	map.server_AddSector(zone.upperleft, zone.lowerright, "no_build_new");

	// And trigger rendering of it
	CRules@ rules = getRules();
	CBitStream params;
	params.write_Vec2f(zone.upperleft);
	params.write_Vec2f(zone.lowerright);
	rules.SendCommand(rules.getCommandID("add_floating_zone"), params, true);

	// And server keep track of the zone for when people join later
	Vec2f[] floating_zone;
	floating_zone.push_back(zone.upperleft);
	floating_zone.push_back(zone.lowerright);
	floating_zones.push_back(floating_zone);

	CBlob@ flag = getOppositeFlag(this, map);
	if (flag !is null)
	{
		ResetFlagZone(flag, map);
	}

	// If there are no active flagzones left, keep sudden death going
	// Todo: activate equal amount of flags on each team if there are 3+ flags
	if (was_suddendeath && !isSuddenDeath(getRules()))
	{
		server_StartSuddenDeathFlags(false);
	}
}
