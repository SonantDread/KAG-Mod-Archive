// Genreic building

#include "Hitters.as";
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
	AddIconToken("$stonequarry$", "../Mods/Entities/Industry/CTFShops/Quarry/Quarry.png", Vec2f(40, 24), 4);
	//this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	this.Tag("builder always hit");

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Choose Worship");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem(this, "Life Altar", "$lifealtar$", "lifealtar", "Blesses your team with regeneration. (Stacks)");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Resupply Altar", "$resupplyaltar$", "resupplyaltar", "Blesses your team with boosted resupplies. (Stacks)");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Speed Altar", "$speedaltar$", "speedaltar", "Blesses your team with mobility. (Doesn't Stack)");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Wealth Altar", "$wealthaltar$", "wealthaltar", "Blesses your team with periodic coins. (Stacks)");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "War Altar", "$waraltar$", "waraltar", "Blesses your team's knights & archers with boosted damage. (Doesn't Stack)");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.05f)
	{
		this.getSprite().PlaySound("/dig_stone1", 1.7f, 1.0f);
	}

	if (customData == Hitters::sword)
	{
		damage *= 0.35f;
	}

	if (hitterBlob.getTeamNum() == this.getTeamNum())
	{
		damage *= 0.3f;
	}

	return damage;
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
			this.getSprite().PlaySound("/ConstructAltar.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
			caller.ClearMenus();
		}
	}
}