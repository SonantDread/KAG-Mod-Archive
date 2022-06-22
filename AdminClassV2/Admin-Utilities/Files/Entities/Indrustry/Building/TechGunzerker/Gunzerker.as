// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//ICONS
	//AddIconToken("$m1$", "M1.png", Vec2f(16, 8), 0);
	//AddIconToken("$tommy$", "Tommy.png", Vec2f(16, 8), 0);
	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(6, 7));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	{
		ShopItem@ s = addShopItem(this, "Worn pistol", "$shitgun$", "shitgun", "Created from junk, this revolver can explode in your hand at any time.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Light revolver", "$smalliron$", "smalliron", "Could you shoot faster than your.. Hello, what do you mean by copyri ... *Bang*", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",3);
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy revolver", "$bigiron$", "bigiron", "As heavy as lond to recharge.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",4);
	}
	{
		ShopItem@ s = addShopItem(this, "Lever Action", "$leveraction$", "leveraction", "You must reload after every shot.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",5);
	}
	{
		ShopItem@ s = addShopItem(this, "Maschinenpistole 40", "$mp40$", "mp40", "Uncontrolable gun, you are warn !", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",2);
	}
	{
		ShopItem@ s = addShopItem(this, "Maschinenpistole 18", "$mp18$", "mp18", "Personnal Defense Weapon.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",6);
	}
	{
		ShopItem@ s = addShopItem(this, "Jeremy", "$jeremy$", "jeremy", "Personnal Defense Weapon.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",10);
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$supershotgun$", "supershotgun", "An heavy weapon", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",11);
	}
	{
		ShopItem@ s = addShopItem(this, "Winchester M1897", "$trenchgun$", "trenchgun", "An Heavy shotgun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",20);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",12);
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun MK2", "$ultrashotgun$", "ultrashotgun", "The MK2 of shotgun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1050);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel", 45);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",17);
	}
	{
		ShopItem@ s = addShopItem(this, "Sturmgewehr 44", "$stg44$", "stg44", "An heavy gun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 600);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",6);
	}
	{
		ShopItem@ s = addShopItem(this, "Thunder Tube", "$thundertube$", "thundertube", "Play with this minigun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 8500);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",50);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",14);
	}
	{
		ShopItem@ s = addShopItem(this, "Lewis automatic rifle", "$lewisgun$", "lewisgun", "The Lewis Gun is a First World War–era light machine gun", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 3000);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",18);
	}	
	{
		ShopItem@ s = addShopItem(this, "Kalachnikov", "$ak47$", "ak47", "Do you like to steal from the weak and satisfy your ego? So we can say that this weapon can be suitable for you", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 500);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",5);
	}
	{
		ShopItem@ s = addShopItem(this, "Sig fried", "$sigfried$", "sigfried", "Automatic weapon, beware of recoil", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 650);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",7);
	}
	{
		ShopItem@ s = addShopItem(this, "Bergman Gun", "$bergman$", "bergman", "Medium rate of fire for comfortable support. Why want more ?", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",14);
	}
	{
		ShopItem@ s = addShopItem(this, "Jeremy MK2", "$jeremymk2$", "jeremymk2", "More powerfull", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",15);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",16);
	}
	{
		ShopItem@ s = addShopItem(this, "[Not Repertoried ID]", "$sasha$", "sasha", "What the..", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 3000);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",75);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",18);
	}	
	{
		ShopItem@ s = addShopItem(this, "Ster Gun", "$stergun$", "stergun", "Looks like an sniper but without Scoop.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",15);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",16);
	}
	{
		ShopItem@ s = addShopItem(this, "Ster Gun MK2", "$stergunmk2$", "stergunmk2", "The MK2 of Ster Gun.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",30);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",18);
	}
	{
		ShopItem@ s = addShopItem(this, "Barrett M95", "$m95$", "m95", "The Barrett M95, better known as the M95, is a bolt-action sniper rifle.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2500);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",125);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",8);
	}
	{
		ShopItem@ s = addShopItem(this, "M1 Garand", "$m1$", "m1", "The M1 Garand or M1 Rifle[nb 1] is a .30-06 caliber semi-automatic rifle that was the standard U.S.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 6000);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel",100);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",10);
	}	
	{
		ShopItem@ s = addShopItem(this, "Super Sheriff Weapon", "$martyrifle$", "martyrifle", "LOL YOU REALLY THINK YOU CAN BUY IT ?", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30000000000);
		AddRequirement(s.requirements, "blob", "hayrock", "Hayrock",1800000000);
	}
	
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}