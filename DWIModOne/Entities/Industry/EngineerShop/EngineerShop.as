// BoatShop.as

#include "Requirements.as"
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

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	int team_num = this.getTeamNum();

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	{
		ShopItem@ s = addShopItem(this, "Trojan Boulder", "$trojanboulder$", "trojanboulder", "Boulder you can hide in and control", false, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Super Tramp", "$supertrampoline$", "supertrampoline", "Better quality trampoline for higher bouncing", false, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Car", "$car$", "car", "One man vehicle of mass destruction!", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);

		s.crate_icon = 3;

	}
	{
		ShopItem@ s = addShopItem(this, "Team Crate", "$teamcrate$", "teamcrate", "Crate with room for 4 teammates!", false, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);

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
