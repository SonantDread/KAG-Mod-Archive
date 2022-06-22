#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "blob", "explosives", "Explosives", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Rain Charge", "$raincharge$", "raincharge", "Rain kegs from the sky!", false);
		AddRequirement(s.requirements, "blob", "explosives", "Explosives", 8);
	}
	{
		ShopItem@ s = addShopItem(this, "Cluster Keg", "$clusterkeg$", "clusterkeg", "A cluster of kegs.", false);
		AddRequirement(s.requirements, "blob", "explosives", "Explosives", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Explosives", "$explosives$", "explosives", "Used in more powerful explosives.", false);
		AddRequirement(s.requirements, "blob", "gunpowder", "gunpowder", 8);
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
	}
}
