//script by Xeno(PURPLExeno), sprites by Skemonde(TheCustomerMan), hosting by vladkvs193

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); 
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	addTokens(this); 

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 9));
	this.set_string("shop description", "Advanced Weapon Shop");
	this.set_u8("shop icon", 21);

	this.SetLightRadius(32);
    this.SetLight(true);

 	{
		ShopItem@ s = addShopItem(this, "Salt pebbles (20)", "$icon_banditammo$", "mat_banditammo-20", "Bullets for shit guns!");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
    {
		ShopItem@ s = addShopItem(this, "Low Caliber Ammunition (20)", "$icon_pistolammo$", "mat_pistolammo-20", "Bullets for pistols and SMGs.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Caliber Ammunition (10)", "$icon_rifleammo$", "mat_rifleammo-10", "Bullets for rifles. Effective against armored targets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 80);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun Shells (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", "Shotgun Shells for... Shotguns.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Gun Ammunition (50)", "$icon_gatlingammo$", "mat_gatlingammo-50", "Ammunition used by the machine gun.");
		AddRequirement(s.requirements, "coin", "", "Coins", 90);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "'Fuger' Pocket Pistol", "$fuger$", "fuger-110", "Some special order straight from Germany.");
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		s.spawnNothing = true;
	}
	{
        ShopItem@ s = addShopItem(this, "Mauser C96", "$c96$", "c96", "Mauser self-loading pistol.");
		AddRequirement(s.requirements, "coin", "", "Coins", 960);
		AddRequirement(s.requirements, "blob", "beagle", "UPF Beagle-20", 1);
		AddRequirement(s.requirements, "blob",  "mat_steelingot", "Steel Ingot", 4);
        AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		
        s.spawnNothing = true;
    }
	{
        ShopItem@ s = addShopItem(this, "Mauser Schnellfeuer Pistole", "$m712$", "m712", "Official modification that makes C96 fully automatic!!");
		AddRequirement(s.requirements, "coin", "", "Coins", 3712);
        AddRequirement(s.requirements, "blob", "c96", "Mauser C96", 1);
		AddRequirement(s.requirements, "blob", "uzi", "UPF Submachine Gun", 1);
        AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
	    AddRequirement(s.requirements, "blob",  "mat_steelingot", "Steel Ingot", 8);
		
        s.spawnNothing = true;
    }
	AddIconToken("$icon_ivan_offering_1$", "AltarIvan_Icons.png", Vec2f(24, 24), 1);
    {
		ShopItem@ s = addShopItem(this, "Squat of Kalashnikov", "$ak47$", "ak47", "Popular russian weapon");
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 24);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 4);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "RP-46", "$rp46$", "rp46", "Powerful machinegun with slow fire rate and medium accuracy");
		AddRequirement(s.requirements, "coin", "", "Coins", 2500);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 16);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 10);
		
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "TKB-521", "$tkb521$", "tkb521", "A nice machinegun with a big magazine and medium damage");
		AddRequirement(s.requirements, "coin", "", "Coins", 2750);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 12);
		
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{	
		ShopItem@ s = addShopItem(this, "Dragunov's Rifle", "$SVD$", "SVD", "A strong semi-auto sniper rifle.");
		AddRequirement(s.requirements, "coin", "", "Coins", 2500);
		AddRequirement(s.requirements, "blob",  "mat_wood", "Wood", 300);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 16);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 4);
		AddRequirement(s.requirements, "blob", "rifle", "Bolt Rifle", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gauss Rifle", "$icon_gaussrifle$", "gaussrifle", "A modified toy used to kill people.\n\nUses Mithril Ingots.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 50);
		AddRequirement(s.requirements, "blob", "mat_copperwire", "Copper Wire", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 850);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$icon_shotgun$", "shotgun", "A short-ranged weapon that deals devastating damage.\n\nUses Shotgun Shells.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 120);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Scorcher", "$icon_flamethrower$", "flamethrower", "A tool used for incinerating plants, buildings and people.\n\nUses Oil.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 600);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Blazethrower", "$icon_blazethrower$", "blazethrower", "A Scorcher modification providing support for gaseous fuels.\n\nUses Fuel.");
		AddRequirement(s.requirements, "blob", "flamethrower", "Scorcher", 1);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 5);
		AddRequirement(s.requirements, "coin", "", "Coins", 900);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Acidthrower", "$icon_acidthrower$", "acidthrower", "A tool used for dissolving plants, buildings and people.\n\nUses Acid.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 1250);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade Launcher", "$icon_grenadelauncher$", "grenadelauncher", "A short-ranged weapon that launches grenades.\n\nUses Grenades.");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 12);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 800);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "L.O.L. Warhead Launcher", "$icon_mininukelauncher$", "mininukelauncher", "Are people bullying you again? Remember, there still is the nuclear option.\n\nUses L.O.L. Warheads.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 20);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "SAM RPG", "$samrpg$", "samrpg", "RPG, but with auto-aiming rockets! Uses SAM missiles!");
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 42);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 100);
		AddRequirement(s.requirements, "blob", "mat_copperingot", "Copper Ingot", 30);
		AddRequirement(s.requirements, "coin", "", "Coins", 3000);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
}    

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	addTokens(this);
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$rp46$", "RP-46.png", Vec2f(34, 12), 0, teamnum);
	AddIconToken("$tkb521$", "TKB-521.png", Vec2f(34, 14), 0, teamnum);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			CPlayer@ ply = callerBlob.getPlayer();
			if (ply !is null)
			{
				tcpr("[PBI] " + ply.getUsername() + " has purchased " + name);
			}
		
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;
				if (callerBlob.getPlayer() !is null && name == "nuke")
				{
					blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				}

				if (!blob.hasTag("vehicle"))
				{
					if (!blob.canBePutInInventory(callerBlob))
					{
						callerBlob.server_Pickup(blob);
					}
					else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
					{
						callerBlob.server_PutInInventory(blob);
					}
				}
			}
		}
	}
}
