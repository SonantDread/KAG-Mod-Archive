﻿// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n", false, true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n", false, true);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n", false, false);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 160);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 80);
	}
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		s.spawnNothing = true;
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
		if(isServer){
			
			if (name == "air_castle")
			{
				server_CreateBlob("air_castle", this.getTeamNum(), this.getPosition()+Vec2f(0,28));
			}
			else
			{
				server_CreateBlob(name, this.getTeamNum(), this.getPosition());
			}
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ front = this.addSpriteLayer("front", this.getFilename() , 80, 56, blob.getTeamNum(), blob.getSkinNum());

	if (front !is null)
	{
		Animation@ anim = front.addAnimation("default", 0, false);
		anim.AddFrame(1);
		front.SetRelativeZ(200);
	}
}