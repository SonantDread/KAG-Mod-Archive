#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);
	
	this.SetLight(true);
	this.SetLightRadius(52.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));
		
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Arms Tavern");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Molotov", "$molotov$", "molotov", "Don't drop it!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Engineering Guide For Dummies", "$engineeringguide$", "engineeringguide", "Learn how to become an engineer.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Alchemism Guide For Dummies", "$alchemistguide$", "alchemistguide", "Learn how to become an alchemist.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell logs", "$COIN$", "coin-2", "Sell a log for 2 coins.");
		AddRequirement(s.requirements, "blob", "log", "Log", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell 50 Stone", "$COIN$", "coin-2", "Sell 50 stone for 2 coins.");
		AddRequirement(s.requirements, "blob", "heart", "Heart", 1);
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
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