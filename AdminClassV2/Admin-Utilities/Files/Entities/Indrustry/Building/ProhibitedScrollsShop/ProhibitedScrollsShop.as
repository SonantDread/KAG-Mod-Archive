// Necromancer Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6,2));	
	this.set_string("shop description", "Buy Prohibited scrolls");
	this.set_u8("shop icon", 25);
	this.SetLight(true);
	this.SetLightRadius(128.0f );
	this.Tag("builder always hit");
	
	// Magician
	
		/*string sex = traderRandom.NextRanged(2) == 0 ? "TraderMale.png" : "TraderFemale.png";
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", sex, 16, 16, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 8));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));*/


	/*{
		ShopItem@ s = addShopItem( this, "Grave", "$grave1$", "grave1", "To bury your loved ones or you.", false, true);
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
		s.crate_icon = 4;
	}*/
	{
		ShopItem@ s = addShopItem( this, "Scroll of Arsonist", "$sarsonist$", "sarsonist", "Be an Arsonist", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 750 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "priest", "Dead priest", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Bunny", "$sbunny$", "sbunny", "Be an Bunny. With an.. Chicken.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "chicken", "Chicke,", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Gargoyle", "$sgargoyle$", "sgargoyle", "Be an Gargoyle.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 600 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 5 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll Necromancer", "$snecromancer$", "snecromancer", "Be an Necromancer.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "priest", "Dead Priest", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Slayer", "$sslayer$", "sslayer", "Be an Slayer.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 75000 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "knight", "Dead Knight", 1 );
		
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Stalker", "$sstalker$", "sstalker", "Be an Stalker.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 2 );
		AddRequirement( s.requirements, "blob", "builder", "Dead Builder", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Greg", "$sgreg$", "sgreg", "Spawn 2 gregs.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 750 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Horde", "$shorde$", "shorde", "Spawn an horde of zombie.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 1000 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Shark", "$sshark$", "sshark", "Spawn an angry shark.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Skeleton", "$sskeleton$", "sskeleton", "Spawn 5 skeletons.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 8000 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Zombie", "$szombie$", "szombie", "Spawn 4 Zombies.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 1200 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
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
		CBlob@ zombie;
		CBlob@ corpse;
		
		string name = params.read_string();
		
		{
			if(name == "summonWarrior")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "knight", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "nwarrior", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());				
			}
			
			if(name == "summonZombie")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "builder", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "nzombie", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());				
			}
			
			if(name == "summonSkeleton")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "archer", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "nskeleton", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());
			}
			
			if(name == "summonGargoyle")
			{
				if (isServer)
				{
					if (blob !is null)  
					{
						@corpse = server_CreateBlob( "wizard", blob.getTeamNum(), this.getPosition()); 
						@zombie = server_CreateBlob( "ngarg", blob.getTeamNum(), this.getPosition());
					}
				}
				if (corpse !is null) 
				{
					corpse.getSprite().Gib();
					corpse.server_Die();
				}
				if (zombie !is null) ParticleZombieLightning(zombie.getPosition());
			}			
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if(destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}