﻿// Genreic building

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2,5));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);

	 
	AddIconToken( "$warboatfactory$", "warboatfactory.png", Vec2f(32,32), 0 );
    AddIconToken( "$sharknursery$", "sharknursery.png", Vec2f(32,32), 0 );
	AddIconToken( "$boatfactory$", "boatfactory.png", Vec2f(32,16), 0 );
	
	this.Tag(SHOP_AUTOCLOSE);
	
	
	{ 
		ShopItem@ s = addShopItem( this, "Shark Nursery", "$sharknursery$", "sharknursery", descriptions[14] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 );
		AddRequirement( s.requirements, "no more", "sharknursery", "Shark Nursery", 3 );

	}

	{
		ShopItem@ s = addShopItem( this, "Boat factory", "$boatfactory$", "boatfactory", "Latest dinghy model is produced here!" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
        AddRequirement( s.requirements, "no more", "boatfactory", "Boat factory", 4 );
	}
	{
		ShopItem@ s = addShopItem( this, "WarBoat factory", "$warboatfactory$", "warboatfactory", "Warboat factory" );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
        AddRequirement( s.requirements, "no more", "boatfactory", "Boat factory", 4 );
	}
	
	
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", !builder_only || caller.getName() == "builder" );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();	
	//if (cmd == this.getCommandID("shop buy"))
	//{
	//	u16 callerID;
	//	if (!params.saferead_u16(callerID))
	//		return;
	//	bool spawnToInventory = params.read_bool();
	//	bool spawnInCrate = params.read_bool();
	//	bool producing = params.read_bool();
	//	string blobName = params.read_string();		
	//	u8 s_index = params.read_u8();

	//	CBlob@ caller = getBlobByNetworkID( callerID );
	//	if (caller !is null)
	//	{				
	//		this.getSprite().PlaySound("/Construct.ogg" ); 
	//		this.getSprite().getVars().gibbed = true;
	//		this.server_Die();

	//		// open factory upgrade menu immediately
	//		if (blobName = "factory")
	//		{
	//			if (cmd == this.getCommandID("upgrade factory menu"))
	//			{
	//				CBlob@ caller = getBlobByNetworkID( params.read_u16() );
	//		}
	//	}
	//} 
	//else 
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		CBlob@ item = getBlobByNetworkID( params.read_netid() );
		if (item !is null && caller !is null)
		{				
			this.getSprite().PlaySound("/Construct.ogg" ); 
			this.getSprite().getVars().gibbed = true;
			this.server_Die();

			// open factory upgrade menu immediately
			if (item.getName() == "factory")
			{
				CBitStream factoryParams;
				factoryParams.write_netid( caller.getNetworkID() );
				item.SendCommand( item.getCommandID("upgrade factory menu"), factoryParams );
			}
		}
	}
}
   
// leave a pile of wood	after death
void onDie(CBlob@ this)
{
	/*if (getNet().isServer()) //TODO: Maybe do this if teamkilled.
	{
		CBlob@ blob = server_CreateBlob( "mat_wood", this.getTeamNum(), this.getPosition() );
		if (blob !is null)
		{
			blob.server_SetQuantity( COST_WOOD_BUILDING/2 );
		}
	}*/
}
