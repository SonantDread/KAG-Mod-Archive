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
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Soul", "$soul$", "soul", "It pulses with life.", true);
		AddRequirement(s.requirements, "blob", "moonrock", "Moon Rock", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Cultist Guide", "$cultistguide$", "cultistguide", "Join the Cult.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 36);
	}
	{
		ShopItem@ s = addShopItem(this, "Moonrock Offering", "$moonrockoffering$", "moonrockoffering", "Petition the Moon.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "The Signal", "$thesignal$", "thesignal", "A beacon to the stars.", true);
		AddRequirement(s.requirements, "blob", "moonrock", "Moon Rock", 50);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 15);
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
		this.set_Vec2f("shop offset", Vec2f(0, 0));
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
