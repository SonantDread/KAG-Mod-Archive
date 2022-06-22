// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();
	
	this.Tag("builder always hit");

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		AddIconToken("$gem_healer_icon$", "GemHealer.png", Vec2f(24, 24), 4);
		ShopItem@ s = addShopItem(this, "Gem Healer", "$gem_healer_icon$", "gem_healer", "A building that heals allies every second when gems are inserted.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		AddIconToken("$gem_laser_icon$", "GemLaserIcon.png", Vec2f(24, 24), 0);
		ShopItem@ s = addShopItem(this, "Gem Laser", "$gem_laser_icon$", "gem_laser", "A building that fires lasers at enemies when gems are inserted.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

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
			caller.ClearMenus();
		}
	}
}