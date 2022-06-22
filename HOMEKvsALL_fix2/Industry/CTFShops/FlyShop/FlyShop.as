// BoatShop.as

#include "Requirements.as"
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
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	AddIconToken("$bomber$", "Balloon.png",Vec2f(48, 64), 0);
	{
		ShopItem@ s = addShopItem(this, "Bomber", "$bomber$", "bomber", "Flying thing, you can grapple it!", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	
	AddIconToken("$airship$", "Airship.png",Vec2f(96, 64), 0);
	{
		ShopItem@ s = addShopItem(this, "Airship", "$airship$", "airship", "Bigger flying thing, can also grapple it.", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 300);
	}
	
	/*
	AddIconToken("$knockbackbomb$", "MatKnockbackBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Knockback Bomb", "$knockbackbomb$", "mat_knockbackbombs", "A bomb that explodes with extra concussive force.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	
	AddIconToken("$firebomb$", "MatFireBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Fire Bomb", "$firebomb$", "mat_firebombs", "A bomb which sets the area around it on fire upon exploding.\nExplodes on contact.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}*/
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