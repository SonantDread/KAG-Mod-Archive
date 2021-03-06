// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);
	AddIconToken("$outpost$", "Outpost.png", Vec2f(40, 40), 0);

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(6, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	int team_num = this.getTeamNum();

	{
		string cata_icon = getTeamIcon("catapult", "VehicleIcons.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Catapult", cata_icon, "catapult", cata_icon + "\n\n\n" + Descriptions::catapult, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::catapult);
	}
	{
		string ballista_icon = getTeamIcon("ballista", "VehicleIcons.png", team_num, Vec2f(32, 32), 1);
		ShopItem@ s = addShopItem(this, "Ballista", ballista_icon, "ballista", ballista_icon + "\n\n\n" + Descriptions::ballista, false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::ballista);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + Descriptions::ballista_ammo, false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Shells", "$mat_bomb_bolts$", "mat_bomb_bolts", "$mat_bomb_bolts$\n\n\n" + Descriptions::ballista_bomb_ammo, false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Outpost", "$outpost$", "outpost", "A deployable respawn point with a storage that allows fast travel", false, true);
		s.crate_icon = 7;
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Leviathan Cannon", "$leviathancannon$", "leviathancannon", "A heavy cannon that shoots explosive bullets. Has very strong recoil", false, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	AddIconToken("$bomber$", "Balloon.png",Vec2f(48, 64), 0);
	{
		ShopItem@ s = addShopItem(this, "Bomber", "$bomber$", "bomber", "Flying thing, you can grapple it!", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	
	AddIconToken("$airship$", "Airship.png",Vec2f(96, 64), 0);
	{
		ShopItem@ s = addShopItem(this, "Airship", "$airship$", "airship", "Bigger flying thing, can also grapple it.", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
			else if (name == "outpost")
			{
				CBlob@ crate = getBlobByNetworkID(item);
				
				crate.set_Vec2f("required space", Vec2f(5, 5));
				crate.set_s32("gold building amount", 50);
				crate.Tag("unpack_check_nobuild");
			}
		}
	}
}
