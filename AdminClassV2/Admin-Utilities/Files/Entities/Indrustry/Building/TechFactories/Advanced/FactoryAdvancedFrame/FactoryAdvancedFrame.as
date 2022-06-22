// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	AddIconToken("$stonequarry$", "Quarry.png", Vec2f(40, 24), 4);
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.Tag("builder always hit");

	//INIT COSTS
	InitCosts();

	AddIconToken( "$factoryadvancedbergman$", "bergman.png", Vec2f(32,16), 0 );
	AddIconToken( "$factoryadvanceddynamite$", "DynamiteIcon.png", Vec2f(16,16), 0 );
	AddIconToken( "$factoryadvancedquarry$", "PolymerFactoryIcon.png", Vec2f(16,16), 0 );
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem(this, "Bergman Factory", "$factoryadvancedbergman$", "factoryadvancedbergman", "Obliterate anything in your path with this factory-made assault rifle.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Dynamite Factory", "$factoryadvanceddynamite$", "factoryadvanceddynamite", "JC a bomb!");
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Quarry", "$factoryelectric$", "factoryelectric", "It's a electric luigi, you didn't make it.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 50);
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
