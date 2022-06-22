// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GetPlayerData.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	//this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 15);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$table_icon$", "Table.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Table", "$table_icon$", "table", "A multiple purpose table used for mundane things such as surgery and crafting.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	AddIconToken("$bed_icon$", "Bed.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Bed", "$bed_icon$", "bed_frame", "A bed for SSS: sleeping, sex and surgery.");
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 2);
	}
	AddIconToken("$chest_icon$", "WoodenChest.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Chest", "$chest_icon$", "wooden_chest", "A simple unlocked storage.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
		this.set_bool("shop available", true);
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
		if (item !is null && caller !is null){
			if(isServer)item.server_setTeamNum(getPlayerBlobColour(caller));
			
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
}