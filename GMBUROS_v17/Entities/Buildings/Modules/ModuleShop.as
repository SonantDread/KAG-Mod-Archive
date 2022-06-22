// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-50); //background
	//this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 15);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$chair_icon$", "Chair.png", Vec2f(16, 16), 1);
	{
		ShopItem@ s = addShopItem(this, "Chair", "$chair_icon$", "module_chair", "A place to rest your legs.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
	}
	AddIconToken("$loom_icon$", "Loom.png", Vec2f(16, 16), 1);
	{
		ShopItem@ s = addShopItem(this, "Loom", "$loom_icon$", "loom", "A simple machine to create textiles.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	AddIconToken("$leather_rack_icon$", "LeatherRack.png", Vec2f(16, 16), 4);
	{
		ShopItem@ s = addShopItem(this, "Leather Rack", "$leather_rack_icon$", "leather_rack", "A rack for turning corpses into leather.");
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
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
}