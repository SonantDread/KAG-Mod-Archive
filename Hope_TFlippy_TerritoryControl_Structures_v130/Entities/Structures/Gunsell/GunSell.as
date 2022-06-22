// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,1));
	this.set_Vec2f("shop menu size", Vec2f(10, 8));
	this.set_string("shop description", "Forge");
	this.set_u8("shop icon", 15);

		{
		ShopItem@ s = addShopItem(this, "Low caliber ammo for a gold ingot", "$icon_pistolammo$", "mat_goldingot-1", "Sell pistol ammo", true);
		AddRequirement(s.requirements, "blob", "mat_pistolammo", "Pistol ammo", 100);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High caliber ammo for a gold ingot", "$icon_rifleammo$", "mat_goldingot-1", "Sell rifle ammo", true);
		AddRequirement(s.requirements, "blob", "mat_rifleammo", "Rifle ammo", 40);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun ammo for a gold ingot", "$icon_shotgunammo$", "mat_goldingot-1", "Sell shotgun ammo");
		AddRequirement(s.requirements, "blob", "mat_shotgunammo", "Shotgun ammo", 16);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Machinegun ammo for a gold ingot", "$icon_gatlingammo$", "mat_goldingot-1", "Sell machinegun ammo");
		AddRequirement(s.requirements, "blob", "mat_gatlingammo", "Machinegun ammo", 200);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Fuger for a gold ingot", "$fuger$", "mat_goldingot-1", "Sell Fuger");
		AddRequirement(s.requirements, "blob", "fuger", "Fuger", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Beagle for 2 gold ingots", "$beagle$", "mat_goldingot-2", "Sell Beagle");
		AddRequirement(s.requirements, "blob", "beagle", "Beagle", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Mauser C96 for 5 gold ingots", "$c96$", "mat_goldingot-5", "Sell Mauser C96");
		AddRequirement(s.requirements, "blob", "c96", "Mauser C96", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Schnehel Schpoken for 15 gold ingots", "$m712$", "mat_goldingot-15", "Sell M712");
		AddRequirement(s.requirements, "blob", "m712", "M712", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Cock19 for 3 gold ingots", "$cock19$", "mat_goldingot-3", "Sell Cock19");
		AddRequirement(s.requirements, "blob", "cock19", "Cock19", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Cock19B for 5 gold ingots", "$cock19b$", "mat_goldingot-5", "Sell Cock19B");
		AddRequirement(s.requirements, "blob", "cock19b", "Cock19B", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Taser for 1 gold ingots", "$taser$", "mat_goldingot-1", "Sell Taser");
		AddRequirement(s.requirements, "blob", "taser", "Taser", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell PDW for 5 gold ingots", "$pdw$", "mat_goldingot-5", "Sell PDW");
		AddRequirement(s.requirements, "blob", "pdw", "PDW", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell UZI for 7 gold ingots", "$uzi$", "mat_goldingot-7", "Sell UZI");
		AddRequirement(s.requirements, "blob", "uzi", "UZI", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Carbine for 8 gold ingots", "$carbine$", "mat_goldingot-8", "Sell Carbine");
		AddRequirement(s.requirements, "blob", "carbine", "Carbine", 1);

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell AK-47 for 8 gold ingots", "$ak47$", "mat_goldingot-8", "Sell AK-47");
		AddRequirement(s.requirements, "blob", "ak47", "AK-47", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell SAR-12 for 8 gold ingots", "$sar$", "mat_goldingot-8", "Sell SAR-12");
		AddRequirement(s.requirements, "blob", "sar", "SAR-12", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Assault for 10 gold ingots", "$assaultrifle$", "mat_goldingot-10", "Sell Assault Rifle");
		AddRequirement(s.requirements, "blob", "assaultrifle", "Assault Rifle", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell TAR-21 for 10 gold ingots", "$tar21$", "mat_goldingot-10", "Sell TAR-21");
		AddRequirement(s.requirements, "blob", "tar21", "TAR-21", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, "Sell TAR-21B for 15 gold ingots", "$tar21b$", "mat_goldingot-15", "Sell TAR-21B");
		AddRequirement(s.requirements, "blob", "tar21b", "TAR-21B", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell XM8 for 15 gold ingots", "$xm8$", "mat_goldingot-15", "Sell XM8");
		AddRequirement(s.requirements, "blob", "xm8", "XM8", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell XM8v2 for 25 gold ingots", "$xm8v2$", "mat_goldingot-25", "Sell XM8v2");
		AddRequirement(s.requirements, "blob", "xm8v2", "XM8v2", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell DP-27 for 3 gold ingots", "$dp27$", "mat_goldingot-3", "Sell DP-27");
		AddRequirement(s.requirements, "blob", "dp27", "DP-27", 1);

		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, "Sell RP-46 for 10 gold ingots", "$rp46$", "mat_goldingot-10", "Sell RP-46");
		AddRequirement(s.requirements, "blob", "rp46", "RP-46", 1);

		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell TKB-521 for 10 gold ingots", "$tkb521$", "mat_goldingot-10", "Sell TKB-521");
		AddRequirement(s.requirements, "blob", "tkb521", "TKB-521", 1);

		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Puntgun for 10 gold ingots", "$puntgun$", "mat_goldingot-10", "Sell Puntgun");
		AddRequirement(s.requirements, "blob", "puntgun", "Puntgun", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Boomstick for 2 gold ingots", "$icon_boomstick$", "mat_goldingot-2", "Sell Boomstick");
		AddRequirement(s.requirements, "blob", "boomstick", "Boomstick", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Shotgun for 3 gold ingots", "$icon_shotgun$", "mat_goldingot-3", "Sell Shotgun");
		AddRequirement(s.requirements, "blob", "shotgun", "Shotgun", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Assault Shotgun for 7 gold ingots", "$autoshotgun$", "mat_goldingot-7", "Sell Shotgun");
		AddRequirement(s.requirements, "blob", "autoshotgun", "Assault Shotgun", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell SVD for 12 gold ingots", "$SVD$", "mat_goldingot-12", "Sell SVD");
		AddRequirement(s.requirements, "blob", "SVD", "SVD", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Suppressed Rifle for 10 gold ingots", "$silencedrifle$", "mat_goldingot-10", "Sell Suppressed Rifle");
		AddRequirement(s.requirements, "blob", "silencedrifle", "Suppressed Rifle", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Sniper Rifle for 15 gold ingots", "$sniper$", "mat_goldingot-15", "Sell Sniper Rifle");
		AddRequirement(s.requirements, "blob", "sniper", "Sniper Rifle", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell AMR-12 for 50 gold ingots", "$amr$", "mat_goldingot-50", "Sell AMR-12");
		AddRequirement(s.requirements, "blob", "amr", "AMR-12", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell AMR-13 for 100 gold ingots", "$amr13$", "mat_goldingot-100", "Sell AMR-13");
		AddRequirement(s.requirements, "blob", "amr13", "AMR-13", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Gauss for 8 gold ingots", "$gaussrifle$", "mat_goldingot-8", "Sell Gauss");
		AddRequirement(s.requirements, "blob", "gaussrifle", "Gauss", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Scorcher for 2 gold ingots", "$flamethrower$", "mat_goldingot-2", "Sell Scorcher");
		AddRequirement(s.requirements, "blob", "flamethrower", "Scorcher", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Acid Thrower for 5 gold ingots", "$acidthrower$", "mat_goldingot-5", "Sell XM8v2");
		AddRequirement(s.requirements, "blob", "acidthrower", "Acid Thrower", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Napalmer for 8 gold ingots", "$napalmer$", "mat_goldingot-8", "Sell Napalmer");
		AddRequirement(s.requirements, "blob", "napalmer", "Napalmer", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Bazooka for 2 gold ingots", "$bazooka$", "mat_goldingot-2", "Sell Bazooka");
		AddRequirement(s.requirements, "blob", "bazooka", "Bazooka", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Grenade Launcher for 5 gold ingots", "$grenadelauncher$", "mat_goldingot-5", "Sell Grenade Launcher");
		AddRequirement(s.requirements, "blob", "grenadelauncher", "Grenade Launcher", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell RPG for 15 gold ingots", "$rpg$", "mat_goldingot-15", "Sell RPG");
		AddRequirement(s.requirements, "blob", "rpg", "RPG", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell SAM RPG for 30 gold ingots", "$samrpg$", "mat_goldingot-30", "Sell SAM RPG");
		AddRequirement(s.requirements, "blob", "samrpg", "SAM RPG", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell L.O.L. Warhead Launcher for 5 gold ingots", "$mininukelauncher$", "mat_goldingot-5", "L.O.L. Warhead Launcher");
		AddRequirement(s.requirements, "blob", "mininukelauncher", "L.O.L. Warhead Launcher", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Megagun for 75 gold ingots", "$minigun$", "mat_goldingot-75", "Sell Megagun");
		AddRequirement(s.requirements, "blob", "minigun", "Megagun", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell R.E.K.T. 9000 for 250 gold ingots", "$rekt$", "mat_goldingot-250", "Sell R.E.K.T. 9000");
		AddRequirement(s.requirements, "blob", "rekt", "R.E.K.T. 9000", 1);

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ConstructShort");

		if (isServer())
		{
			u16 caller, item;

			if (!params.saferead_netid(caller) || !params.saferead_netid(item))
				return;

			string name = params.read_string();

			if (name.findFirst("mat_") != -1)
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);

				if (callerBlob !is null)
				{
					CPlayer@ callerPlayer = callerBlob.getPlayer();
					string[] tokens = name.split("-");

					if (callerPlayer !is null)
					{
						MakeMat(callerBlob, this.getPosition(), tokens[0], parseInt(tokens[1]));

						// CBlob@ mat = server_CreateBlob(tokens[0]);

						// if (mat !is null)
						// {
							// mat.Tag("do not set materials");
							// mat.server_SetQuantity(parseInt(tokens[1]));
							// if (!callerBlob.server_PutInInventory(mat))
							// {
								// mat.setPosition(callerBlob.getPosition());
							// }
						// }
					}
				}
			}
		}
	}
}