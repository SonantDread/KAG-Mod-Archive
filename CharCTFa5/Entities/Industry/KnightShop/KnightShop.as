// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
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
	
	AddIconToken("$molotov$", "Molotov.png", Vec2f(16, 16), 0);

	//load config
	if (getRules().exists("ctf_costs_config"))
	{
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	cost_bomb = cfg.read_s32("cost_bomb_plain", cost_bomb);
	cost_waterbomb = cfg.read_s32("cost_bomb_water", cost_waterbomb);
	cost_mine = cfg.read_s32("cost_mine", cost_mine);
	cost_keg = cfg.read_s32("cost_keg", cost_keg);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(11, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", "small bomb", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", "stunning bomb", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "self triggered bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "large bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarKnightUniform", "$onestarknightuniform$", "onestarknightuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarKnightUniform2", "$onestarknightuniform2$", "onestarknightuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarKnightUniform", "$twostarknightuniform$", "twostarknightuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestarknightuniform", "One Star Knight Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarKnightUniform2", "$twostarknightuniform2$", "twostarknightuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestarknightuniform2", "One Star Knight Uniform", 1);
	}

	{
		ShopItem@ s = addShopItem(this, "ThreeStarKnightUniform", "$threestarknightuniform$", "threestarknightuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostarknightuniform", "Two Star Knight Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "ThreeStarKnightUniform2", "$threestarknightuniform2$", "threestarknightuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostarknightuniform2", "Two Star Knight Uniform", 1);
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
