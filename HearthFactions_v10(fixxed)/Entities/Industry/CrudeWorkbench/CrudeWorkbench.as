#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "StandardRespawnCommand.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	// this.set_TileType("background tile", CMap::tile_castle_back);

	// if (getNet().isServer()) this.server_setTeamNum(-1);
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.set_string("required class", "slave");
	this.set_Vec2f("class offset", Vec2f(-4, 0));
		
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Don't let the master find it!");
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "Trap your gulag...", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Inkblot Vial", "$inkblotvial$", "inkblotvial", "Mask your escape!", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 300);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "Drill your way out, or murder your way out!", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 350);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grain", "$grain$", "grain", "Heal up!", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "Saw up your owner with a well made trap!", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
		s.spawnNothing = true;
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
		this.getSprite().PlaySound("MigrantHmm");
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