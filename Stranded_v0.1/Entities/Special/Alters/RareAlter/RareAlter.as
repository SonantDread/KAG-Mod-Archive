// Zombie Portal

//#include "Requirements.as"
//#include "ShopCommon.as";
//#include "Descriptions.as";
//#include "WARCosts.as";
//#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	//this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	
	this.Tag("alter");
	this.Tag("builder always hit");
	this.getSprite().SetZ(-50); //background
	
	CSpriteLayer@ portal = this.getSprite().addSpriteLayer( "portal", "RareAlter.png" , 64, 64);
	Animation@ anim = portal.addAnimation("default", 0, false);
	anim.AddFrame(1);
	portal.SetRelativeZ(-60);
	
	CSpriteLayer@ lightning = this.getSprite().addSpriteLayer( "lightning", "EvilLightning.png" , 32, 32, -1, -1 );	
	Animation@ lanim = lightning.addAnimation( "default", 4, false );
	for (int i=0; i<7; i++) lanim.AddFrame(i*4);
	Animation@ lanim2 = lightning.addAnimation( "default2", 4, false );
	for (int i=0; i<7; i++) lanim2.AddFrame(i*4+1);
	
//	portal.SetOffset(Vec2f(0,-24));
//	lightning.SetOffset(Vec2f(0,-24));

	this.getShape().getConsts().mapCollisions = false;
	this.set_bool("portalbreach",false);
	this.set_bool("portalplaybreach",false);
	
	this.SetLight(false);
	this.SetLightRadius(100.0f);
}

void onTick( CBlob@ this)
{
	int spawnRate = 275 + (190 * this.getHealth() / 44.0);
	
	if (getGameTime() % spawnRate == 0 && this.get_bool("portalbreach"))
	{
		this.getSprite().PlaySound("Thunder");
		CSpriteLayer@ lightning = this.getSprite().getSpriteLayer("lightning");
		if (XORRandom(4)>2) lightning.SetAnimation("default"); else lightning.SetAnimation("default2");
		//lightning.SetFrame(0);
	}

	if (this.get_bool("portalplaybreach")) {
		this.getSprite().PlaySound("PortalBreach");
		this.set_bool("portalplaybreach",false);
		this.SetLight(true);
		this.SetLightRadius(128.0f);		
	}
	
	if (!getNet().isServer()) return;
	
	int num_alter_mobs = getRules().get_s32("num_alter_mobs");
	int max_alter_mobs = getRules().get_s32("max_alter_mobs");
	
	if (this.get_bool("portalbreach"))
	{
		if ((getGameTime() % spawnRate == 0) && num_alter_mobs < max_alter_mobs)
		{
		CBlob@[] blobs;
		getMap().getBlobsInRadius( this.getPosition(), 250, @blobs );
		if (blobs.length == 0) return;
		
			Vec2f sp = this.getPosition();
			
			int r = XORRandom(7);
			
			if (r==0)
			server_CreateBlob( "evilzombie", -1, sp);
			
			else if (r==1) 
			server_CreateBlob( "zombie2", -1, sp);
			
			else if (r==2)
			server_CreateBlob( "zombieknight", -1, sp);

			else if (r==4)
			server_CreateBlob( "evilwraith", -1, sp);
			
			else if (r==5)
			server_CreateBlob( "evilskeleton", -1, sp);
			
			else			
			server_CreateBlob( "evilzombie", -1, sp);
		}
	}
	
	else
	{
		if (getGameTime() % 300 == 0)
		{
			Vec2f sp = this.getPosition();
			
		
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius( sp, 100, @blobs );
			for (uint step = 0; step < blobs.length; ++step)
			{
				CBlob@ other = blobs[step];
				if (other.hasTag("survivorplayer"))
				{
					this.set_bool("portalbreach",true);
					this.set_bool("portalplaybreach",true);
					this.Sync("portalplaybreach",true);
					this.Sync("portalbreach",true);
				}
			}
		}
	}
}

void onDie( CBlob@ this)
{
	server_DropCoins(this.getPosition() + Vec2f(0,-32.0f), 500);
	server_CreateBlob("chest", this.getTeamNum(), this.getPosition());	
	server_CreateBlob("chest", this.getTeamNum(), this.getPosition());	
}

							   
