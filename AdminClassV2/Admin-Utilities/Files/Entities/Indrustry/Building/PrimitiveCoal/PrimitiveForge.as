// Primitive Forge logic

#include "Requirements.as";
#include "ShopCommon.as";
#include "CheckSpam.as";						
#include "Costs.as"


void onInit( CBlob@ this )
{	 
	//this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.SetLight(true);
	

	//this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3,2));
	this.set_string("shop description", "Burn for make material.");
	this.set_u8("shop icon", 25);
	
{
	{	 
		ShopItem@ s = addShopItem( this, "Coal", "$mat_coal$", "mat_coal-5", "Burn wood for get coal.", true );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Steel", "$mat_steel$", "mat_steel-2", "Refine iron for steel (Coal).", true );
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron Ore", 5 );
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 5 );
	}
	{
		ShopItem@ s = addShopItem( this, "Cementing Paste", "$mat_cementing$", "mat_cementing-3", "Make Cementing Paste (Wood).", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 5 );
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Polymer", "$mat_polymer$", "mat_polymer-5", "Make Polymer.", true );
		AddRequirement( s.requirements, "blob", "material_powder_crystal", "Crystal Powder", 5 );
		AddRequirement( s.requirements, "blob", "mat_org", "Organic Waste", 10 );
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 10 );		
	}
	{
		ShopItem@ s = addShopItem( this, "Bedrock Powder", "$mat_bedrock$", "mat_bedrock-50", "Get Bedrock powder.", true );
		AddRequirement( s.requirements, "blob", "material_powder_crystal", "Crystal Powder", 10 );
		AddRequirement( s.requirements, "blob", "mat_org", "Organic Waste", 30 );
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron Ore", 25 );
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 50 );
		
	}
}
/*{
	{
		ShopItem@ s = addShopItem( this, "Steel", "$mat_steel$", "mat_steel-2", "Refine iron for steel (Wood)", true );
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron Ore", 5 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 20 );
	}


	{
		ShopItem@ s = addShopItem( this, "Cementing Paste", "$mat_cementing$", "mat_cementing-3", "Make Cementing Paste (Wood)", true );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 5 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
	}
}*/
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("KnifeStab.ogg");
		
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (isServer())
		{
			string[] spl = name.split("-");
			
			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null && callerBlob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}