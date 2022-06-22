﻿// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
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
	if (getRules().exists("ctf_costs_config"))
	{
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
	this.set_Vec2f("shop menu size", Vec2f(10, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "archer");

	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", "archer arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", "stunning arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", "good on wood structures", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", "good on stone structures", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarArcherUniform", "$onestararcheruniform$", "onestararcheruniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarArcherUniform2", "$onestararcheruniform2$", "onestararcheruniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarArcherUniform", "$twostararcheruniform$", "twostararcheruniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestararcheruniform", "One Star Archer Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarArcherUniform2", "$twostararcheruniform2$", "twostararcheruniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestararcheruniform2", "One Star Archer Uniform", 1);
	}

	{
		ShopItem@ s = addShopItem(this, "ThreeStarArcherUniform", "$threestararcheruniform$", "threestararcheruniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostararcheruniform", "Two Star Archer Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "ThreeStarArcherUniform2", "$threestararcheruniform2$", "threestararcheruniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostararcheruniform2", "Two Star Archer Uniform", 1);
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
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
