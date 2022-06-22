#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "7.62mm Rounds", "$mat_7mmround$", "mat_7mmround", "Ammo for a light machinegun.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
	}
	{
		ShopItem@ s = addShopItem(this, "14.5mm Rounds", "$mat_14mmround$", "mat_14mmround", "Ammo for an APC's heavy machinegun.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 19);
	}
	{
		ShopItem@ s = addShopItem(this, "105mm Shells", "$mat_bolts$", "mat_bolts", "Ammo for a tank's main gun.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 16);
	}
	{
		ShopItem@ s = addShopItem(this, "HEAT Warheads", "$mat_heatwarhead$", "mat_heatwarhead", "Anti-Tank explosive, used by an RPG-7.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Steak", "$steak$", "steak", "Slab of meat to keep you fighting.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "A dangerous trap for infantry.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 13);
	}
	{
		ShopItem@ s = addShopItem(this, "Tank Trap", "$tanktrap$", "tanktrap", "A crippling trap for vehicles.", false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 75);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "Huge explosive, can seriously damage vehicles and infantry.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 28);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy an Btr82a APC", "$crate$", "btr82a", "APC.\n\nUses 14.5mm.", false, true);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy an M60 Tank", "$crate$", "m60", "Heavy tank.\n\nUses 105mm & 7.62mm.", false, true);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy an T-10 Tank", "$crate$", "t10", "Heavy tank w/ tough armor.\n\nUses 105mm & 7.62mm.", false, true);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	this.set_Vec2f("shop offset", Vec2f_zero);

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if (!getNet().isServer()) return; /////////////////////// server only past here

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
