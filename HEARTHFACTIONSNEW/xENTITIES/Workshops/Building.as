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
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);

	{
		ShopItem@ s = addShopItem(this, "Builder Shop", "$buildershop$", "buildershop", Descriptions::buildershop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Demolition Shop", "$demolition$", "demolition", "Big boy booms.");
		AddRequirement(s.requirements, "blob", "mounted_bow", "Cannon", 1);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		AddRequirement(s.requirements, "blob", "gunpowder", "Gunpowder", 250);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Quarters", "$quarters$", "quarters", Descriptions::quarters);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Knight Shop", "$knightshop$", "knightshop", Descriptions::knightshop);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	//}
	{
		ShopItem@ s = addShopItem(this, "Archer Shop", "$archershop$", "archershop", Descriptions::archershop);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Boat Shop", "$boatshop$", "boatshop", Descriptions::boatshop);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::boatshop_wood);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Vehicle Shop", "$vehicleshop$", "vehicleshop", Descriptions::vehicleshop);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::vehicleshop_wood);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Smeltery", "$smeltery$", "smeltery", "Smelt materials in this shop.");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	//}
	{
		ShopItem@ s = addShopItem(this, "Graveyard", "$graveyard$", "graveyard", "Lay waste to the living world with this workshop.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "moonrock", "Moon Rock", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Rogue Shop", "$rogueshop$", "rogueshop", "An expensive shop for a sneaky rogue; able to transform into a unsuspecting bush!");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Technology Shop", "$techshop$", "techshop", "An expensive shop for building advanced technology.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Alchemy Engine", "$alchemyengine$", "alchemyengine", "A shop for brewing various liquids with the Alchemist.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Kitchen", "$kitchen$", "kitchen", "Cook up delecious meals!");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 150);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	//}
	{
		ShopItem@ s = addShopItem(this, "Storage Cache", "$storage$", "storage", Descriptions::storagecache);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Oven", "$oven$", "oven", "A warm cozy oven for cooking food.");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 350);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Gulag", "$gulag$", "gulag", "Own a slave in this stone cell.");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Slave Owner's Shop", "$slaveownersshop$", "slaveownersshop", "Become an Overseer, whip your slaves to work harder!");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Produce Storage", "$producestorage$", "producestorage", "For storing food.");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 150);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Mill", "$mill$", "mill", "Input buckets of grain and produce flour.");
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Transport Tunnel", "$tunnel$", "tunnel", Descriptions::tunnel);
	//	AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::tunnel_stone);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::tunnel_wood);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	//}
	{
		ShopItem@ s = addShopItem(this, "Temple of the Sun", "$templeofthesun$", "templeofthesun", "Become enlightened of the all-mighty Sun God's ways, the final step.");
		AddRequirement(s.requirements, "blob", "sunshard", "Sun Shard", 1);
		AddRequirement(s.requirements, "blob", "sunstone", "Sun Stone", 2);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 1000);
	}
	{
		ShopItem@ s = addShopItem(this, "Sun Shrine", "$sunshrine$", "sunshrine", "Concede your will to the all-mighty Sun God. Beware!");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "blob", "sunstone", "Sun Stone", 30);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
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
