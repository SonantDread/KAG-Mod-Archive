﻿// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_ballista_ammo_upgrade_gold = 60;
const s32 cost_bomber = 50;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);


	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 6));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Ultimate Flypult", "$flypult$", "flypult", "$flypult$\n\n\n" + descriptions[5], false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_catapult);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 2500);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista_ammo);
	}
  {
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_catapult);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
	}
	{
		ShopItem@ s = addShopItem(this, "Balloon", "$bomber$", "bomber", "", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_bomber);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 1000);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 1000);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 60);
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
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
		}
	}
}
