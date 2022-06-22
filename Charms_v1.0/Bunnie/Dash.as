//Dash v1.0 by Strathos

#include "MakeDustParticle.as";
#include "CharmCommon.as";

f32 DASH_FORCE = 400.0f;//force applied

void onInit (CBlob@ this)
{
	this.set_u8( "dashCoolDown", 0 );
	this.set_bool( "dashing", false );
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick (CBlob@ this)
{
	if (this is null)
	{
		return;
	}

	bool dashing = this.get_bool( "dashing" );

	CControls@ controls = this.getControls();

	if (controls is null)
	{
		return;
	}

	CRules@ rules = getRules();

	if(rules is null)
	{
		return;
	}
	
	CPlayer@ player = this.getPlayer();

	if(player is null)
	{
		return;
	}

	PlayerCharm@ dashcharm = getCharmByName("dashcharm");

	if (dashcharm is null)
	{
		return;
	}

	u16 DASH_COOLDOWN = dashcharm.cooldown;

	Vec2f vel = this.getVelocity();
	const bool onground = this.isOnGround() || this.isOnLadder();
	const bool left = controls.ActionKeyPressed(AK_MOVE_LEFT);
	const bool right = controls.ActionKeyPressed(AK_MOVE_RIGHT);
	const bool down	= controls.ActionKeyPressed(AK_MOVE_DOWN);

	if(rules.get_bool("dashcharm_" + player.getUsername()))
	{
		if ( !dashing )
		{
			if (down && ( left || right ) && vel.Length() < 3.0f )
			{
				this.set_bool( "dashing", true );
				this.set_u8( "dashCoolDown", 0 );
				MakeDustParticle( this.getPosition() + Vec2f( 0.0f, 9.0f ), "/DustSmall.png");
				this.getSprite().PlaySound("/StoneJump");//StoneStep7.ogg
				f32 xCompensate;
				if ( left )
				{
					xCompensate = 50.0f * ( vel.x > 0.0f ? vel.x : vel.x * 1.5f );
					this.AddForce( Vec2f( -DASH_FORCE, 10.0f ) - Vec2f( xCompensate, 0.0f ) );
				}
				else if ( right )
				{
					xCompensate = 50.0f * ( vel.x < 0.0f ? vel.x : vel.x * 1.5f );
					this.AddForce( Vec2f( DASH_FORCE, 10.0f ) - Vec2f( xCompensate, 0.0f ) );
				}
				getRules().set_u32("dashcharm_cd" + player.getUsername(), getGameTime());
				getRules().Sync("dashcharm_cd" + player.getUsername(), true);
			}
		}
		else
		{
			u8 dashCoolDown = this.get_u8( "dashCoolDown" );
			this.set_u8( "dashCoolDown", ( dashCoolDown + 1 ) );
			if ( ( ( !down || ( !left && !right ) ) && dashCoolDown > DASH_COOLDOWN ) || dashCoolDown > DASH_COOLDOWN * 3 )
				this.set_bool( "dashing", false );
		}
	}
}