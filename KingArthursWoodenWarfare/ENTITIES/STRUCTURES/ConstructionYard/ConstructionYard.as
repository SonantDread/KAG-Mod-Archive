// Yard script

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	AddIconToken("$stonequarry$", "../Mods/Entities/Industry/CTFShops/Quarry/Quarry.png", Vec2f(40, 24), 4);
	//this.getSprite().getConsts().accurateLighting = true;

	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(10, 2));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem(this, "Bunker", "$bunker$", "bunker", "A tough encampment, great for holding important areas.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy Bunker", "$heavybunker$", "heavybunker", "A terrifying reinforcement, ideal for holding landmarks.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Repair Station", "$repairstation$", "repairstation", "Build in an open area, it will repair vehicles next to it.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "LMG Armory", "$lmgarmory$", "lmgarmory", "Use an LMG with an insane fire-rate and recoil. It will weigh you down.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 75);
	}
	{
		ShopItem@ s = addShopItem(this, "Medic Armory", "$medicarmory$", "medicarmory", "As a medic you heal allies in a area around you. And use an MP5.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 75);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Shipment Upgrade", "$shipmentupgrade$", "shipmentupgrade", "Newly spawned vehicles with have improved equiptment if this building is alive.");
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
	//}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (this.isOverlapping(caller))
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
			caller.ClearMenus();
		}
	}
}