// BoatShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_dinghy = 25;
const s32 cost_longboat = 50;
const s32 cost_warboat = 250;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	AddIconToken("$megaboat$", "VehicleIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$covered_dinghy$", "VehicleIcons.png", Vec2f(32, 32), 7);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + "a small boat");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);

	}
	{
		ShopItem@ s = addShopItem(this, "Covered Dinghy", "$covered_dinghy$", "covered_dinghy", "$covered_dinghy$\n\n\n" + "a small boat with a mounted bow");
		AddRequirement(s.requirements, "coin", "", "Coins", 15);


		s.crate_icon = 0;
	}
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + "ramming speed", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.crate_icon = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + "a mobile war spawn", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Mega Boat", "$megaboat$", "megaboat", "$megaboat$\n\n\n" + "upgraded warboat", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 175);
		s.crate_icon = 0;
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
	}
}

