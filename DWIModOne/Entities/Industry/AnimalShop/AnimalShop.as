// Vehicle Workshop

#include "Requirements.as"
#include "Requirements_Tech.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(7, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Golden Chicken", "$goldenchicken$", "goldenchicken", "$goldenchicken$\n\n\nGenetically modified chicken that helps you glide!", false, false);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Shark", "$shark$", "shark", "$shark$\n\n\nThis vicious beast has a drive\nto kill that may never cease.\nGood for throwing.", false, true);
		s.crate_icon = 22;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		AddRequirement(s.requirements, "coin", "", "Coins", 180);
	}
	{
		ShopItem@ s = addShopItem(this, "Bison", "$bison$", "bison", "$bison$\n\n\n\nFeed him and he might be your friend <3", false, true);
		s.crate_icon = 21;
		AddRequirement(s.requirements, "coin", "", "Coins", 240);
	}
	{
		ShopItem@ s = addShopItem(this, "Necromancer", "$necromancer$", "necromancer", "$necromancer$\n\n\nAn angry soul once found guarding a princess.\nHe will defend you for a nominal fee.", false, true);
		s.crate_icon = 20;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
	}
	{
		ShopItem@ s = addShopItem(this, "Greg", "$greg$", "greg", "$greg$\n\n\nYou know exactly what this is.", false, false);
		s.crate_icon = 0;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
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
