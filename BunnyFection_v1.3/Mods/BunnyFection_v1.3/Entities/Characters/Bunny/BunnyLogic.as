// Builder logic

#include "Hitters.as";
#include "Knocked.as";
#include "BuilderCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MakeMat.as";
#include "Requirements.as";
#include "BF_CanHit.as";
#include "PlacementCommon.as";

void onInit( CBlob@ this )
{
    //no spinning
    this.getShape().SetRotationsAllowed(false);
    this.set_f32("gib health", -3.0f);
    this.Tag("player");
    this.Tag("flesh");
    HitData hitdata;
    this.set("hitdata", hitdata );
	this.addCommandID("pickaxe");
	this.set_u8("armor", 5);
	this.set_u8("currentarmor", 5);
	this.set_bool("hasarmor", false);
	this.push("names to activate", "bf_candle");
	this.push("names to activate", "bf_miningcharge");
	this.push("names to activate", "bf_potionspeed");
	this.push("names to activate", "bf_potioninvisibility");
	this.push("names to activate", "bf_potionrockskin");
	this.push("names to activate", "bf_potionfeather");
	this.push("names to activate", "pigwaregg");
	AddIconToken( "$bf_hall$", "BF_Hall.png", Vec2f(32,16), 1);
    AddIconToken( "$bf_workshop$", "BF_Workshop.png", Vec2f(16,16), 0);
	
    setKnockable( this );
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
    u8 knocked = getKnocked(this);
	const bool left = this.isKeyPressed( key_left );
	const bool right = this.isKeyPressed( key_right );
	const bool up = this.isKeyPressed( key_up );
	const bool down = this.isKeyPressed( key_down );
	const bool inair = ( !this.isOnGround() && !this.isOnLadder() );
	CSprite @sprite = this.getSprite();
	
	if ((this.get_u8("currentarmor") != this.get_u8("armor")) && this.get_bool("hasarmor"))
	{
		
		MakeMat(this, this.getPosition(), findArmor(this.get_u8("currentarmor")), 1);
		this.set_bool("hasarmor" , false);
	}
	if (this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if (ismyplayer && getHUD().hasMenus()) {
		return;
	}

    // activate/throw

    if ( ismyplayer )
    {
		Pickaxe( this );

        if (this.isKeyJustPressed(key_action3))
        {
			CBlob@ carried = this.getCarriedBlob();
			if (carried is null || !carried.hasTag("temp blob")) {
				client_SendThrowOrActivateCommand( this );
			}
        }
    }


	if ( down && ( left || right ) && !inair )// && !knocked )
	{
		this.Tag( "crawling" );
		//blob crawl size
	}
	else if ( this.hasTag( "crawling" ) )
	{
		CMap@ map = this.getMap();
		Vec2f pos = this.getPosition();
		const f32 ts = map.tilesize;
		const f32 y_ts = ts * 0.2f;
		const f32 x_ts = ts * 1.4f;

		//bool surface_above = map.isTileSolid(pos + Vec2f(y_ts, -x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, -x_ts));
		
		//if ( !surface_above )
		{
			this.Untag( "crawling" );
		}
	}
	
	bool digging = sprite.isAnimation( "strike" ) || sprite.isAnimation( "dig_up" );

	if ( digging )
	{	
		//Movement stuff
		RunnerMoveVars@ moveVars;
		if (this.get( "moveVars", @moveVars ))
		{
			moveVars.walkFactor = 0.5f;
			moveVars.jumpFactor = 0.5f;
		}
	}

	if (ismyplayer && this.isKeyPressed(key_action1))
	{
		BlockCursor @bc;
		this.get( "blockCursor", @bc );

		HitData@ hitdata;
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = bc.buildable ? bc.tileAimPos : Vec2f_zero;
	}


    // get rid of the built item

    if (this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup))
    {
		this.set_u8( "buildblob", 255 );
		this.set_TileType( "buildtile", 0 );
        CBlob@ blob = this.getCarriedBlob();
		if (blob !is null && blob.hasTag("temp blob"))
        {
            blob.Untag("temp blob");
            blob.server_Die();
        }
    }
}

void SendHitCommand( CBlob@ this, CBlob@ blob, const Vec2f tilepos, const Vec2f attackVel, const f32 attack_power )
{
	CBitStream params;
	if (blob is null)
		params.write_netid( 0 );
	else
		params.write_netid( blob.getNetworkID() );
	params.write_Vec2f( tilepos );
	params.write_Vec2f( attackVel );
	params.write_f32( attack_power );
	this.SendCommand( this.getCommandID("pickaxe"), params );
}

bool RecdHitCommand( CBlob@ this, CBitStream@ params )
{
	u16 blobID;
	Vec2f tilepos, attackVel;
	f32 attack_power;
	if (!params.saferead_netid( blobID ))
		return false;
	if (!params.saferead_Vec2f( tilepos ))
		return false;
	if (!params.saferead_Vec2f( attackVel ))
		return false;
	if (!params.saferead_f32( attack_power ))
		return false;

	if (blobID == 0) {
		//print( "::: Trying to hit Map" );
		this.server_HitMap( tilepos, attackVel, attack_power, Hitters::builder );
	}
	else
	{
		CBlob@ blob = getBlobByNetworkID( blobID );
		if (blob !is null)
		{
			//print( "::: Trying to hit Blob: " + blob.getName() );
			const bool teamHurt = ( blob.hasTag("dead"));
			this.server_Hit( blob, tilepos, attackVel, attack_power, Hitters::builder, true);
		}
	}
	return true;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("pickaxe"))
	{
		if (!RecdHitCommand( this, params ))
			warn("error when recieving pickaxe command");
	}
}

void Pickaxe( CBlob@ this )
{
    HitData@ hitdata;
    CSprite @sprite = this.getSprite();
    bool strikeAnim = sprite.isAnimation("strike") || sprite.isAnimation( "dig_up" );

    if (!strikeAnim)
    {
        this.get("hitdata", @hitdata);
        hitdata.blobID = 0;
        hitdata.tilepos = Vec2f_zero;
        return;
    }

    bool justCheck = !(strikeAnim && sprite.isFrameIndex(3));   // no damage cause we just check hit for cursor display

    // pickaxe!

    if (hitdata is null)
    {
        this.get("hitdata", @hitdata);
        hitdata.blobID = 0;
        hitdata.tilepos = Vec2f_zero;
    }
    
    f32 arcdegrees = 90.0f;

    Vec2f blobPos = this.getPosition();
    Vec2f aimPos = this.getAimPos();
    Vec2f aimDir = aimPos - blobPos;
    f32 aimangle = aimDir.Angle();
    Vec2f pos = blobPos + Vec2f(2,0).RotateBy(-aimangle);
    f32 radius = this.getRadius();
    f32 attack_distance = radius - 0.6f;
    f32 damage = getArmorDamage(this);
    CMap@ map = this.getMap();
	bool dontHitMore = false;
	
    bool hasHit = false;
	
    // this gathers HitInfo objects which contain blob or tile hit information
    HitInfo@ bestinfo = null;
    f32 bestDistance = 100000.0f;
    
    HitInfo@[] hitInfos;

    if (map.getHitInfosFromArc( pos, -aimangle, arcdegrees, attack_distance, this, @hitInfos ))
    {
        //HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
		
			CBlob@ b = hi.blob;
			if (b !is null) // blob
			{			
				if ( !bunnyCanHit(this, b) )	{
					continue;
				}
				
				if( !justCheck && isUrgent(this, b) )
				{
					hasHit = true;
					SendHitCommand( this, hi.blob, hi.hitpos, hi.blob.getPosition() - pos, damage );
				}
				else
				{				
					f32 len = (aimPos - b.getPosition()).Length();
					if ( len < bestDistance )
					{
						bestDistance = len;
						@bestinfo = hi;
					}
				}
			}
		}
    }
    
	
	Vec2f normal = aimDir;
    normal.Normalize();
    
    Vec2f attackVel = normal;

	const f32 tile_attack_distance = attack_distance * 1.5f;
    Vec2f tilepos = blobPos + normal * Maths::Min(aimDir.Length() - 1, tile_attack_distance);
    map.rayCastSolid( blobPos, tilepos, tilepos );
    
    bool noBuildZone = map.getSectorAtPosition( tilepos, "no build") !is null;
    
    f32 tiledist = (tilepos - aimPos).Length();
    
    
    if (tiledist + (map.tilesize*0.5f) < bestDistance)
    {
		Tile tile = map.getTile( tilepos );

		if (bunnyCanHitMap( this, map, tile ) && !noBuildZone && !map.isTileGroundBack( tile.type ) &&
            (map.isTileBackgroundNonEmpty( tile ) || map.isTileSolid( tile ) ||
			(map.isTileGrass( tile.type ) && bestinfo is null ) ))
		{
			if (!justCheck) {
				SendHitCommand( this, null, tilepos, attackVel, 1.0f );
			}
			
			hasHit = true;
			hitdata.tilepos = tilepos;
		}
	}
    
    if (bestinfo !is null && !hasHit)
    {
		hitdata.blobID = bestinfo.blob.getNetworkID();
    
		if (!justCheck)
		{
			SendHitCommand( this, bestinfo.blob, bestinfo.hitpos, bestinfo.blob.getPosition() - pos, damage );
		}
	}
    
}

bool isUrgent( CBlob@ this, CBlob@ b )
{
	return (b.getTeamNum() != this.getTeamNum() || b.hasTag("dead")) && b.hasTag("player");
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	// ignore collision for built blob
	BuildBlock[]@ blocks;
	this.get( "blocks", @blocks );	
	for (uint i = 0; i < blocks.length; i++)
	{
		BuildBlock@ b = blocks[i];
		if (b.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped( null );
			detached.IgnoreCollisionWhileOverlapped( null );
		}
	}

    // BUILD BLOB
    // take requirements from blob that is built and play sound
    // put out another one of the same
    if (detached.hasTag("temp blob"))	   // wont happen on client
    {
		if (!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}		

		uint i = this.get_u8( "buildblob" );
        if (blocks !is null && i >= 0 && i < blocks.length)
        {
            BuildBlock@ b = blocks[i];	
            if (b.name == detached.getName())
            {
                CInventory@ inv = this.getInventory();
                CBitStream missing;	  
				this.set_u8( "buildblob", 255 );
				this.set_TileType( "buildtile", 0 );
                if (hasRequirements( inv, b.reqs, missing ))
                {
                    server_TakeRequirements( inv, b.reqs );
                    this.getSprite().PlaySound( "/ConstructShort.ogg" );
                }
				// take out another one if in inventory
				server_BuildBlob( this, @blocks, i );

            }
        }
    }
    else // take out another seed
        if (detached.getName() == "seed")
        {
            CBlob@ anotherBlob = this.getInventory().getItem( detached.getName() );

            if (anotherBlob !is null)   {
                this.server_Pickup( anotherBlob );
            }
        }
}
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 modifier = getDefenceArmor(this);
	return damage * modifier;
}
void onAddToInventory( CBlob@ this, CBlob@ blob )
{
    // destroy built blob if somehow they got into inventory
    if (blob.hasTag("temp blob"))
    {
        blob.server_Die();
        blob.Untag("temp blob");
    }
}
f32 getArmorDamage(CBlob@ this )
{
	if (this.get_u8("armor") == 0)
	{
		return 0.5f;
	}
	else if (this.get_u8("armor") == 1)
	{
		return 0.7f;
	}
	else if (this.get_u8("armor") == 2)
	{
		return 0.9f;
	}
	else
	{
		return 0.5f;
	}
}
f32 getDefenceArmor(CBlob@ this)
{
	if (this.get_u8("armor") == 0)
	{
		return 0.7f;
	}
	else if (this.get_u8("armor") == 1)
	{
		return 0.8f;
	}
	else if (this.get_u8("armor") == 2)
	{
		return 0.6f;
	}
	else
	{
		return 1.0f;
	}
}
string findArmor(u8 armorNum)
{
	if (armorNum == 0)
	{
		return "bf_cobaltarmor";
	}
	else if (armorNum == 1)
	{
		return "bf_scandiumarmor";
	}
	else
	{
		return "";
	}
}
