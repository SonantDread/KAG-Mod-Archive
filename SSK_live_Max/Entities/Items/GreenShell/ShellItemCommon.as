
// shell item common functions and constants

const u32 SHELL_DEATH_TIME = 600;

namespace ShellStates
{
	enum States
	{
		normal = 0,
		sliding_right,
		sliding_left,
		dead
	}
}

namespace ShellEvents
{
	enum Events
	{
		normal = 0,
		kick_start,
		wall_bump
	}
}

void SyncShellState( CBlob@ this, u8 state, u8 shellEvent = ShellEvents::normal )
{
	CBitStream bt;
	bt.write_u8(state);
	bt.write_u8(shellEvent);
	this.SendCommand( this.getCommandID("sync shell"), bt );
}

void HandleShellState( CBlob@ this, CBitStream@ bt )
{	
	CSprite@ thisSprite = this.getSprite();

	u8 state = bt.read_u8();
	u8 shellEvent = bt.read_u8();

	if (state == ShellStates::normal)
	{
		thisSprite.SetAnimation("default");
		this.setVelocity(Vec2f( 0.0f, this.getVelocity().y ));
	}
	else if (state == ShellStates::sliding_right)
	{
		thisSprite.SetAnimation("sliding");
		this.SetFacingLeft( false );
	}
	else if (state == ShellStates::sliding_left)
	{
		thisSprite.SetAnimation("sliding");
		this.SetFacingLeft( true );
	}
	else if (state == ShellStates::dead)
	{
		CShape@ thisShape = this.getShape();
		thisShape.getConsts().mapCollisions = false;
		thisShape.getConsts().collidable = false;
		thisShape.getConsts().bullet = false;
		thisShape.SetRotationsAllowed(true);
		thisSprite.SetAnimation("default");

		this.setVelocity(Vec2f(0, -6.0f));
		this.server_SetTimeToDie(2);

		if (this.get_u8( "stompVelocityX" ) > 0)
		{
			this.setAngularVelocity(25.0);   //Make shell spin upon being killed
		}
		else
		{
			thisSprite.SetFrame(1);
			this.setAngularVelocity(-25.0);
		}

		thisSprite.PlaySound( "mariostomp.ogg" );

		ParticleAnimated( "Sprites/Smoke.png",
							this.getPosition() + Vec2f(0.0,-4.0f),
							Vec2f(0.0,0.0f),
							1.0f, 1.0f, 
							3, 
							0.0f, true );
	}

	// event logic
	if (shellEvent == ShellEvents::wall_bump)
	{	
		// slightly speed up death timer for each wall bump
		if (getNet().isServer())
		{
			u32 deathTimer = this.get_u32("death timer");
			if (deathTimer <= SHELL_DEATH_TIME)
			{
				deathTimer += 5;
				this.set_u32("death timer", deathTimer);
			}
		}

		ParticleAnimated( "Sprites/dust.png",
						this.getPosition(),
						Vec2f(0.0,0.0f),
						1.0f, 1.0f, 
						3, 
						0.0f, true );

		thisSprite.PlaySound( "shellbump.ogg", 2.0f );
	}
	else if (shellEvent == ShellEvents::kick_start)
	{
		thisSprite.PlaySound( "mariostomp.ogg" );
	}

	// set state
	this.set_u8( "state", state );
}