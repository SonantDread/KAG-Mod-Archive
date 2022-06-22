// Necromancer Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";


void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6,3));	
	this.set_string("shop description", "Buy holy scrolls");
	this.set_u8("shop icon", 25);
	this.SetLight(true);
	this.SetLightRadius(128.0f );
	
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

	{
		ShopItem@ s = addShopItem( this, "Scroll of chicken", "$schicken$", "schicken", "Spawn five chickens.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 50 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Drought", "$drought$", "drought", "Dry water around you.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Return", "$sreturn$", "sreturn", "Teleport in dorm.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 1500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Reinforce", "$sreinforce$", "sreinforce", "Reinforce stone.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 150 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Midas", "$smidas$", "smidas", "Turn stone into gold.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Elemental", "$selemental$", "selemental", "Spawn five elemental. They'll help you to fight against ennemy.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 5 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Friendly Shark", "$sfshark$", "sfshark", "Spawn an friendly shark.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "shark", "Shark", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Meteor", "$smeteor$", "smeteor", "Spawn an meteor.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 600 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Friendly Shark", "$sfshark$", "sfshark", "Spawn an friendly shark.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "shark", "Shark", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Carnage", "$carnage$", "carnage", "Kill lesser and medium zombie.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 300 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Carnage", "$Stop_search_file_you_are_ridiculous$", "Stop_search_file_you_are_ridiculous", "Kill lesser, medium and giant zombie.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 300 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 3 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Assassin", "$sassassin$", "sassassin", "Be an Assassin.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 2 );
		AddRequirement( s.requirements, "blob", "archer", "Dead Archer", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Burd", "$sburd$", "sburd", "Be an Chicken.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 1 );
		AddRequirement( s.requirements, "blob", "chicken", "Chicken", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Crossbow", "$scrossbow$", "scrossbow", "Be an Crossbow.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 100 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 2 );
		AddRequirement( s.requirements, "blob", "archer", "Dead Archer", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Dragoon", "$sdragoon$", "sdragoon", "Be an Dragoon.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 3 );
		AddRequirement( s.requirements, "blob", "knight", "Dead Knight", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Pyromancer", "$spyro$", "spyro", "Be an Pyromancer.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 250 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 3 );
		AddRequirement( s.requirements, "blob", "priest", "Dead Priest", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Scroll of Wizard", "$swizard$", "swizard", "Be an Wizard.", false);
		AddRequirement( s.requirements, "coin", "", "Coins", 500 );
		AddRequirement( s.requirements, "blob", "whitepage", "Crystals Shards", 5 );
		AddRequirement( s.requirements, "blob", "knight", "Dead priest", 1 );
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

void onInit(CSprite@ this)
{
	CSpriteLayer@ whitepage = this.addSpriteLayer( "whitepage","Whitepage.png", 8,8 );
	
	if(whitepage !is null)
	{
		Animation@ anim = whitepage.addAnimation("default", 0, false);
		anim.AddFrame(0);
		whitepage.SetAnimation(anim);
		whitepage.SetOffset(Vec2f(0, 16));
		whitepage.SetRelativeZ(0.1f);
	}
}

void onTick(CSprite@ this)

{
	//spin dat orb
	CSpriteLayer@ whitepage = this.getSpriteLayer("whitepage");

	if (whitepage !is null)
	{
		whitepage.SetFacingLeft(false);

		Vec2f around(0.5f, -0.5f);
		whitepage.RotateBy(2.5f, around);
	}
}

/*{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");
	if (!trader_moving)
	{
		if (move_timer <= getGameTime())
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);

		}

	}
	else
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);

		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");

		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);

		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");

		}

	}

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.getTeamNum() == this.getTeamNum() && hitterBlob !is this)
	{
		return 0.0f;
	} //no griffing

	this.Damage(damage, hitterBlob);

	return 0.0f;
}*/