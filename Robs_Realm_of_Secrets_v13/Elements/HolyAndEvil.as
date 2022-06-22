
#include "Hitters.as";
#include "ChangeClass.as";
#include "Health.as";

void onInit(CBlob@ this)
{
	this.set_string("boss","");
	
	this.set_s16("power",100);
	this.set_s16("corruption",0);
	this.set_s16("kills",0);
	
	this.set_f32("holy_cooldown",0);
	
	//this.Tag("evil");
	//this.Tag("holy");
	//this.Tag("pure_corruption");
	
	this.addCommandID("makeshadow");
	this.addCommandID("makewraith");
	this.addCommandID("makedarkpearl");
	this.addCommandID("convertzombies");
	
	this.addCommandID("soulblade");
	this.addCommandID("worldzombies");
	this.addCommandID("skeletonrain");
	this.addCommandID("evilspawn");
	
	this.addCommandID("makegoldfish");
	this.addCommandID("makegoldorb");
	this.addCommandID("makegoldsword");
	
	this.addCommandID("burstheal");
	this.addCommandID("holydefense");
	this.addCommandID("ascendwraith");
}


void onTick(CBlob @ this)
{

	int corruption = this.get_s16("corruption");

	CPlayer@ player = this.getPlayer();
	
	this.set_s16("power",(((getMap().tilemapheight*getMap().tilesize)-this.getPosition().y)/(getMap().tilemapheight*getMap().tilesize))*150);
	
	bool Transfer = false;
	
	if(player !is null){
		if(this.get_string("boss") != player.getUsername())Transfer = true;
	} else {
		Transfer = true;
	}
	
	if(Transfer){
		CPlayer@ PlayerBoss = getPlayerByUsername(this.get_string("boss"));
		if(PlayerBoss !is null){
			CBlob@ Boss = PlayerBoss.getBlob();
			if (Boss !is null)
			if(!Boss.hasTag("ghost"))
			{
				if(corruption > 0)
				if(!Boss.hasTag("holy")){
					Boss.set_s16("corruption",Boss.get_s16("corruption")+1);
					corruption -= 1;
				}
				
				this.set_s16("power",Boss.get_s16("power"));
			}
		}
	}
	
	if(this.hasTag("holy"))
	if(this.get_f32("holy_cooldown") < 1000){
		this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")+(this.get_s16("power")/100.0));
		if(getNet().isServer())this.Sync("holy_cooldown",true);
	}
	
	if(this.hasTag("evil")){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("gold") || b.getName() == "mat_gold")
				{
					if(this.hasTag("pure_corruption")){
						this.set_s16("power",this.get_s16("power")-1);
						if(this.get_s16("power") <= 0){
							this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::suddengib);
						}
					} else {
						this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::suddengib);
					}
				}
			}
		}
		this.Untag("holy");
	}
	
	this.set_s16("corruption",corruption);
	
	if(corruption >= 1000 && this.getName() != "darkbeing"){
		this.set_s16("corruption",corruption/4);
		ChangeClass(this, "darkbeing", this.getPosition()-Vec2f(0,8), 9);
	}
	
	if(this.hasTag("evil") || this.hasTag("evil_potential")){
		this.Tag("EvilMenu");
	} else {
		this.Untag("EvilMenu");
	}
	
	if(this.hasTag("holy")){
		this.Tag("HolyMenu");
	} else {
		this.Untag("HolyMenu");
	}
	
}


void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData){

	if(hitBlob.getHealth() <= 0)
	if(hitBlob.get_s16("corruption") <= this.get_s16("corruption"))
	if(!hitBlob.hasTag("evil"))
	if(hitBlob.hasTag("flesh") && !hitBlob.hasTag("lifeless"))
	if((hitBlob.getName() != "archer" && hitBlob.getName() != "knight") || hitBlob.hasTag("holy") || this.hasTag("evil"))
	if(hitBlob.getHealth()+damage > 0){
		if(hitBlob.getName() != "chicken" && hitBlob.getName() != "fishy"){
			this.set_s16("corruption",this.get_s16("corruption")+20);
			this.set_s16("kills",this.get_s16("kills")+1);
			if(this.hasTag("pure_corruption"))this.set_s16("corruption",this.get_s16("corruption")+20);
		} else this.set_s16("corruption",this.get_s16("corruption")+1);
		if(getNet().isServer())this.Sync("corruption",true);
	}

}





void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.hasTag("EvilMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		if(this.hasTag("BloodMenu"))X += 16 * 7;
		//I'm here
		if(this.hasTag("HolyMenu"))X -= 16 * 7;
		if(this.hasTag("NatureMenu"))X -= 16 * 7;
		if(this.hasTag("LifeMenu"))X -= 16 * 7;
		
		int Height = 2;
		if(this.getName() == "darkbeing"){
			Height = 4;
		}
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Dark Abilities");

		AddIconToken("$shadowblade$", "ShadowBlade.png", Vec2f(16, 16), 0);
		AddIconToken("$wraith$", "WraithIcon.png", Vec2f(16, 16), 0);
		AddIconToken("$evilzombie$", "EvilZombieIcon.png", Vec2f(16, 16), 0);
		AddIconToken("$pearl_icon$", "CorruptionOrb.png", Vec2f(8, 8), 0);
		
		AddIconToken("$skeletonrain_icon$", "SkeletonRain.png", Vec2f(16, 16), 0);
		AddIconToken("$worldzombies_icon$", "WorldRevive.png", Vec2f(16, 16), 0);
		AddIconToken("$evilspawn_icon$", "EvilSpawnIcon.png", Vec2f(16, 16), 0);
		AddIconToken("$soulblade_icon$", "SoulBlade.png", Vec2f(16, 16), 0);
		
		int cost = 1;
		if(!this.hasTag("pure_corruption"))cost = 2;
		if(this.hasTag("holy"))cost = 4;
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			
			{
				CGridButton@ b = menu.AddButton("$shadowblade$", "Conjure a sword of corruption, whoever uses it shall be bound to you.", this.getCommandID("makeshadow"));
				if(this.get_s16("corruption") < 25*cost)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$wraith$", "Turn a nearby ghost into an evil wraith.", this.getCommandID("makewraith"));
				if(this.get_s16("corruption") < 50*cost)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$evilzombie$", "Turn a nearby body into a zombie.", this.getCommandID("convertzombies"));
				if(this.get_s16("corruption") < 50*cost)if(b !is null)b.SetEnabled(false);
			}
			
			{
				CGridButton@ b = menu.AddButton("$pearl_icon$", "Create a concentrated ball of corrutpion.", this.getCommandID("makedarkpearl"));
				if(this.get_s16("corruption") < 100)if(b !is null)b.SetEnabled(false);
			}
			
			if(this.getName() == "darkbeing"){
				{
					CGridButton@ b = menu.AddButton("$worldzombies_icon$", "Raise all dead as evil zombies.", this.getCommandID("worldzombies"));
					if(this.get_s16("corruption") < 200*cost)if(b !is null)b.SetEnabled(false);
				}
				
				{
					CGridButton@ b = menu.AddButton("$skeletonrain_icon$", "Rain skeletons upon the earth.", this.getCommandID("skeletonrain"));
					if(this.get_s16("corruption") < 300*cost)if(b !is null)b.SetEnabled(false);
				}
				
				{
					CGridButton@ b = menu.AddButton("$soulblade_icon$", "Forge the soulblade.", this.getCommandID("soulblade"));
					if(this.get_s16("corruption") < 500*cost)if(b !is null)b.SetEnabled(false);
				}
				
				{
					CGridButton@ b = menu.AddButton("$evilspawn_icon$", "Create a orb of pure corruption for ghosts to respawn at.", this.getCommandID("evilspawn"));
					if(this.get_s16("corruption") < 750*cost)if(b !is null)b.SetEnabled(false);
				}
			}
			
		}
	}
	
	
	if(this.hasTag("HolyMenu")){
		int X = 0;
		if(this.hasTag("DeathMenu"))X += 16 * 7;
		if(this.hasTag("BloodMenu"))X += 16 * 7;
		if(this.hasTag("EvilMenu"))X += 16 * 7;
		//I'm here
		if(this.hasTag("NatureMenu"))X -= 16 * 7;
		if(this.hasTag("LifeMenu"))X -= 16 * 7;
		
		int Height = 1;
		if(this.getName() == "goldenbeing"){
			Height = 3;
		}
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x + X),
				  gridmenu.getUpperLeftPosition().y + 32 * 6 - 16+(Height*24-48));
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(2,Height), "Holy Abilities");

		AddIconToken("$goldfish$", "GoldenFish.png", Vec2f(16, 16), 0);
		AddIconToken("$goldorb$", "GoldenOrb.png", Vec2f(16, 16), 0);
		AddIconToken("$goldsword$", "GoldenSword.png", Vec2f(16, 16), 0);
		
		AddIconToken("$burstheal$", "HolyAbilities.png", Vec2f(16, 16), 0);
		AddIconToken("$holydefense$", "HolyAbilities.png", Vec2f(16, 16), 1);
		AddIconToken("$accension$", "HolyAbilities.png", Vec2f(16, 16), 2);
		
		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			
			{
				CGridButton@ b = menu.AddButton("$burstheal$", "Heal a nearby person for 1 heart.", this.getCommandID("burstheal"));
				if(this.get_f32("holy_cooldown") < 50)if(b !is null)b.SetEnabled(false);
			}
			{
				CGridButton@ b = menu.AddButton("$holydefense$", "Give someone nearby extra defense.", this.getCommandID("holydefense"));
				if(this.get_f32("holy_cooldown") < 500)if(b !is null)b.SetEnabled(false);
			}
			if(this.getName() == "goldenbeing"){
				{
					CGridButton@ b = menu.AddButton("$goldorb$", "Create a shining orb of gold.", this.getCommandID("makegoldorb"));
					if(this.get_f32("holy_cooldown") < 100)if(b !is null)b.SetEnabled(false);
				}
				{
					CGridButton@ b = menu.AddButton("$goldfish$", "Create an object which can immortalise someone.", this.getCommandID("makegoldfish"));
					if(this.get_f32("holy_cooldown") < 100)if(b !is null)b.SetEnabled(false);
				}
				{
					CGridButton@ b = menu.AddButton("$goldsword$", "Create a sword to cleanse someone.", this.getCommandID("makegoldsword"));
					if(this.get_f32("holy_cooldown") < 750)if(b !is null)b.SetEnabled(false);
				}
				//{
				//	CGridButton@ b = menu.AddButton("$accension$", "Ascend a nearby wraith.", this.getCommandID("ascendwraith"));
				//	if(this.get_f32("holy_cooldown") < 1000)if(b !is null)b.SetEnabled(false);
				//}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	int cost = 1;
	if(!this.hasTag("pure_corruption"))cost = 2;
	if(this.hasTag("holy"))cost = 4;
	
	int Power = 1;
	if(this.getName() == "darkbeing")Power += 2;
	if(this.hasTag("pure_corruption"))Power += 1;
	
	if (cmd == this.getCommandID("makeshadow")){
		if(this.get_s16("corruption") >= 25*cost)
		{
			if (getNet().isServer())
			{
				CBlob @blob = server_CreateBlob("shadowblade", this.getTeamNum(), this.getPosition());
				blob.set_string("boss",this.getPlayer().getUsername());
				this.set_s16("corruption",this.get_s16("corruption")-25*cost);
				this.Tag("evil");
				this.Sync("corruption",true);
				this.Sync("evil",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("makewraith")){
		if(this.get_s16("corruption") >= 50*cost)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "ghost")
						{
							string name = "wraithknight";
							if(XORRandom(2) == 0)name = "wraitharcher";
							CBlob @newBlob = server_CreateBlob(name, this.getTeamNum(), b.getPosition());
							if (newBlob !is null)
							{
								// plug the soul
								newBlob.server_SetPlayer(b.getPlayer());
								
								CopyData(b,newBlob);
								
								newBlob.set_s16("corruption",300);
								
								b.Tag("switch class");
								b.server_SetPlayer(null);
								b.server_Die();
							}
							this.set_s16("corruption",this.get_s16("corruption")-50*cost);
							this.Tag("evil");
							this.Sync("corruption",true);
							this.Sync("evil",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("convertzombies")){
		if(this.get_s16("corruption") >= 50*cost)
		{
			int converted = 0;
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f*Power, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("dead"))
						{
							CBlob @newBlob = server_CreateBlob("evil_zombie", this.getTeamNum(), b.getPosition());
							b.server_Die();
							this.set_s16("corruption",this.get_s16("corruption")-50*cost);
							this.Tag("evil");
							this.Sync("corruption",true);
							this.Sync("evil",true);
							
							converted += 1;
							
							if(converted >= Power)return;
						}
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("makedarkpearl")){
		if(this.get_s16("corruption") >= 100)
		{
			if (getNet().isServer())
			{
				CBlob @blob = server_CreateBlob("corruption_orb", this.getTeamNum(), this.getPosition());
				this.set_s16("corruption",this.get_s16("corruption")-100);
				this.Sync("corruption",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("worldzombies")){
		if(this.get_s16("corruption") >= 200*cost)
		{
			if (getNet().isServer()){
				CBlob@[] Blobs;	   
				getBlobsByTag("flesh", @Blobs);
				for (uint i = 0; i < Blobs.length; i++)
				{
					CBlob@ b = Blobs[i];
					if(b.hasTag("dead"))
					{
						CBlob @newBlob = server_CreateBlob("evil_zombie", this.getTeamNum(), b.getPosition());
						b.server_Die();
					}
				}
				this.set_s16("corruption",this.get_s16("corruption")-200*cost);
				this.Tag("evil");
				this.Sync("corruption",true);
				this.Sync("evil",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("skeletonrain")){
		if(this.get_s16("corruption") >= 300*cost)
		{
			if (getNet().isServer()){
				CBlob@[] Blobs;	   
				getBlobsByTag("flesh", @Blobs);
				for (uint i = 0; i < Blobs.length; i++)
				{
					CBlob@ b = Blobs[i];
					CBlob @newBlob = server_CreateBlob("evilskeleton", this.getTeamNum(), b.getPosition());
				}
				this.set_s16("corruption",this.get_s16("corruption")-300*cost);
				this.Tag("evil");
				this.Sync("corruption",true);
				this.Sync("evil",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("soulblade")){
		if(this.get_s16("corruption") >= 500*cost)
		{
			if (getNet().isServer())
			{
				CBlob@[] Blobs;	   
				getBlobsByName("soulblade", @Blobs);
				if(Blobs.length <= 0){
					CBlob @blob = server_CreateBlob("soulblade", this.getTeamNum(), this.getPosition());
					this.set_s16("corruption",this.get_s16("corruption")-500*cost);
					this.Tag("evil");
					this.Sync("corruption",true);
					this.Sync("evil",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("evilspawn")){
		if(this.get_s16("corruption") >= 750*cost)
		{
			if (getNet().isServer())
			{
				CBlob @blob = server_CreateBlob("evilspawn", this.getTeamNum(), this.getPosition());
				blob.set_string("boss",this.getPlayer().getUsername());
				this.set_s16("corruption",this.get_s16("corruption")-750*cost);
				this.Tag("evil");
				this.Sync("corruption",true);
				this.Sync("evil",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("burstheal")){
		if(this.get_f32("holy_cooldown") >= 10)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && Health(b) < MaxHealth(b))
						{
							Heal(b,1);
							this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")-10);
							this.Sync("holy_cooldown",true);
							return;
						}
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("holydefense")){
		if(this.get_f32("holy_cooldown") >= 100)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.hasTag("player") && b.get_s16("golden_shield") <= 0 && b.getTeamNum() == this.getTeamNum())
						{
							b.set_s16("golden_shield",3000);
							this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")-100);
							this.Sync("holy_cooldown",true);
							return;
						}
					}
				}
			}
			
		}
	}
	
	if (cmd == this.getCommandID("makegoldfish")){
		if(this.get_f32("holy_cooldown") >= 100)
		{
			if (getNet().isServer())
			{
				server_CreateBlob("goldenfish", this.getTeamNum(), this.getPosition());
				this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")-100);
			}
		}
	}
	
	if (cmd == this.getCommandID("makegoldorb")){
		if(this.get_f32("holy_cooldown") >= 100)
		{
			if (getNet().isServer())
			{
				server_CreateBlob("goldenorb", this.getTeamNum(), this.getPosition());
				this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")-100);
			}
		}
	}
	
	if (cmd == this.getCommandID("makegoldsword")){
		if(this.get_f32("holy_cooldown") >= 750)
		{
			if (getNet().isServer())
			{
				CBlob @blob = server_CreateBlob("goldensword", this.getTeamNum(), this.getPosition());
				blob.set_string("boss",this.getPlayer().getUsername());
				this.set_f32("holy_cooldown",this.get_f32("holy_cooldown")-750);
				this.Sync("holy_cooldown",true);
			}
		}
	}
	
	if (cmd == this.getCommandID("ascendwraith")){
		if(this.get_f32("holy_cooldown") >= 1000)
		{
			if (getNet().isServer()){
				CBlob@[] blobsInRadius;	   
				if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getName() == "ghost" && b.get_s16("corruption") <= 21)
						{
							CBlob @wraith = ChangeClass(b,"knight",b.getPosition(),this.getTeamNum());
							wraith.set_u8("race",8);
							return;
						}
					}
				}
			}
			
		}
	}
}