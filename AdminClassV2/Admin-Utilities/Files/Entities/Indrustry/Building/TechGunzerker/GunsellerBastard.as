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
	this.set_string("shop description", "Whatchu want? Just buy somethin' and I'll toss in this crap fuel cell. Just touchin' it made two o' my fingers rot off. And I only accept Gun. Coins is for clowns, boy!");
	this.set_u8("shop icon", 25);
	
	

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	{
		ShopItem@ s = addShopItem(this, "Sell Small Iron", "$smalliron$", "whitepage", "Pick somethin'! My time's valuable! Kinda.", true);
		AddRequirement(s.requirements, "blob", "smalliron", "smalliron",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Heavy revolver", "$bigiron$", "whitepage", "Do not hope for more.", true);
		AddRequirement(s.requirements, "blob", "bigiron", "bigiron",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Kalachnikov", "$ak47$", "whitepage-2", "What do I really have to take it back ?", true);
		AddRequirement(s.requirements, "blob", "ak47", "ak47",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Ster Gun", "$stergun$", "whitepage-2", "Buy somethin' or get outta my face!", true);
		AddRequirement(s.requirements, "blob", "stergun", "stergun",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Lever Action", "$leveraction$", "whitepage-3", "I would sell it to someone smarter.", true);
		AddRequirement(s.requirements, "blob", "leveraction", "leveraction",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell M1 Garand", "$m1$", "whitepage-3", "*Yawn* ?", true);
		AddRequirement(s.requirements, "blob", "m1", "m1",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Ster Gun Mk2", "$stergunmk2$", "whitepage-3", "I don't care what ya buy, just buy somethin'!", true);
		AddRequirement(s.requirements, "blob", "stergunmk2", "stergunmk2",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Lewis automatic rifle", "$lewisgun$", "whitepage-5", "So like that we don't like big toys ?", true);
		AddRequirement(s.requirements, "blob", "lewisgun", "lewisgun",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Sturmgewehr 44", "$stg44$", "whitepage-5", "Outta my face! OUTTA MY FACE!", true);
		AddRequirement(s.requirements, "blob", "stg44", "stg44",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Ultra Shotgun", "$ultrashotgun$", "whitepage-9", "Heh-heh, thanks for the Eridiu... Uhm.. Gun, chump!", true);
		AddRequirement(s.requirements, "blob", "supershotgun", "supershotgun",1);
	}	
	{
		ShopItem@ s = addShopItem(this, "Sell Winchester M1897", "$trenchgun$", "whitepage-14", "You know where to find me!", true);
		AddRequirement(s.requirements, "blob", "trenchgun", "trenchgun",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Maschinenpistole 40", "$mp40$", "whitepage-15", "Good riddance!", true);
		AddRequirement(s.requirements, "blob", "mp40", "mp40",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Maschinenpistole 18", "$mp18$", "whitepage-15", "Hey don't forget your brain before sell it", true);
		AddRequirement(s.requirements, "blob", "mp18", "mp18",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Yeah sell it", "$jeremy$", "whitepage-19", "Come on ! Hurry up. I have another client.", true);
		AddRequirement(s.requirements, "blob", "jeremy", "jeremy",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Bergman", "$bergman$", "whitepage-20", "You're right, give it to me. In your hands it's an insult.", true);
		AddRequirement(s.requirements, "blob", "bergman", "bergman",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell sell it mk2", "$jeremymk2$", "whitepage-21", "So we don't like guns, eh ?", true);
		AddRequirement(s.requirements, "blob", "jeremymk2", "jeremymk2",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Super Sherif Shotgun", "$martyrifle$", "whitepage-200", "What ? did you really think you would sell this gun someday ? Make me laugh.", true);
		AddRequirement(s.requirements, "blob", "martyrifle", "martyrifle",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Lewis automatic rifle", "$m95$", "coins-1", "Hurry up ! I don't have time for you !", true);
		AddRequirement(s.requirements, "blob", "m95", "m95",1);
	}		
	{
		ShopItem@ s = addShopItem(this, "Sell Rusty gun", "$shitgun$", "coins-1", "Heh-HEH, what a sucker !", true);
		AddRequirement(s.requirements, "blob", "shitgun", "shitgun",1);
	}		
	{
		ShopItem@ s = addShopItem(this, "Sell Sig & Fried", "$sigfried$", "coins-1", "Who told you 'bout this shop? I'll kill 'em!", true);
		AddRequirement(s.requirements, "blob", "sigfried", "sigfried",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Super Shotgun", "$supershotgun$", "coins-1", "You know where to find me!", true);
		AddRequirement(s.requirements, "blob", "supershotgun", "supershotgun",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Thunder Tube", "$thundertube$", "coins-1", "Don't you hurry back!", true);
		AddRequirement(s.requirements, "blob", "thundertube", "thundertube",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell [Not Repertoried ID]", "$XXX$", "whitepage-1", "What the... ?", true);
		AddRequirement(s.requirements, "blob", "sasha", "sasha",1);
	}		
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ChaChing.ogg");
		
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