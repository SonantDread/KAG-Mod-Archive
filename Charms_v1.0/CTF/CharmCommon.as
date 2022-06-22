//class for getting everything needed for charms

#include "RespawnCommandCommon.as";

const f32 CHARM_BUTTON_SIZE = 2;

shared class PlayerCharm
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
	uint8 slots;
	bool active;
	uint32 cooldown;
	f32 range;
	f32 radius;
};

void addPlayerCharm(CBlob@ this, string name, string iconName, string configFilename, string description, uint8 slots, bool active, uint32 cooldown, f32 range, f32 radius)
{
	if (!this.exists("playercharms"))
	{
		PlayerCharm[] charms;
		this.set("playercharms", charms);
	}

	PlayerCharm p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	p.slots = slots;
	p.active = active;
	p.cooldown = cooldown;
	p.range = range;
	p.radius = radius;
	this.push("playercharms", p);
}

void addCharmsToMenu(CBlob@ this, CGridMenu@ menu, uint16 callerID)
{
	PlayerCharm[]@ charms;

	if (this.get("playercharms", @charms))
	{
		for (uint i = 0 ; i < charms.length; i++)
		{
			PlayerCharm @pcharm = charms[i];

			uint16 testd = callerID;

			CPlayer@ callerplayer = getBlobByNetworkID(testd).getPlayer();

			CBitStream params;
			params.write_u16(callerID);
			params.write_string(pcharm.configFilename);
			params.write_u8(pcharm.slots);

			CRules@ rules = getRules();

			string charm_user = pcharm.configFilename + "_" + callerplayer.getUsername();
			string charm_user_slots = "charmslots_" + callerplayer.getUsername();

			CGridButton@ button = menu.AddButton(pcharm.iconName, pcharm.name, SpawnCmd::selectCharm, Vec2f(CHARM_BUTTON_SIZE, CHARM_BUTTON_SIZE), params);

			if (button !is null)
			{
				if(rules.get_bool(charm_user) == true)
				{
					button.SetSelected(1);
				}
				else if(rules.get_bool(charm_user) == false && pcharm.slots > rules.get_u8(charm_user_slots))
				{
					button.SetEnabled(false);
				}
			}

			button.SetHoverText( "\n" + pcharm.description + "\n" );
		}
	}
}

PlayerCharm@ getDefaultCharm(CBlob@ this)
{
	PlayerCharm[]@ charms;

	if (this.get("playercharms", @charms))
	{
		return charms[0];
	}
	else
	{
		return null;
	}
}

void InitCharms(CBlob@ this)
{
	AddIconToken("$heart_charm_icon$", "HeartCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$falldmg_charm_icon$", "FallDmgCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$clock_charm_icon$", "ClockCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$4x_charm_icon$", "4xCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$waterheal_charm_icon$", "WaterHealCharm.png", Vec2f(32, 32), 0);

	AddIconToken("$dash_charm_icon$", "DashCharm.png", Vec2f(32, 32), 0);
	//AddIconToken("$fire_sword_charm_icon$", "FireSwordCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$chicken_charm_icon$", "ChickenCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$heavy_charm_icon$", "HeavyCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$velocity_3x_charm_icon$", "LForceCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$skull_bomb_charm_icon$", "SkullBombCharm.png", Vec2f(32, 32), 0);

	AddIconToken("$speed_on_kill_charm_icon$", "SpeedOnKillCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$teleport_charm_icon$", "TeleportCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$killer_queen_charm_icon$", "KillerQueenCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$statis_field_charm_icon$", "StasisCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$arrow_rain_charm_icon$", "ArrowRainCharm.png", Vec2f(32, 32), 0);	

	AddIconToken("$360_slash_charm_icon$", "360SlashCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$swap_places_charm_icon$", "SwapPlacesCharm.png", Vec2f(32, 32), 0);	
	AddIconToken("$divine_protection_charm_icon$", "DivineProtectionCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$infinite_wallrun_charm_icon$", "InfiniteWallrunCharm.png", Vec2f(32, 32), 0);
	AddIconToken("$materials_extraction_charm_icon$", "MaterialsExtractionCharm.png", Vec2f(32, 32), 0);	

	AddIconToken("$coin_increase_charm_icon$", "CoinIncreaseCharm.png", Vec2f(32, 32), 0);	
	AddIconToken("$2hearts_on_death_charm_icon$", "2HeartsCharm.png", Vec2f(32, 32), 0);	
	AddIconToken("$light_charm_icon$", "LightCharm.png", Vec2f(32, 32), 0);	
	AddIconToken("$quick_build_charm_icon$", "QuickBuildCharm.png", Vec2f(32, 32), 0);	
	AddIconToken("$tree_climb_charm_icon$", "TreeClimbCharm.png", Vec2f(32, 32), 0);	

	AddIconToken("$switch_charms$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 11, 2);

	// blob (tent), name, icon name, realname (configfilename), description, cost, active or passive, cooldown, range, radius

	addPlayerCharm(this, "Charm of Extra Health", "$heart_charm_icon$", "heartcharm", "Passive Charm. +1 heart to maximum health. \nCost: 2", 2, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Fall Damage Immunity", "$falldmg_charm_icon$", "falldmgcharm", "Passive Charm. You no longer get fall damage. \nCost: 2", 2, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Heal Over Time", "$clock_charm_icon$", "clockcharm", "Passive Charm. Heal 0.25hp per 2 seconds if not damaged in the past 5 seconds. \nCost: 3", 3, false, 5 * 30, -1, -1);
	addPlayerCharm(this, "Charm of Quadra Arrows", "$4x_charm_icon$", "4xcharm", "Passive Charm. Archer only. Do 4x shot instead of 3x shot. \nCost: 3", 3, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Water Healing", "$waterheal_charm_icon$", "waterhealcharm", "Passive Charm. Water heals you. Water stuns are halved. \nCost: 2", 2, false, -1, -1, -1);

	addPlayerCharm(this, "Charm of Dashing", "$dash_charm_icon$", "dashcharm", "Ability Charm. Pressing [S] while moving left or right ([A] / [D]) will make you dash in that direction. 5 second cooldown. \nCost: 2", 2, true, 5 * 30, -1, -1);
	addPlayerCharm(this, "Charm of Slowfall", "$chicken_charm_icon$", "lightercharm", "Passive Charm. You are lighter.\nCost: 2", 2, false, -1, -1, -1);
	//addPlayerCharm(this, "Charm of Fire Sword", "$fire_sword_charm_icon$", "fireswordcharm", "Passive Charm. Attacking players, items gives them +25% heat per heart of damage. Shielded: 10% heat. Catch fire when reach 100% heat. Heated entities lose 4% heat each second. \nCost: 3", 3, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Heavy Curse", "$heavy_charm_icon$", "heavycharm", "Ability Charm. Use ability key on players or items to make them much heavier for a short time. 20s cooldown. Doesn't work through walls. Limited range. \nCost: 3", 3, true, 20 * 30, 100.0f, 16.0f);
	addPlayerCharm(this, "Charm of Velocity Tripling", "$velocity_3x_charm_icon$", "velocity3xcharm", "Ability Charm. Use ability key on players or items to triple their current velocity. 30s cooldown. Doesn't work through walls. Limited range.\nCost: 3", 3, true, 30 * 30, 200.0f, 16.0f);
	addPlayerCharm(this, "Charm of Bombs On Death", "$skull_bomb_charm_icon$", "bombsondeathcharm", "Passive Charm. Drop 3 bombs with 6 second timer on death.\nCost: 2", 2, false, -1, -1, -1);

	addPlayerCharm(this, "Charm of Speed On Kill", "$speed_on_kill_charm_icon$", "speedonkillcharm", "Passive Charm. Increased movement speed for 6 seconds after killing an enemy.\nCost: 3", 3, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Teleport", "$teleport_charm_icon$", "teleportcharm", "Ability Charm. Use ability key on desired location to teleport to. 20s cooldown. Doesn't work through walls. Limited range.\nCost: 4", 4, true, 20 * 30, 160.0f, -1);
	addPlayerCharm(this, "Charm of Item Explosion", "$killer_queen_charm_icon$", "killerqueencharm", "Ability Charm. Pressing ability key causes the last item you held (has red particles around it) to explode. 10s cooldown. \nCost: 2", 2, true, 10 * 30, 256.0f, -1);
	addPlayerCharm(this, "Charm of Stasis", "$statis_field_charm_icon$", "stasischarm", "Ability Charm. Pressing ability key creates a statis field - non-player entities are frozen in time when entering it. Lasts 5 seconds, 45s cooldown.\nCost: 4", 4, true, 45 * 30, 250.0f, 88.0f);
	addPlayerCharm(this, "Charm of Arrow Rain", "$arrow_rain_charm_icon$", "arrowraincharm", "Ability Charm. Pressing ability key makes you summon a volley of golden arrows. Consumes arrows from inventory. 40s cooldown.\nCost: 4", 4, true, 40 * 30, -1, -1);

	addPlayerCharm(this, "Charm of 360 Angle Slashes", "$360_slash_charm_icon$", "360slashcharm", "Passive Charm. Double slash is replaced with a single high range 360 slash.\nCost: 2", 2, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Location Swap", "$swap_places_charm_icon$", "swapplacescharm", "Ability Charm. Pressing ability key on an enemy player swaps their location with yours. 20s cooldown. Doesn't work through walls. Limited range.\nCost: 3", 3, true, 20 * 30, 250.0f, 16.0f);
	addPlayerCharm(this, "Charm of Divine Protection", "$divine_protection_charm_icon$", "divineprotectioncharm", "Passive Charm. You're able to survive fatal damage every 30 seconds.\nCost: 3", 3, false, 30 * 30, -1, -1);
	addPlayerCharm(this, "Charm of Infinite Wallrun", "$infinite_wallrun_charm_icon$", "infinitewallruncharm", "Passive Charm. You can wallrun infinitely.\nCost: 1", 1, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Materials Extraction", "$materials_extraction_charm_icon$", "materialsextractioncharm", "Passive Charm. Killing an enemy makes them drop a small amount of materials.\nCost: 2", 2, false, -1, -1, -1);

	addPlayerCharm(this, "Charm of Combat Coin Gain", "$coin_increase_charm_icon$", "coinincreasecharm", "Passive Charm. 150% coin gain from combat, 75% coin loss on death.\nCost: 1", 2, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Additional Heart Drop", "$2hearts_on_death_charm_icon$", "2heartsondeathcharm", "Passive Charm. Enemies drop an additional heart on death.\nCost: 1", 1, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Light", "$light_charm_icon$", "lightcharm", "Passive Charm. You emit light.\nCost: 1", 1, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Quick Build", "$quick_build_charm_icon$", "quickbuildcharm", "Passive Charm. You can place blocks faster.\nCost: 3", 3, false, -1, -1, -1);
	addPlayerCharm(this, "Charm of Tree Climb", "$tree_climb_charm_icon$", "treeclimbcharm", "Passive Charm. You can climb trees as builder and knight.\nCost: 1", 1, false, -1, -1, -1);

}

PlayerCharm@ getCharmByName(string seekedConfigFilename)
{
	CBlob@ blob = getBlobByName("tent");

	if(blob is null)
	{
		PlayerCharm p;
		p.name = "Charm of Fire Sword";
		p.iconName = "$heart_charm_icon$";
		p.configFilename = "fireswordcharm";
		p.description = "description";
		p.slots = 0;
		p.active = false;
		p.cooldown = 1;
		p.range = 1.0f;
		p.radius = 1.0f;
		return p;
	}

	PlayerCharm[]@ charms;

	if (blob.get("playercharms", @charms))
	{
		for (uint i = 0 ; i < charms.length; i++)
		{
			PlayerCharm@ currentcharm = charms[i];

			if(currentcharm.configFilename == seekedConfigFilename)
			{
				return currentcharm;
			}
		}
	}

	return null;

}

bool hasCharm(CPlayer@ this, PlayerCharm@ charm)
{
	if(this is null || charm is null || getRules() is null ) return false;

	return getRules().get_bool(charm.configFilename + "_" + this.getUsername());
}

EKEY_CODE getKey(string key)
{
	if(key == "KEY_KEY_1")
	{
		return KEY_KEY_1;
	}
	else if(key == "KEY_KEY_2")
	{
		return KEY_KEY_2;
	}
	else if(key == "KEY_KEY_3")
	{
		return KEY_KEY_3;
	}
	else if(key == "KEY_KEY_4")
	{
		return KEY_KEY_4;
	}
	else if(key == "KEY_KEY_5")
	{
		return KEY_KEY_5;
	}
	else if(key == "KEY_KEY_6")
	{
		return KEY_KEY_6;
	}
	else
	{
		return JOYSTICK_3_BUTTON_LAST; // pog
	}

}