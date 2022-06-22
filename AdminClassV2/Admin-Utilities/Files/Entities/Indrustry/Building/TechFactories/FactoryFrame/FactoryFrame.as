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
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.Tag("builder always hit");

	//INIT COSTS
	InitCosts();

	AddIconToken( "$factoryjeremy$", "jeremy.png", Vec2f(32,16), 0 );
	AddIconToken( "$factorypolymer$", "Material_Polymer.png", Vec2f(16,16), 3 );
	AddIconToken( "$factorystergun$", "stergun.png", Vec2f(32,16), 0 );
	AddIconToken( "$factorybeer$", "Beer.png", Vec2f(16,16), 0 );
	AddIconToken( "$factorysteel$", "steelinv.png", Vec2f(16,16), 0 );
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem(this, "Jeremy Factory", "$factoryjeremy$", "factoryjeremy", "Lay on the lumber with this factory-made SMG.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Polymer factory", "$factorypolymer$", "factorypolymer", "A factory that manufactures polymer.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Ster Gun Factory", "$factorystergun$", "factorystergun", "Make your enemies swallow entire bananas with this factory-made rifle.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Beer Factory", "$factorybeer$", "factorybeer", "Take a shot of dutch courage, though I have not a clue as of how this works.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Steel Refinery", "$factorysteel$", "factorysteel", "Smash stone into steel that can be used for high-grade factories.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Advanced Factory Frame", "$factoryadvancedframe$", "factoryadvancedframe", "A Frame that can be used for high-grade factories.");
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
