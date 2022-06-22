﻿// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

s32 cost_arrows = 15;
s32 cost_waterarrows = 20;
s32 cost_firearrows = 30;
s32 cost_bombarrows = 50;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//load config
	if (getRules().exists("ctf_costs_config")) {
		cost_config_file = getRules().get_string("ctf_costs_config");
	}

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	cost_arrows = cfg.read_s32("cost_arrows", cost_arrows);
	cost_waterarrows = cfg.read_s32("cost_waterarrows", cost_waterarrows);
	cost_firearrows = cfg.read_s32("cost_firearrows", cost_firearrows);
	cost_bombarrows = cfg.read_s32("cost_bombarrows", cost_bombarrows);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 12));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-12, 0));

	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", Descriptions::arrows, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Bullets", "$mat_bullets$", "mat_bullets", Descriptions::bullets, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 2);
	}

	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, true);
        AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 3);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + Descriptions::dinghy);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 2);
	}

	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + Descriptions::longboat, false, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 4);
		s.crate_icon = 1;
	}

	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + Descriptions::warboat, false, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 8);
		s.crate_icon = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 4);
	}
	
	
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 6);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 8);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 2);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 8);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 16);
	}
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + Descriptions::catapult, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 12);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + Descriptions::ballista, false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 12);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + Descriptions::ballista_ammo, false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 6);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", Descriptions::ballista_ammo_upgrade_gold, false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 16);
	}
	{
		ShopItem@ s = addShopItem(this, "Scout Balloon", "$bomber$", "bomber", Descriptions::balloon, false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomber Bombs", "$mat_heavybomb$", "mat_heavybomb", Descriptions::bomb, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Gas Lantern", "$gaslantern$", "gaslantern", Descriptions::lantern, true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Sack of Coins", 1);
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null) {
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}