// ArcherShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "Costs.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("put_migrant");

	AddIconToken("$put_migrant$", "Entities/Characters/Migrant/MigrantIcon.png", Vec2f(18, 18), 0);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12);

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_string("required class", "archer");

	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", Descriptions::arrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::arrows);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterarrows);
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::firearrows);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::bombarrows);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	this.set_Vec2f("class offset", Vec2f(-5, 0));

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(5, 0));
	}

	CBlob@ carried = caller.getCarriedBlob();
	CBitStream params;
	if (carried !is null && carried.hasTag("migrant"))
	{
		this.set_Vec2f("class offset", Vec2f(-5, 2));
		if (caller.getConfig() == this.get_string("required class"))
		{
			this.set_Vec2f("shop offset", Vec2f(0, 2));
		}
		else
		{
			this.set_Vec2f("shop offset", Vec2f(5, 2));
		}

		params.write_u16(carried.getNetworkID());
		caller.CreateGenericButton("$put_migrant$", Vec2f(0, -6), this, this.getCommandID("put_migrant"), "Train Archer", params);
	}

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
	else if (cmd == this.getCommandID("put_migrant"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			if (getNet().isServer())
			{
				caller.server_DetachFromAll();
				caller.server_Die();

				CBlob@ blob = server_CreateBlob("archerbot", this.getTeamNum(), this.getPosition());
			}

			this.getSprite().PlaySound("/ChaChing.ogg");
		}
	}
}