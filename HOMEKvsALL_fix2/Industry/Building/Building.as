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
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);
		AddIconToken("$buildershop2$", "BuilderShop.png", Vec2f(40, 24), 0);

	{
		ShopItem@ s = addShopItem(this, "Builder Shop", "$buildershop2$", "buildershop", Descriptions::buildershop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::buildershop_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Quarters", "$quarters$", "quarters", Descriptions::quarters);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::quarters_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Knight Shop", "$knightshop$", "knightshop", Descriptions::knightshop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::knightshop_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Archer Shop", "$archershop$", "archershop", Descriptions::archershop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::archershop_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Boat Shop", "$boatshop$", "boatshop", Descriptions::boatshop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::boatshop_wood);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::boatshop_gold);
	}
	{
		ShopItem@ s = addShopItem(this, "Vehicle Shop", "$vehicleshop$", "vehicleshop", Descriptions::vehicleshop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::vehicleshop_wood);
		// AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::vehicleshop_gold);
	}
	{
		ShopItem@ s = addShopItem(this, "Storage Cache", "$storage$", "storage", Descriptions::storagecache);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::storage_stone);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::storage_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Transport Tunnel", "$tunnel$", "tunnel", Descriptions::tunnel);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::tunnel_stone);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::tunnel_wood);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::tunnel_gold);
	}
	// AddIconToken("$kegshop2$", "KEGShop.png", Vec2f(40, 24), 0);
	// {
	// 	ShopItem@ s = addShopItem(this, "King's Explosive Groceries", "$kegshop2$", "kegshop2", "WELCOME TO THE KING'S EXPLOSIVE GROCERIES!\nKEGS 50% OFF FOR A LIMITED TIME!");
	// 	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	// 	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	// }
	// AddIconToken("$flyshop$", "FlyShop", Vec2f(40, 24), 0);
	// {
	// 	ShopItem@ s = addShopItem(this, "Aerial Siege", "$flyshop$", "flyshop", "Buy some flying stuff");
	// 	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	// 	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
	// }
	AddIconToken("$scrollshop$", "ScrollShop.png", Vec2f(40, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Shop with Homekian Scrolls", "$scrollshop$", "scrollshop", "Scrolls created by the Church of Homek.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
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
