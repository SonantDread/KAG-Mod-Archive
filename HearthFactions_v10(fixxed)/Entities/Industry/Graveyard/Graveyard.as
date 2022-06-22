// Graveyard.as

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
		ShopItem@ s = addShopItem(this, "Soul", "$soul$", "soul", "It pulses with life.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Skull of the Dead", "$skullofthedead$", "skullofthedead", "An ominus looking skull. Press E.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Eye of Darkness", "$eyeofdarkness$", "eyeofdarkness", "Disguises the wearer with darkness!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 18);
		AddRequirement(s.requirements, "blob", "inkblotvial", "Inkblot Vial", 3);
	}
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
