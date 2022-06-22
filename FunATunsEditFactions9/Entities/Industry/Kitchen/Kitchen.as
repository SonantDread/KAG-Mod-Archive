// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

s32 cost_bomb = 25;
s32 cost_waterbomb = 30;
s32 cost_keg = 120;
s32 cost_mine = 60;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Cooked Fish", "$cookfish$", "cookfish", "A Cooked Fish!", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 15);
		AddRequirement(s.requirements, "blob", "fishy", "Fish", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bread", "$bread$", "bread", "Bread", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 15);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 2);
	}
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}