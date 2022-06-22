// Gunshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

s32 cost_magnum = 25;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(17, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	{
		ShopItem@ s = addShopItem(this, "Magnum", "$magnum$", "magnum", "Damage: 6\nAmmo: 6/32\nRate: 5", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1000);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50);

	}
	{
		ShopItem@ s = addShopItem(this, "AK47", "$ak47$", "ak47", "Damage: 3\nAmmo: 64/250\nRate: 9*", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1250);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Colt1911", "$colt1911$", "Colt1911", "Damage: 3\nAmmo: 6/64\nRate: 7", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 600);
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "GoldenGun", "$goldengun$", "goldengun", "Damage: 10\nAmmo: 6/64\nRate: 3", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1000);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "TommyGun", "$tommygun$", "tommygun", "Damage: 3.5\nAmmo: 30/250\nRate: 10*", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1250);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$shotgun$", "shotgun", "Damage: 2.5\nAmmo: 2/32\nRate: 4*", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1250);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "M1", "$m1$", "m1", "Damage: 3\nAmmo: 8/160\nRate: 7*", true);
		AddRequirement(s.requirements, "coin", "coins", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "ChaChing.ogg");
	}
}