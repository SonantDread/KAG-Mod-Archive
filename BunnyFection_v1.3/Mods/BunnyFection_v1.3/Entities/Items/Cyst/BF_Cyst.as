// BF_Cyst script

#include "Hitters.as";

const f32 DAMAGE = 0.5f;
const f32 AOE = 24.0f;

const u8 triggerTime = 90;

void onInit(CBlob@ this)
{
	this.set_u8( "gooTime", 50 );
	this.set_string( "here", " " );
	this.getCurrentScript().tickIfTag = "activated";
	this.addCommandID("getin");
    this.addCommandID("getout");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if ( caller.getDistanceTo(this) < 20.0f && this.get_string( "here") == " ")
    {
        CBitStream params;
        params.write_u16( caller.getNetworkID() );
        caller.CreateGenericButton( 4, Vec2f(0,0), this, this.getCommandID("getin"), "Get inside", params );
    }
	else if ((caller.getDistanceTo(this) < 20.0f && this.get_string( "here") != " " ) || caller is this )    // fix - iterate if more stuff in crate
    {
        CBitStream params;
        params.write_u16( caller.getNetworkID() );
        caller.CreateGenericButton( 6, Vec2f(0,0), this, this.getCommandID("getout"), "Get out", params );
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		this.Tag("activated");	
        this.SetLightRadius(5.0f);
        this.SetLightColor(SColor(255, 128, 200, 0 ));
        this.SetLight(true);

		CSprite@ sprite = this.getSprite();
		// add a countdown animation
		sprite.SetAnimation("pulsate");

		// ToDo:add a custom sound
		sprite.PlaySound("/branches1.ogg", 1.5f, 0.65f);
	}
	else if (cmd == this.getCommandID("getin"))
    {
        CBlob @caller = getBlobByNetworkID( params.read_u16() );

        if (caller !is null) {
            //this.server_PutInInventory( caller );
			this.set_string( "here", caller.getName());
			this.server_SetPlayer(caller.getPlayer());
			caller.server_Die();
        }
    } 
	else if (cmd == this.getCommandID("getout"))
    {
        CBlob @caller = getBlobByNetworkID( params.read_u16() );
		
        if (caller !is null) {
            //this.server_PutOutInventory( caller );
			CBlob @newBlob = server_CreateBlob( "bf_mutant1", 1, this.getPosition());
			newBlob.server_SetPlayer(this.getPlayer());
        }
		this.set_string( "here", " ");
    }
}

void onTick(CBlob@ this)
{
	if (!this.exists("triggerTimer"))
	{
		this.set_s32("triggerTimer", getGameTime() + triggerTime);
	}
	s32 Timer = this.get_s32("triggerTimer") - getGameTime();
	if (Timer <= 0)
	{
		Trigger(this);
	}
}

void Trigger(CBlob@ this)
{
	if(this.get_string( "here") != " ")
	{
		CBlob @newBlob = server_CreateBlob( "bf_mutant1", 1, this.getPosition());
		newBlob.server_SetPlayer(this.getPlayer());
	}
	this.server_Die();
}

void Create(CBlob@ this, CMap@ map, Vec2f checkPos, Tile tileCheck, int count)
{
	if (getNet().isServer())
	{
		if (canBeCreated(this, map, tileCheck))
		{
			CBlob@ ladder = server_CreateBlobNoInit("bf_laddercyst");
			ladder.server_setTeamNum(this.getTeamNum());
			ladder.set_u8("goo frame", count);
			ladder.setPosition(checkPos);
			ladder.Init();
		}
	}
}

void onDie( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	CBlob@[] aoeBlobs;
	CMap@ map = getMap();
	map.getBlobsInRadius( pos, AOE, @aoeBlobs );

	if ( aoeBlobs.length() > 0 )
	{
		for ( u8 i = 0; i < aoeBlobs.length(); i++ )
		{
			CBlob@ blob = aoeBlobs[i];
			if ( !getMap().rayCastSolidNoBlobs( pos, blob.getPosition() ) )
			{
				if ( getNet().isServer() )
					this.server_Hit( blob, pos, Vec2f_zero, DAMAGE, 40, blob.getName() == "bf_gooball" );
			}
		}
	}
}

bool canBeCreated(CBlob@ this, CMap@ map, Tile tileCheck)
{
	return map.isTileBackground(tileCheck) && !map.isTileGrass(tileCheck.type) && !map.hasTileSolidBlobs(tileCheck);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (this.getTeamNum() == byBlob.getTeamNum());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if ( !this.hasTag( "activated" ) || this.isAttached() || getGameTime() - this.get_u16( "detachTime" ) < 3 )
		return;
	
	if ( ( blob is null && solid ) || 
		 ( blob !is null && this.getTeamNum() != blob.getTeamNum() && blob.hasTag( "block" ) ) )
	{
		this.setPosition( point1 + normal * 1.4f * this.getRadius() );	
		this.getShape().SetStatic( true );
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getShape().SetStatic( false );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().SetZ( -1.0f );
	this.set_u16( "detachTime", getGameTime() );
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !this.hasTag("activated");
}