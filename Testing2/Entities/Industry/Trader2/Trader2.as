// Builder Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Exchange 10 Gold for 250 Wood", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 10 );
	}

	{
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Exchange 50 Gold for 250 Stone", true );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for wood", "$mat_gold$", "mat_gold", "Exchange 1000 Wood for 50 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1000 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for stone", "$mat_gold$", "mat_gold", "Exchange 300 Stone for 50 Gold", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 300 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Gold for coins", "$mat_gold$", "mat_gold", "Buy 50 gold for 100 coins.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	/*
	{
		ShopItem@ s = addShopItem( this, "Mega Saw", "$megasaw$", "megasaw", "Buy Mega Saw for 500 coins.", true );
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
	}
	*/
	this.set_string("required class", "builder");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
