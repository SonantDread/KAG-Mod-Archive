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

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);
	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
		/*{
		ShopItem@ s = addShopItem(this, "TNT", "$mat_tnt$", "mat_tnt", "Bastard!", true);
		AddRequirement(s.requirements, "blob", "mat_dynamite", "Dynamite", 4);
		AddRequirement(s.requirements, "blob", "mat_tape", "Duct Tape", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Anti-tank Grenade", "$mat_antitank$", "mat_antitank", "Does major damage to vehicles, can instagib if placed inside the vehicle.", true);
		AddRequirement(s.requirements, "blob", "mat_dynamite", "Dynamite", 2);
		AddRequirement(s.requirements, "blob", "mat_fraggrenade", "Frag Grenade", 1);
		AddRequirement(s.requirements, "blob", "mat_tape", "Duct Tape", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Shit Gun", "$shitgun$", "shitgun", "A gun made of leftover chewing gum and a branch.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Ster Gun MK II", "$stergunmk2$", "stergunmk2", "An upgrade that increases the damage and bullet speed.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 10);
		AddRequirement(s.requirements, "blob", "mat_tape", "Duct Tape", 1);
		AddRequirement(s.requirements, "blob", "stergun", "Ster Gun", 1);
	}
		{
		ShopItem@ s = addShopItem(this, "Jeremy Submachine Gun MK II", "$jeremymk2$", "jeremymk2", "An upgrade that increases the firerate and ammo capacity.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 10);
		AddRequirement(s.requirements, "blob", "mat_tape", "Duct Tape", 1);
		AddRequirement(s.requirements, "blob", "jeremy", "Jeremy Submachine Gun", 1);
	}
		{
		ShopItem@ s = addShopItem(this, "Ultra Shotgun", "$ultrashotgun$", "ultrashotgun", "A ridiculous quad barrel shotgun to rip and tear through your enemies.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 20);
		AddRequirement(s.requirements, "blob", "mat_tape", "Duct Tape", 1);
		AddRequirement(s.requirements, "blob", "supershotgun", "Super Shotgun", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy Shells", "$mat_bolts$", "mat_bolts", "Heavy Bombs used for Artillery and Tank cannons.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 20);
		AddRequirement(s.requirements, "blob", "mat_dynamite", "Dynamite", 1);
	}*/
	{
		ShopItem@ s = addShopItem(this, "UPF Peacekeeper", "$sentry$", "sentry", "Consumes bullets while firing.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 150);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystalshard", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 100);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 50);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Laser Weapon System (Missile)", "$lws$", "lws", "Consumes battery while firing. Tracking missiles.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 250);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystalshard", 1);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 150);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Laser Weapon System (Aircraft)", "$lws_aircraft$", "lws_aircraft", "Consumes battery while firing. Tracking aircraft and heavy armoured vehicle", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 250);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystalshard", 1);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 200);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 120);
	}
	{
		ShopItem@ s = addShopItem(this, "Laser Weapon System (Evolved)", "$lws_missile$", "lws_missile", "Consumes battery while firing. Tracking missiles and aircraft but performance decrease.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 250);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystalshard", 2);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 150);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 2000);
	}
	{
		ShopItem@ s = addShopItem(this, "SAM Launcher", "$sam$", "sam", "Consumes rocket while firing.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 500);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystalshard", 1);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 400);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 200);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Tesla Coil", "$zapper$", "zapper", "consumes batteries during electric shocks.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 175);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		AddRequirement(s.requirements, "blob", "mat_cementing", "Cementing Paste", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", " Polymer", 75);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "UPF Gatling Ammo", "$mat_gatlingammo$", "mat_gatlingammo", "Especially for UPF Peacekeeper.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 10);
		AddRequirement(s.requirements, "COINS", "", "Coins", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Battery", "$mat_battery$", "mat_battery", "Turn on your defense.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 25);
		AddRequirement(s.requirements, "blob", "mat_elec", " Electronics", 5);
		AddRequirement(s.requirements, "COINS", "", "Coins", 10);
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}