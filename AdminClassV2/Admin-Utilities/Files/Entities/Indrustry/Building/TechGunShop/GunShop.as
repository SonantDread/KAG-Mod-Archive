// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$mat_frag$", "FragGrenadeIcon.png", Vec2f(16, 16), 2);

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);

	//INIT COSTS
	InitCosts();
	AddIconToken( "$bigiron$", "bigicon.png", Vec2f(16,16), 0 );
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	
	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	{
		ShopItem@ s = addShopItem(this, "Lever-Action Rifle", "$leveraction$", "leveraction", "A lever-action rifle in 45-70. government bullets caliber, gun bullets.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		ShopItem@ s = addShopItem(this, "Frag Grenade", "$mat_frag$", "mat_fraggrenade", "Grenade, Ouch. Click to ignite.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Sigfried Assault Rifle", "$sigfried$", "sigfried", "Zum Schnappen bin ich immer bereit-schnipp schnapp im Land.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 55);
	}
	{
		ShopItem@ s = addShopItem(this, "Super Shotgun", "$supershotgun$", "supershotgun", "Oh baby!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 95);
	}
		{
		ShopItem@ s = addShopItem(this, "Thundertube", "$thundertube$", "thundertube", "BRING ON THE THUNDAH", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
		{
		ShopItem@ s = addShopItem(this, "Big iron", "$bigiron$", "bigiron", "A gun that can take down any outlaw loose and running.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
			{
		ShopItem@ s = addShopItem(this, "Small iron", "$smalliron$", "smalliron", "Big iron's little brother.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
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
	}
}