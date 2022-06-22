// TechShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Molotov", "$molotov$", "molotov", "Set fire to things!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Slidemine", "$slidemine$", "slidemine", "Side it on the ground into people!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 6);
	}
	{
		ShopItem@ s = addShopItem(this, "Firemine", "$firemine$", "firemine", "It explodes into flames!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 6);
	}
	{
		ShopItem@ s = addShopItem(this, "Glass Vial", "$glassvial$", "glassvial", "A pristine clear glass vial.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Cannon", "$mounted_bow$", "mounted_bow", "Launch cannonballs straight into your enemies!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
		}
	}
}
