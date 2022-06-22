// TechShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);


	{
		ShopItem@ s = addShopItem(this, "Cannon", "$mounted_bow$", "mounted_bow", "Launch cannonballs straight into your enemies!", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Cannon Balls", "$cannonballs$", "cannonballs", "Ammo for your cannon!", false);
		AddRequirement(s.requirements, "blob", "gunpowder", "Gunpowder", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "blob", "gunpowder", "Gunpowder", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Gunpowder", "$gunpowder$", "gunpowder", "Craft 2 gunpowder, used to make explosives!", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 20);
		s.spawnNothing = true;
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

		if (!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}

			if (name == "gunpowder")
			{
				CBlob@ blob = server_CreateBlobNoInit('gunpowder');

				if (blob !is null)
				{
					blob.Tag('custom quantity');
					blob.Init();
					blob.server_SetQuantity(2);
					blob.setPosition(this.getPosition());
				}
			}
		}
	}
}