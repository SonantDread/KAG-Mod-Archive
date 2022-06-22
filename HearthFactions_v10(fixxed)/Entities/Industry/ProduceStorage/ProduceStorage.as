// ProduceStorage.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Carrot Seed", "$carrotseed$", "carrotseed", "Plant it on grass.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coin", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lettuce Seed", "$lettuceseed$", "lettuceseed", "Plant it on grass.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coin", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Corn Seed", "$cornseed$", "cornseed", "Plant it on grass.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "coin", "", "Coin", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Carrot for Two Carrot Seeds", "$carrotseed$", "carrotseed", "Refine a carrot into two carrot seeds.", false);
		AddRequirement(s.requirements, "blob", "carrot", "Carrot", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Lettuce for Two Lettuce Seeds", "$lettuceseed$", "lettuceseed", "Refine a lettuce into two lettuce seeds.", false);
		AddRequirement(s.requirements, "blob", "lettuce", "Lettuce", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Corn for Two Corn Seeds", "$cornseed$", "cornseed", "Refine a corn into two corn seeds.", false);
		AddRequirement(s.requirements, "blob", "corn", "Corn", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	bool canChangeClass = caller.getName() != this.get_string("required class") && caller.hasTag(this.get_string("required tag"));
	
	if(canChangeClass)
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ChaChing");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
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
				
				if (blob is null) return;
			   
				if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}