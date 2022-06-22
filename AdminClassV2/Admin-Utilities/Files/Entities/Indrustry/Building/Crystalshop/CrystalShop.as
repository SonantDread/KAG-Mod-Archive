#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "GenericButtonCommon.as"

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 25, 94, 157));
	this.getSprite().getConsts().accurateLighting = true;
	

	//this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6,3));
	this.set_string("shop description", "An strange workshop which work with crystal.");
	this.set_u8("shop icon", 25);
	
		// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "sdkjfdsklfjklsdfj");

	

	{	 
		ShopItem@ s = addShopItem( this, "Wood", "$mat_wood$", "mat_wood", "Exchange 1 soul shard for 250 Wood", true );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystal Shard", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Stone", "$mat_stone$", "mat_stone", "Exchange 1 soul shard for 250 Stone", true );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystal Shard", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Crystal Torch", "$bluetorch$", "bluetorch", "This torch can't be extinguish with water. Incredible !", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 10 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystal Shard", 1 );
	}	
	{
		ShopItem@ s = addShopItem( this, "Crystal Place", "$crystalplace$", "crystalplace", "Similar as fireplace but the radius is more bigger and blue.", false, true);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 3 );
		s.crate_icon = 4;
	}
	{
		ShopItem@ s = addShopItem( this, "Gramophone", "$musicbox$", "musicbox", "Use disc for listen music.", true);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Disc", "$musicdisc$", "musicdisc", "Random disc.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Base Craft", "$basecraft$", "basecraft", "Flying vehicle propeled with the power of crystal", false, true);
		s.crate_icon = 4;
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 6 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 );
	}
	{
		ShopItem@ s = addShopItem( this, "Ovni", "$ovni$", "ovni", "Flying vehicle propeled with the power of crystal", false, true);
		s.crate_icon = 4;
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 5 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 );
	}
	{
		ShopItem@ s = addShopItem( this, "Mage", "$mage$", "mage", "Hire a Mage who will help you.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystal Shard", 1 );
		AddRequirement(s.requirements, "blob", "buiilder", "Dead Builder", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Heroic Soul", "$whitebook$", "randomBook", "Merge 3 Soul Shards into a random Heroic Soul.", true);
		AddRequirement( s.requirements, "coin", "", "Coins", 1000 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 5 );
	}
	this.set_string("required class", "sdkjfdsklfjklsdfj");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	u8 kek = caller.getTeamNum();	
	if (kek == 0)
	{
		this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
	}
}


								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		
		bool isServer = (getNet().isServer());
			
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		CBlob@ blob = getBlobByNetworkID( caller );
		CBlob@ tree;
		Vec2f pos = this.getPosition();
		
		string name = params.read_string();
		
		{
			if(name == "randomBook")
			{
				if (isServer)
				{
					int r = XORRandom(6);
					if (r == 0)
						server_CreateBlob("sburd", this.getTeamNum(), this.getPosition());
					else if (r == 1)
						server_CreateBlob("sdragoon", this.getTeamNum(), this.getPosition());
					else if (r == 2)
						server_CreateBlob("scrossbow", this.getTeamNum(), this.getPosition());
					else if (r == 3)
						server_CreateBlob("swizard", this.getTeamNum(), this.getPosition());
					else if (r == 4)
						server_CreateBlob("spyro", this.getTeamNum(), this.getPosition());	
					else if (r == 5)
						server_CreateBlob("sassassin", this.getTeamNum(), this.getPosition());						
				}			
			}		
		}
	}
}

