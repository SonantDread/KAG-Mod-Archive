#include "Growth.as";

void onInit(CBlob@ this)
{
	this.set_s16("sap",calculateSap());
	this.set_s16("original_sap",calculateSap());
	this.set_s16("blood",0);
	
	this.set_s16("nature_ability",0);
	this.addCommandID("makeslime");
	this.addCommandID("makeent");
	this.addCommandID("poison");
	this.addCommandID("overgrowzombies");
	
	this.addCommandID("heal");
	this.addCommandID("overgrow");
	this.addCommandID("makewisp");
	this.addCommandID("globalheal");
	
	this.addCommandID("makedruid");
}


void onTick(CBlob @ this)
{
	if (getNet().isServer()){
		if(XORRandom(100) == 0){
			this.set_s16("sap",calculateSap());
			this.Sync("sap",true);
			this.Sync("original_sap",true);
		}
	}
	
	int amount = 2;
	if(this.get_s16("sap") > this.get_s16("original_sap")/2)amount = 1;
	
	if(this.get_s16("nature_ability") < 1000)
	this.set_s16("nature_ability",this.get_s16("nature_ability")+amount);
	
	if(this.getName() == "naturebeing" || this.hasTag("onewithnature")){
		this.Tag("NatureMenu");
	} else {
		this.Untag("NatureMenu");
	}
	if(this.get_s16("blood") > 0){
		this.Tag("BloodMenu");
	} else {
		this.Untag("BloodMenu");
	}
}

int calculateSap(){
	int sap = 0;
	
	CBlob@[] Blobs;	   
	getBlobsByName("tree_bushy", @Blobs);
	getBlobsByName("tree_pine", @Blobs);
	getBlobsByName("bush", @Blobs);
	getBlobsByName("flowers", @Blobs);
	//for (uint i = 0; i < Blobs.length; i++)
	//{
	//	CBlob@ b = Blobs[i];
	//	sap += 1;
	//}
	
	sap = Blobs.length;
	
	return sap;
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.hasTag("NatureMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		if(this.hasTag("BloodMenu"))X += 16 * 7;
		if(this.hasTag("EvilMenu"))X += 16 * 7;
		if(this.hasTag("HolyMenu"))X += 16 * 7;
		//I'm here
		if(this.hasTag("LifeMenu"))X -= 16 * 7;
		
		int Height = 1;
		if(this.getName() == "naturebeing"){
			Height = 4;
		}
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Nature Abilities");

		AddIconToken("$slime$", "NatureAbilities.png", Vec2f(16, 16), 0);
		AddIconToken("$ent$", "NatureAbilities.png", Vec2f(16, 16), 1);
		AddIconToken("$poison$", "NatureAbilities.png", Vec2f(16, 16), 2);
		AddIconToken("$plantzombie$", "NatureAbilities.png", Vec2f(16, 16), 3);
		
		AddIconToken("$heal$", "NatureAbilities.png", Vec2f(16, 16), 4);
		AddIconToken("$overgrow$", "NatureAbilities.png", Vec2f(16, 16), 5);
		AddIconToken("$wisp$", "NatureAbilities.png", Vec2f(16, 16), 6);
		AddIconToken("$globalheal$", "NatureAbilities.png", Vec2f(16, 16), 7);
		
		AddIconToken("$druid$", "NatureAbilities.png", Vec2f(32, 32), 2);
		
		int discount = 1;
		if(this.getName() == "naturebeing" && this.hasTag("summoned"))discount = 2;
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			
			if(this.get_s16("sap") <= this.get_s16("original_sap")*0.80){
				{
					CGridButton@ b = menu.AddButton("$poison$", "Poison a nearby player.", this.getCommandID("poison"));
					if(this.get_s16("nature_ability") < 100/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			
			if(this.get_s16("sap") <= this.get_s16("original_sap")*0.60){
				{
					CGridButton@ b = menu.AddButton("$slime$", "Summon a slime at a nearby tree or bush.", this.getCommandID("makeslime"));
					if(this.get_s16("nature_ability") < 150/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			if(this.getName() == "naturebeing"){
				if(this.get_s16("sap") <= this.get_s16("original_sap")*0.40){
					{
						CGridButton@ b = menu.AddButton("$ent$", "Turn a nearby tree into an ent.", this.getCommandID("makeent"));
						if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				if(this.get_s16("sap") <= this.get_s16("original_sap")*0.20){
					{
						CGridButton@ b = menu.AddButton("$plantzombie$", "Turn nearby bodies into zombies.", this.getCommandID("overgrowzombies"));
						if(this.get_s16("nature_ability") < 750/discount)if(b !is null)b.SetEnabled(false);
					}
				}
			}
			
			if(this.get_s16("sap") > this.get_s16("original_sap")*0.20){
				{
					CGridButton@ b = menu.AddButton("$heal$", "Heal a nearby player.", this.getCommandID("heal"));
					if(this.get_s16("nature_ability") < 100/discount)if(b !is null)b.SetEnabled(false);
				}
			}
			
			if(this.get_s16("sap") > this.get_s16("original_sap")*0.40){
				{
					CGridButton@ b = menu.AddButton("$overgrow$", "Grow flora around you.", this.getCommandID("overgrow"));
					if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
				}
			}
				
			if(this.getName() == "naturebeing"){
				if(this.get_s16("sap") > this.get_s16("original_sap")*0.60){
					{
						CGridButton@ b = menu.AddButton("$wisp$", "Summon a wisp at a nearby tree.", this.getCommandID("makewisp"));
						if(this.get_s16("nature_ability") < 500/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				if(this.get_s16("sap") > this.get_s16("original_sap")*0.80){
					{
						CGridButton@ b = menu.AddButton("$globalheal$", "Heal all players.", this.getCommandID("globalheal"));
						if(this.get_s16("nature_ability") < 1000/discount)if(b !is null)b.SetEnabled(false);
					}
				}
				
				{
					CGridButton@ b = menu.AddButton("$druid$", "Turn a nearby player into a druid.", this.getCommandID("makedruid"));
					if(this.get_s16("nature_ability") < 1000/discount)if(b !is null)b.SetEnabled(false);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	int discount = 1;
	if(this.getName() == "naturebeing" && this.hasTag("summoned"))discount = 2;
	
	if (cmd == this.getCommandID("makeslime")){
		if(this.get_s16("nature_ability") >= 150/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "bush" || b.getName() == "tree_pine" || b.getName() == "tree_bushy")
						{
							server_CreateBlob("slime", -1, b.getPosition());
							this.set_s16("nature_ability",this.get_s16("nature_ability")-150/discount);
							this.Sync("nature_ability",true);
							if(!this.hasTag("summoned"))return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("makeent")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				if(!this.hasTag("summoned")){
					CBlob@[] blobsInRadius;	   
					if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];
							if(b.getName() == "tree_pine" || b.getName() == "tree_bushy")
							{
								server_CreateBlob("ent", -1, b.getPosition());
								this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
								this.Sync("nature_ability",true);
								b.server_Die();
								return;
							}
						}
					}
				} else {
					server_CreateBlob("ent", -1, this.getPosition());
					this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
					this.Sync("nature_ability",true);
					return;
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("overgrow")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				Growth(this.getPosition());
				this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
				this.Sync("nature_ability",true);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("makewisp")){
		if(this.get_s16("nature_ability") >= 500/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "tree_pine" || b.getName() == "tree_bushy")
						{
							server_CreateBlob("wisp", -1, b.getPosition());
							this.set_s16("nature_ability",this.get_s16("nature_ability")-500/discount);
							this.Sync("nature_ability",true);
							if(!this.hasTag("summoned"))return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("overgrowzombies")){
		if(this.get_s16("nature_ability") >= 750/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("dead"))
						{
							CBlob @newBlob = server_CreateBlob("plant_zombie", this.getTeamNum(), b.getPosition());
							b.server_Die();
						}
					}
				}
				this.set_s16("nature_ability",this.get_s16("nature_ability")-750/discount);
				this.Sync("nature_ability",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("heal")){
		if(this.get_s16("nature_ability") >= 100/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.get_s16("nature_regen") <= 0)
						{
							b.set_s16("nature_regen",24);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-100/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("poison")){
		if(this.get_s16("nature_ability") >= 100/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.get_s16("poison") <= 0 && b !is this)
						{
							b.set_s16("poison",4);
							if(this.hasTag("summoned"))b.set_s16("poison",4*8);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-100/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("globalheal")){
		if(this.get_s16("nature_ability") >= 1000/discount)
		{
			if (getNet().isServer()){
				CBlob@[] Blobs;	   
				getBlobsByTag("player", @Blobs);
				for (uint i = 0; i < Blobs.length; i++)
				{
					CBlob@ b = Blobs[i];
					b.set_s16("nature_regen",24);
				}
				this.set_s16("nature_ability",this.get_s16("nature_ability")-1000/discount);
				this.Sync("nature_ability",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("makedruid")){
		if(this.get_s16("nature_ability") >= 1000/discount)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.hasTag("flesh") && (b.get_u8("race") == 0 || b.get_u8("race") == 2 || b.get_u8("race") == 4))
						{
							b.set_u8("race",5);
							this.set_s16("nature_ability",this.get_s16("nature_ability")-1000/discount);
							this.Sync("nature_ability",true);
							return;
						}
					}
				}
			}
			
		}
	}
}