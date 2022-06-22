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
	AddIconToken("$clusterbomb$", "ClusterBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$trap$", "Trap.png", Vec2f(16, 16), 0);
	AddIconToken("$bombsatchel$", "BombSatchel.png", Vec2f(16, 16), 0);

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
	this.set_string("required class", "assassin");

	{
		ShopItem@ s = addShopItem(this, "Cluster Bomb", "$clusterbomb$", "mat_clusterbomb", "Explodes into smaller bombs", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Trap", "$trap$", "mat_trap", "Used for weakening enemies", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
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
