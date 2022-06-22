// Necromancer Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";



void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back_moss);
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 25, 94, 157));
	this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(1,1));	
	this.set_string("shop description", "Buy unholy scrolls");
	this.set_u8("shop icon", 25);
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 53, 36, 65));
	this.Tag("builder always hit");
	
	{
		ShopItem@ s = addShopItem( this, "Scroll of the  ", "$jflzejfiojojfoiefjhgheoihfohflsdkhfhjkhjkgkjyfyfyjfkhjf$", "jflzejfiojojfoiefjhgheoihfohflsdkhfhjkhjkgkjyfyfyjfkhjf", "Your determination has made you reject all your humanity but you still have a chance to stop by destroying this shop.", false);
		AddRequirement( s.requirements, "blob", "blackpage", "Corrupt Crystal Shard", 1 );
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



