#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit( CBlob@ this ){
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 3));
	this.set_string("shop description", "Create");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	
	AddIconToken("$stone_hachet_icon$", "Axe_Icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Hachet", "$stone_hachet_icon$", "hachet", "A simple axe for splitting logs and heads.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		s.spawnNothing = true;
	}
	AddIconToken("$mallet_icon$", "Hammer_Icon.png", Vec2f(24, 24), 3);
	{
		ShopItem@ s = addShopItem(this, "Mallet", "$mallet_icon$", "mallet", "A hammer used for building simple wooden structures.", false);
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		s.spawnNothing = true;
	}
	AddIconToken("$spade_icon$", "Pole_Icon.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Spade", "$spade_icon$", "spade", "A spade that excels at digging dirt.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		s.spawnNothing = true;
	}
	AddIconToken("$spear_icon$", "Pole_Icon.png", Vec2f(24, 24), 2);
	{
		ShopItem@ s = addShopItem(this, "Spear", "$spear_icon$", "spear", "A spear for low tech combat.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
		s.spawnNothing = true;
	}
	AddIconToken("$ward_icon$", "Ward.png", Vec2f(8, 17), 0);
	{
		ShopItem@ s = addShopItem(this, "Ward", "$ward_icon$", "ward", "A strange ward that provides auras when infused and powered by a gem.", false);
		s.spawnNothing = true;
	}
	AddIconToken("$stick_fire_icon$", "StickFire.png", Vec2f(16, 17), 11);
	{
		ShopItem@ s = addShopItem(this, "Fire", "$stick_fire_icon$", "stickfire", "A fire for cooking food and smelting metals.", false);
		s.spawnNothing = true;
	}
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		if(isServer){
			caller.server_Pickup(server_CreateBlob(name,caller.getTeamNum(),caller.getPosition()));
			this.server_Die();
		}
	}
}