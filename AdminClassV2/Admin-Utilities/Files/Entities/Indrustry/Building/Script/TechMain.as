// Technologie Main

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"

const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.Tag("builder always hit");

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);
	//INIT COSTS
	//InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "scout");
	this.Tag(SHOP_AUTOCLOSE);
	
	


	{
		ShopItem@ s = addShopItem(this, "Gun Shop", "$gunshop$", "gunshop", "A shop where you can purchase various firearms.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone",100);
	}
	{
		ShopItem@ s = addShopItem(this, "Quarters", "$kwartier$", "kwartier", "A bunk bed for soldiers to rest in.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood",100);
	}
	{
		ShopItem@ s = addShopItem(this, "Garage", "$garage$", "garage", "A shop where you can buy various vehicles and mounted firearms.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood",100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone",100);
	}
	{
		ShopItem@ s = addShopItem(this, "Factory Frame", "$factoryframe$", "factoryframe", "A Frame which allows for factories of all different types to be built within.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone",100);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Crafting Workshop", "$craftshop$", "craftshop", "A workshop that allows for making various items using materials.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood",100);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",50);
	}
	{
		ShopItem@ s = addShopItem(this, "Burner", "$kiln$", "kiln", "Burn wood for make coal.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood",10);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone",150);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
		this.set_bool("shop available", !builder_only || caller.getName() == "builder");
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();

			// open factory upgrade menu immediately
			if (item.getName() == "factory")
			{
				CBitStream factoryParams;
				factoryParams.write_netid(caller.getNetworkID());
				item.SendCommand(item.getCommandID("upgrade factory menu"), factoryParams);
			}
		}
	}
}
