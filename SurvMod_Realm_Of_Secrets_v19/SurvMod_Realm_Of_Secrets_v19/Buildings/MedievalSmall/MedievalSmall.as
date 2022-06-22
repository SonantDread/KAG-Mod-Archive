// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 15);
	this.Tag(SHOP_AUTOCLOSE);

	AddIconToken("$medieval_barracks_icon$", "MedievalBarracks.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Barracks", "$medieval_barracks_icon$", "medieval_barracks", "A place to switch out equipment and gear up.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	AddIconToken("$bookshelf_icon$", "Bookshelf.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Bookcase", "$bookshelf_icon$", "bookshelf", "Store Tek Books in here to provide the teknology to your entire team.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	AddIconToken("$bastion_icon$", "Bastion.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Bastion", "$bastion_icon$", "bulwark_bastion", "A rudimentary bulwark for starting a team.\nIf you team has no bulwarks remaining, it becomes disbanded, so protect them.\nEach type of bulwark adds +2 to your team's max player amount, multiple copies of the same type do not raise the cap.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	AddIconToken("$icon_chest$", "Chest.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Bulwark Chest", "$icon_chest$", "bulwark_chest_base", "A bulwark for starting or strengthening a team.\nIf you team has no bulwarks remaining, it becomes disbanded, so protect them.\nEach type of bulwark adds +2 to your team's max player amount, multiple copies of the same type do not raise the cap.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			if(isServer)
			if(item.getName().find("bulwark") >= 0)
			{
				if (item.getName() == "bulwark_chest_base")item.setPosition(item.getPosition()+Vec2f(0,8));
				
				int newteam = caller.getTeamNum();
				if(newteam > 50){ //If we aren't part of the 8 teams
					int teams = 0;
					bool[] taken = {false,false,false,false,false,false,false,false};
					
					for(uint j = 0; j < 7; j += 1){
						CBlob@[] fg;
						getBlobsByTag("bulwark", @fg);
						for(uint i = 0; i < fg.length; i++)
						{
							if(fg[i].getTeamNum() == j)
							{
								if(!taken[j])teams++;
								taken[j] = true;
							}
						}
					}
					
					if(teams >= 7){ //All 8 teams have been taken.
						item.server_Die();
					}
					
					newteam = -1;
					while(newteam == -1){
						int ranTeam = XORRandom(7);
						if(!taken[ranTeam])newteam = ranTeam;
					}
				
				}
				
				item.server_setTeamNum(newteam);
			}
			
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
}
