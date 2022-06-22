#include "ShellItemCommon.as"
#include "Hitters.as";
#include "SSKShieldCommon.as";
#include "LimitedAttacks.as";
#include "Requirements_Tech.as";
#include "MakeDustParticle.as";
#include "SSKExplosion.as";
#include "FighterVarsCommon.as";

const f32 bounce_speed = 8.0f;
const f32 stomp_speed = 2.0f;
const f32 shell_speed = 6.0f;
const f32 shell_damage = 4.0f;

//blob functions
void onInit( CBlob@ this )
{
	this.addCommandID("sync shell");

	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(1000);
	sprite.getConsts().accurateLighting = false;
	
	this.Tag("invincible");

    this.set_u8("state", ShellStates::normal);
    this.set_u32("death timer", 0);

    this.getShape().SetRotationsAllowed(false);

	this.Tag("projectile");
	this.Tag("shell");

	this.getSprite().SetAnimation("default");

	this.SetMapEdgeFlags( u8(CBlob::map_collide_none) | u8(CBlob::map_collide_nodeath) );	// fall out of map in every direction
}

void onTick( CBlob@ this )
{
    u8 state = this.get_u8( "state" );

	CMap@ map = getMap();

	const f32 ts = map.tilesize;
	const f32 y_ts = ts * 0.2f;
	const f32 x_ts = ts * 1.4f;

	Vec2f pos = this.getPosition();
	
	if (state == ShellStates::sliding_right)
	{
		this.setVelocity(Vec2f( shell_speed, this.getVelocity().y ));
		
		if (getNet().isServer())
		{
			bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, y_ts-map.tilesize)) || map.isTileSolid(pos + Vec2f(x_ts, y_ts));
			if (surface_right)
			{
				SyncShellState(this, ShellStates::sliding_left, ShellEvents::wall_bump);
			}
		}
	}
	else if (state == ShellStates::sliding_left)
	{
		this.setVelocity(Vec2f( -shell_speed, this.getVelocity().y ));
		
		if (getNet().isServer())
		{
			bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, y_ts-map.tilesize)) || map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
			if (surface_left)
			{
				SyncShellState(this, ShellStates::sliding_right, ShellEvents::wall_bump);
			}
		}
	}

    const u16 mapWidth = map.tilemapwidth * map.tilesize;
    const u16 mapHeight = map.tilemapheight * map.tilesize;

    // die when falling below map
   	if (pos.y > mapHeight)
	{
		this.server_Die();
	}

	// warp to at sides of map
   	if (pos.x < 0)
	{
		this.setPosition(Vec2f(mapWidth, pos.y));
	}	
   	else if (pos.x > mapWidth)
	{
		this.setPosition(Vec2f(0, pos.y));
	}	

	// death timer
	if (getNet().isServer())
	{
		if (state == ShellStates::sliding_right || state == ShellStates::sliding_left)
		{
			u32 deathTimer = this.get_u32("death timer");
			if (deathTimer >= SHELL_DEATH_TIME)
			{
				SyncShellState(this, ShellStates::dead);
			}
			else
			{
				deathTimer++;
				this.set_u32("death timer", deathTimer);
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if( cmd == this.getCommandID("sync shell") )
    {
		HandleShellState( this, params );
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )	// not used by engine - collides = false
{
	return (blob.isCollidable() && blob.getShape().isStatic());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob is null) { // map collision?
        return;
    }

    if (blob.isCollidable() && blob.getShape().isStatic())
    {
    	return;
    }

	u8 state = this.get_u8( "state" );
    Vec2f pos = this.getPosition();
    Vec2f vel = blob.getOldVelocity();
	Vec2f moveVel = this.getOldVelocity();
	this.set_u8( "stompVelocityX", moveVel.x );
    
    Vec2f up(0.0f,-1.0f);
	
	if (getNet().isServer())
	{
		if (!blob.hasTag("player"))
		{
			if (state == ShellStates::normal)
			{
				if (blob.getOldVelocity().x > 0)
				{
					SyncShellState(this, ShellStates::sliding_right, ShellEvents::kick_start);
				}
				else if (blob.getOldVelocity().x < 0)
				{
					SyncShellState(this, ShellStates::sliding_left, ShellEvents::kick_start);
				}
			}
		}
	}
    
	if ( blob.getVelocity().y > stomp_speed ) // only allow falling blobs to stomp
    {                  
		//different force if buttons pressed
		f32 bounceForce = 	blob.isKeyPressed( key_jump ) ? 1.4f :
							blob.isKeyPressed( key_down ) ? 0.7f : 1.0f;
		
		bounceForce *= bounce_speed;
		
		//add bounce and "drag"
		vel = vel * 0.5f + up * bounceForce;
		
		blob.setVelocity(vel);
		this.AddForce(-vel * blob.getMass() * 0.1f );
		
		this.getSprite().PlaySound( "mariostomp.ogg" );
		
		if (getNet().isServer())
		{
			if (state == ShellStates::normal) // sitting still and doing nothing
			{
				if (blob.isFacingLeft()) //slide either right or left
				{
					SyncShellState(this, ShellStates::sliding_left);
				}
				else
				{
					SyncShellState(this, ShellStates::sliding_right);
				}
			}
			else if (state == ShellStates::sliding_right || state == ShellStates::sliding_left) //sliding
			{
				SyncShellState(this, ShellStates::normal);	//stop sliding
			}
		}
    }
	else if (state == ShellStates::sliding_right || state == ShellStates::sliding_left)
	{
		if (blob.hasTag("shell"))
		{
			if (getNet().isServer())
			{
				if (state == ShellStates::sliding_right)
				{	
					SyncShellState(this, ShellStates::sliding_left, ShellEvents::wall_bump);
				}
				else
				{
					SyncShellState(this, ShellStates::sliding_right, ShellEvents::wall_bump);
				}
			}
		}
		else
		{
			Vec2f velocity = blob.getPosition() - this.getPosition();
			FighterHitData fighterHitData(2, 4.0f, 0.04f);
			server_fighterHit(this, blob, blob.getPosition(), velocity, shell_damage, Hitters::spikes, true, fighterHitData);

			if (blob.hasTag("player"))
				this.getSprite().PlaySound( "whack1.ogg" );
		}
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().PlaySound("mariostomp.ogg");
	
	if (getNet().isServer())
	{
		if (detached.isFacingLeft())
			SyncShellState(this, ShellStates::sliding_left);
		else
			SyncShellState(this, ShellStates::sliding_right);		
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	u8 state = this.get_u8( "state" );
	return (state == ShellStates::normal);
}