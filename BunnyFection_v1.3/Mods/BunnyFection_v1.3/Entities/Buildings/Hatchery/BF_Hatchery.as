// Genreic building

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";

void onInit( CBlob@ this )
{
	this.Tag( "flesh" );
	this.Tag( "mutant" );
	this.Tag( "building" );
	CSprite@ sprite = this.getSprite();
	sprite.SetZ( -5.0f );
	this.addCommandID("Switch");

    this.getShape().getConsts().mapCollisions = false;
	this.set_Vec2f( "nobuild extend", Vec2f( 8.0f, 16.0f ) );
	
	this.getCurrentScript().tickFrequency = 0;
	  
	  
    this.SetLightRadius(80.0f);
	this.SetLightColor(SColor(255, 128, 200, 0 ));
	this.SetLight(true);

	//Goo	  
	CSpriteLayer@ goo = sprite.addSpriteLayer( "goo", "/BF_HatcheryGoo.png", 8, 2 );
	   
	if (goo !is null)
    {
		Animation@ anim = goo.addAnimation( "default", 20, true );
		int[] frames = { 0, 1, 2, 1, 2 };
		anim.AddFrames( frames );
		goo.SetOffset( Vec2f( 4, 11 ) );
		goo.SetRelativeZ( 1.0f );
	}

    // ICONS
    AddIconToken( "$custom_minion1$", "BF_Minion1.png", Vec2f(16,16), 0);
    AddIconToken( "$custom_minion2$", "BF_Minion2.png", Vec2f(24,16), 0);
    AddIconToken( "$custom_minion3$", "BF_Minion3.png", Vec2f(16,16), 0);
	AddIconToken( "$custom_minion4$", "BF_Minion4.png", Vec2f(16,16), 0);
	AddIconToken( "$custom_cyst$", "BF_Cyst.png", Vec2f(16,16), 0);
	AddIconToken( "$custom_tract$", "BF_Tract.png", Vec2f(24,16), 0);
	AddIconToken( "$custom_fester$", "BF_Fester.png", Vec2f(24,16), 0);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(3,3));
    this.set_string("shop description", "Gestate");
    this.set_u8("shop icon", 22);

	Sound::Play( "/GregCry.ogg" );
	
    // Minion1
    {
        ShopItem@ s = addShopItem( this, "Minion", "$custom_minion1$", "bf_minion1egg", "Three basic minions" );
        AddRequirement( s.requirements, "blob", "bf_materialbiomass", "Biomass", COST_BIO_MINION1 );
    }
    // Minion2
    {
        ShopItem@ s = addShopItem( this, "Husk", "$custom_minion2$", "bf_minion2egg", "Heavy duty Husk." );
        AddRequirement( s.requirements, "blob", "bf_materialbiomass", "Biomass", COST_BIO_MINION2 );
    }
	// Minion3
    {
        ShopItem@ s = addShopItem( this, "Boomer", "$custom_minion3$", "bf_minion3egg", "Boomer!" );
        AddRequirement( s.requirements, "blob", "bf_materialbiomass", "Biomass", COST_BIO_MINION3 );
    }
	{
        ShopItem@ s = addShopItem( this, "Callous", "$custom_minion4$", "bf_minion4egg", "Heavy Duty Callous!" );
        AddRequirement( s.requirements, "blob", "bf_materialbiomass", "Biomass", 50 );
		AddRequirement( s.requirements, "blob", "mat_bioblock", "Bioblock", 10 );
    }
	// Cyst
    {
        ShopItem@ s = addShopItem( this, "Cyst", "$custom_cyst$", "bf_cyst", "A cyst full of sticky gelatinous fluid." );
        AddRequirement( s.requirements, "blob", "bf_materialbiomass", "Biomass", COST_BIO_CYST );
    }
	// Tract
    {
        ShopItem@ s = addShopItem( this, "Tract", "$custom_tract$", "bf_tractegg", "A travel Tract spawner." );
        AddRequirement( s.requirements, "blob", "mat_bioblock", "Bioblock", 70 );
    }
	{
        ShopItem@ s = addShopItem( this, "Fester", "$custom_fester$", "bf_festeregg", "A Mutant storage membrane." );
        AddRequirement( s.requirements, "blob", "mat_bioblock", "Bioblock", 50 );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ZombieKnightGrowl.ogg" );

		u16 callerID = params.read_netid();
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		if ( blob !is null )
		{
			string blobName = params.read_string();
			if ( blobName == "bf_minion1egg" || blobName == "bf_minion2egg" || blobName == "bf_minion3egg" )
					blob.set_netid( "owner", callerID );
		}
	}
	if (cmd == this.getCommandID("Switch"))
    {
		u16 netID;
		if(!params.saferead_netid(netID))
		{
		    return;
		}
        CBlob@ caller = getBlobByNetworkID(netID);
		if ( caller.getName() == "bf_mutant1" )
		{
			if (this !is null)
			{
				Vec2f pos = caller.getPosition();
				CPlayer@ player = caller.getPlayer();
				if (caller !is null)
					RemovePlayerBlob( player );
		
				CBlob @newBlob = server_CreateBlob( "bf_mutant2", 1, pos );
				if (newBlob !is null)
				{
					if (player !is null)
					{
						newBlob.server_SetPlayer( player );
					}
				}
			}
		}	
		if ( caller.getName() == "bf_mutant2" )
		{
			if (this !is null)
			{
				Vec2f pos = caller.getPosition();
				CPlayer@ player = caller.getPlayer();
				if (caller !is null)
					RemovePlayerBlob( player );
		
				CBlob @newBlob = server_CreateBlob( "bf_mutant1", 1, pos );
				if (newBlob !is null)
				{
					if (player !is null)
					{
						newBlob.server_SetPlayer( player );
					}
				}
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.getSprite().SetAnimation( "hit" );
	this.getCurrentScript().tickFrequency = 1;
	
	//sound effect for mutants. plays randomly
	CBlob@[] mutants;
	getBlobsByName( "bf_mutant1", @mutants );
	for ( u8 i = 0; i < mutants.length; i++ )
	{
		if ( XORRandom(8) == 0 && mutants[i].isMyPlayer() )
		{
			Vec2f mutantPos = mutants[i].getPosition();
			if ( ( worldPoint - mutantPos ).Length() < 140.0f )
				Sound::Play( "/WraithSpawn.ogg", worldPoint, 0.6f, 0.9f );
			else
			{
				Vec2f soundDir = worldPoint - mutantPos;
				soundDir.Normalize();
				soundDir *= 140.0f;
				Sound::Play( "/WraithSpawn.ogg", mutantPos + soundDir, 0.6f, 0.9f );
			}
		}
	}
	CBlob@[] mutants2;
	getBlobsByName( "bf_mutant2", @mutants2 );
	for ( u8 i = 0; i < mutants.length; i++ )
	{
		if ( XORRandom(8) == 0 && mutants[i].isMyPlayer() )
		{
			Vec2f mutantPos = mutants[i].getPosition();
			if ( ( worldPoint - mutantPos ).Length() < 140.0f )
				Sound::Play( "/WraithSpawn.ogg", worldPoint, 0.6f, 0.9f );
			else
			{
				Vec2f soundDir = worldPoint - mutantPos;
				soundDir.Normalize();
				soundDir *= 140.0f;
				Sound::Play( "/WraithSpawn.ogg", mutantPos + soundDir, 0.6f, 0.9f );
			}
		}
	}
	
	return damage;
}

void onTick ( CBlob@ this )
{
	if ( this.getSprite().isAnimationEnded() )
	{
		this.getCurrentScript().tickFrequency = 0;
		this.getSprite().SetAnimation( "default" );
	}
}

void onDie( CBlob@ this )
{
	this.getSprite().PlaySound("/splat.ogg");
	this.getSprite().Gib();
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	print("button call");
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ Mutation = caller.CreateGenericButton( "$bf_mutant1$", Vec2f(9.0f,1.0f), this, this.getCommandID("Switch"), "", params);
	if(caller.getDistanceTo(this) < 10.0f)
	{
		if(Mutation != null)
		{
			Mutation.SetEnabled(true);
		}
	}
	else
	{
		Mutation.SetEnabled(false);
	}
}
void RemovePlayerBlob( CPlayer@ player )
{
	if (player is null)
		return;

	// remove previous players blob	  			
	CBlob @blob = player.getBlob();
	if (blob !is null )
	{							   
		blob.server_SetPlayer( null );
		
		//if (blob.getHealth() > 0.0f)
			blob.server_Die();
	}	 
}
