// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	int team_num = this.getTeamNum();

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::bomb);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterbomb);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", getTeamIcon("mine", "Mine.png", team_num, Vec2f(16, 16), 1), "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::mine);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::keg);
	}
	/*{
		ShopItem@ s = addShopItem(this, "Satchel", "$satchel$", "satchel", "little pouch of firestarting potential!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}*/
	{
		ShopItem@ s = addShopItem(this, "Minikeg", "$minikeg$", "minikeg", "small keg for smaller explosions!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "Minikeg Crate", "$mkcrate$", "mkcrate", "Explosive crate filled with minikegs\n Light at your own risk!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Fat Keg", "$fatkeg$", "fatkeg", "A fatter keg \n more powder means more explosion!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class"))
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
	}
}
