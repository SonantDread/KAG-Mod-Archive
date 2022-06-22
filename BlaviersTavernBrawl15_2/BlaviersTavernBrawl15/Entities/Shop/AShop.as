// Tavernbrawl Shop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 5));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// TODO: Better information + icons like the vehicle shop, also make boats not suck
	{
		ShopItem@ s = addShopItem(this, "Bombs", "$mat_bombs$", "mat_bombs", "Used to blow people up.");
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Waterbomb", "$mat_waterbombs$", "mat_waterbombs", "Stun yer' mates.");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "A big boomer, be careful!");
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "Molotov", "$molotov$", "molotov", "Set fire to yer' mates!");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Firemine", "$firemine$", "firemine", "A mine that explodes with flames.");
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Slidemine", "$slidemine$", "slidemine", "Slide it across the ground!");
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "A sneaky mine, vonerable to the keen eye.");
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Mini Mine", "$minimine$", "minimine", "A tiny mine, dealing reduced damage.");
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Shield", "$shield$", "shield", "Block those pesky arrows!");
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, "Waterarrows", "$mat_waterarrows$", "mat_waterarrows", "Stun the bad guys.");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Firearrows", "$mat_firearrows$", "mat_firearrows", "Flaming arrow, will set fire!");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Bombarrow", "$mat_bombarrows$", "mat_bombarrows", "A bomb on a stick, deadly.");
		AddRequirement(s.requirements, "coin", "", "Coins", 55);
	}
	{
		ShopItem@ s = addShopItem(this, "Burger", "$food$", "food", "Delicious food to keep you fighting.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "Grind up your foes with this piece of machinery.");
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	{
		ShopItem@ s = addShopItem(this, "Cannon", "$mounted_bow$", "mounted_bow", "Heavy cannon to bombard your foes.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "Propel objects into the sky!");
		AddRequirement(s.requirements, "coin", "", "Coins", 160);
	}
	{
		ShopItem@ s = addShopItem(this, "Big Keg", "$bigkeg$", "bigkeg", "Largest boomer in the game!");
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
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