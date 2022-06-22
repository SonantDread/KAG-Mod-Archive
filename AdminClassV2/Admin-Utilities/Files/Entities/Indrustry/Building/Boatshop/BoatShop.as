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
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	int team_num = this.getTeamNum();

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	{
		string dinghy_icon = getTeamIcon("dinghy", "VehicleIcons.png", team_num, Vec2f(32, 32), 6);
		ShopItem@ s = addShopItem(this, "Dinghy", dinghy_icon, "dinghy", dinghy_icon + "\n\n\n" + Descriptions::dinghy);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::dinghy_wood);
	}
	{
		string longboat_icon = getTeamIcon("longboat", "VehicleIcons.png", team_num, Vec2f(32, 32), 5);
		ShopItem@ s = addShopItem(this, "Longboat", longboat_icon, "longboat", longboat_icon + "\n\n\n" + Descriptions::longboat, false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::longboat);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::longboat_wood);
		s.crate_icon = 1;
	}
	{
		string warboat_icon = getTeamIcon("warboat", "VehicleIcons.png", team_num, Vec2f(32, 32), 2);
		ShopItem@ s = addShopItem(this, "War Boat", warboat_icon, "warboat", warboat_icon + "\n\n\n" + Descriptions::warboat, false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::warboat);
		s.crate_icon = 2;
	}
	{
		string dinghy_icon = getTeamIcon("uboot", "UbootIcon.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "U-Boot", dinghy_icon, "uboot", dinghy_icon + "\n\n\n" + Descriptions::uboot, false, true);
		s.crate_icon = 19;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::uboot);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::uboot_stone);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::uboot_gold);
	}
	{
		string dinghy_icon = getTeamIcon("Caravel", "CaravelIcon.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Caravel", dinghy_icon, "Caravel", dinghy_icon + "\n\n\n" + Descriptions::caravel, false, true);
		s.crate_icon = 19;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::caravel);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::caravel_wood);
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
