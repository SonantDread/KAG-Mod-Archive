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
	this.Tag("builder always hit");

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);
	AddIconToken( "$herman$", "hermaninv.png", Vec2f(32,32), 0 );
	AddIconToken( "$bison$", "bisoninv.png", Vec2f(32,32), 0 );
	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 8));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	{
		ShopItem@ s = addShopItem(this, "Military Caraja", "$shitcar$", "shitcar", "An armed car for you to enjoy driving and shooting.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 150);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 60);
		AddRequirement(s.requirements, "coin", "", "Coins", 2500);		
	}
	{
		ShopItem@ s = addShopItem(this, "Jef & Ry", "$jeffery$", "jeffery", "A poor quality canon and average armor. Here is the perfect tank for thrifty.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 250);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 130);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 4500);		
	}
	{
		ShopItem@ s = addShopItem(this, "Sergey Tank", "$sergey$", "sergey", "The sergey is old but its power is there. Don't underestimate it !", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 600);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 130);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 180);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 10000);		
	}
	{
		ShopItem@ s = addShopItem(this, "Herman Tank", "$pantserwagen$", "pantserwagen", "A Marty-made high-grade tank vehicle.", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 400);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 400);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 350);
		AddRequirement(s.requirements, "coin", "", "Coins", 12000);		
	}
	{
		ShopItem@ s = addShopItem(this, "Herman Tank", "$herman$", "herman", "Do you like spending more than you want? This tank has nothing more than the others. Except its appearance, make others tremble with your charisma !", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 650);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 200);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 600);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 350);
		AddRequirement(s.requirements, "coin", "", "Coins", 20000);		
	}
	{
		ShopItem@ s = addShopItem(this, "Advanced Mortar", "$mortar$", "mortar", "Who wouldn't like to pound these opponents without moving from their base ?", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 600);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 600);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 350);
		AddRequirement(s.requirements, "blob", "mat_elec", "Electronics", 550);
		AddRequirement(s.requirements, "coin", "", "Coins", 11000);		
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy Shells", "$mat_bolts$", "mat_bolts", "Heavy Bombs used for Artillery and Tank cannons.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 5);
		AddRequirement(s.requirements, "blob", "mat_polymer", "Polymer", 3);
	}
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}