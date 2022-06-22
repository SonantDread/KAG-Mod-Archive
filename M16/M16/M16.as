#include "Hitters.as";

const int FIRE_INTERVAL = 5;

// blob
void onInit( CBlob@ this )
{
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null)
    {
        ap.SetKeysToTake( key_action1 );
    }

    this.addCommandID("shoot");

    this.set_u16("interval", 0);
}

void onTick( CBlob@ this )
{	
    if (this.isAttached())
    {
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
        CBlob@ holder = point.getOccupied();												   
        if (holder is null) { return; }

        CShape@ shape = this.getShape();
        CSprite@ sprite = this.getSprite();
        const f32 aimangle = getAimAngle(this,holder);

        // rotate towards mouse cursor
        sprite.ResetTransform();
        sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-8,2) : Vec2f(8,2) );
        sprite.animation.frame = 0;

        // fire
        if (holder.isMyPlayer())
		{
			u16 interval = this.get_u16("interval");
			if (interval > 0)
				interval--;			

			if (interval == 0)
			{
				if (point.isKeyPressed(key_action1))
				{
					Shoot( this, aimangle, holder );
					interval = FIRE_INTERVAL;						
				}
			}
			this.set_u16("interval", interval);	
		}
    }
    else
    {
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }
}

void Shoot( CBlob@ this, const f32 aimangle, CBlob@ holder )
{
	CBitStream params;
	params.write_Vec2f( this.getPosition() );
	params.write_f32( aimangle );
	params.write_netid( holder.getNetworkID() );
	this.SendCommand( this.getCommandID("shoot"), params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shoot"))
	{
		Vec2f pos = params.read_Vec2f();
		f32 angle = params.read_f32();
		CBlob@ holder = getBlobByNetworkID( params.read_netid() );
		if (holder is null)
			return;

		Vec2f velocity(1,0);
		CBlob@ bullet = server_CreateBlob( "bullet" );
		if (bullet !is null)
		{			
			Vec2f offset(15,0);

			if (this.isFacingLeft())
			{
				offset.RotateBy( angle, Vec2f(-8,-2) );
				bullet.setPosition( pos - offset );				
				angle += 180.0f;
			}
			else
			{
				offset.RotateBy( angle, Vec2f(-8,-2) );
				bullet.setPosition( pos + offset );		
			}

			velocity.RotateBy( angle );
			bullet.setVelocity( velocity * 20 );

			bullet.IgnoreCollisionWhileOverlapped( holder );
            bullet.SetDamageOwnerPlayer( holder.getPlayer() );
			bullet.server_setTeamNum( holder.getTeamNum() );
		}

		CSprite@ sprite = this.getSprite();
		sprite.PlaySound( "M16Fire.ogg" );
		// animate muzzle fire
		sprite.animation.frame = 1 + XORRandom(3);
		// pull back
		sprite.TranslateBy( Vec2f(1.0f,0.0) );
		// shell
		Vec2f velr = getRandomVelocity( 30, 4.3f, 40.0f) *0.1f;
		ParticlePixel( this.getPosition(), Vec2f( velocity.y, velocity.x*(this.isFacingLeft() ? 5.0f : -5.0f) ) + velr, 
			SColor(255,255,197,47), true );
	}
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();
    return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer( attached.getPlayer() );

	attached.server_setTeamNum( 1 );
	attached.getPlayer().server_setTeamNum(1);
	this.getSprite().PlaySound( "PickupM16.ogg" );
}

int lastTimePlayedSound = 0;
void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
    CSprite@ sprite = this.getSprite();
    sprite.ResetTransform();
    sprite.animation.frame = 0;
    this.setAngleDegrees( getAimAngle(this,detached) );

    detached.server_setTeamNum( 0 );
    detached.getPlayer().server_setTeamNum(0);
    if (getGameTime() - lastTimePlayedSound > 30 )
    {
    	this.getSprite().PlaySound( "LoseM16.ogg" );
    	lastTimePlayedSound = getGameTime();
	}
}