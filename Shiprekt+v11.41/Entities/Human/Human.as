#include "HumanCommon.as"
#include "EmotesCommon.as"
#include "MakeBlock.as"
#include "WaterEffects.as"
#include "IslandsCommon.as"
#include "BlockCommon.as"
#include "Booty.as"
#include "AccurateSoundPlay.as"
#include "TileCommon.as"

int useClickTime = 0;
const int PUNCH_RATE = 15;
const int FIRE_RATE = 40;
const int CONSTRUCT_RATE = 14;
const int CONSTRUCT_VALUE = 5;
const int CONSTRUCT_RANGE = 48;
const f32 BULLET_SPREAD = 0.2f;
const f32 BULLET_SPEED = 9.0f;
const f32 BULLET_RANGE = 350.0f;
const u8 BUILD_MENU_COOLDOWN = 30;
const Vec2f BUILD_MENU_SIZE = Vec2f( 6, 3 );
const Vec2f TOOLS_MENU_SIZE = Vec2f( 1, 3 );
Random _shotspreadrandom(0x11598); //clientside

void onInit( CBlob@ this )
{
	this.Tag("player");	 
	this.addCommandID("get out");
	this.addCommandID("shoot");
	this.addCommandID("construct");
	this.addCommandID("punch");
	this.addCommandID("giveBooty");
	this.addCommandID("releaseOwnership");
	this.addCommandID("swap tool");
	this.set_f32("cam rotation", 0.0f);

	if ( getNet().isClient() )
	{
		CBlob@ core = getMothership( this.getTeamNum() );
		if (core !is null) 
		{
			this.setPosition( core.getPosition() );
			this.set_u16( "shipID", core.getNetworkID() );
			this.set_s8( "stay count", 3 );
		}
	}
	
	this.SetMapEdgeFlags( u8(CBlob::map_collide_up) |
		u8(CBlob::map_collide_down) |
		u8(CBlob::map_collide_sides) );
	
	this.set_u32("menu time", 0);
	this.set_bool( "build menu open", false );
	this.set_string("last buy", "coupling");
	this.set_string("current tool", "pistol");
	this.set_u32("fire time", 0);
	this.set_u32("punch time", 0);
	this.set_u32("groundTouch time", 0);
	this.set_bool( "onGround", true );//for syncing
	this.getShape().getVars().onground = true;
	directionalSoundPlay( "Respawn", this.getPosition(), 2.5f );
}

void onTick( CBlob@ this )
{
	Move( this );
	
	u32 gameTime = getGameTime();

	if (this.isMyPlayer())
	{
		PlayerControls( this );

		if ( gameTime % 10 == 0 )
		{
			this.set_bool( "onGround", this.isOnGround() );
			this.Sync( "onGround", false );
		}
	}

	CSprite@ sprite = this.getSprite();
    CSpriteLayer@ laser = sprite.getSpriteLayer( "laser" );

	//kill laser after a certain time
	if ( laser !is null && !this.isKeyPressed(key_action2) && this.get_u32("fire time") + CONSTRUCT_RATE < gameTime )
	{
		sprite.RemoveSpriteLayer("laser");
	}
	
	// stop reclaim effects
	if (this.isKeyJustReleased(key_action2) || this.isAttached())
	{
		this.set_bool( "reclaimPropertyWarn", false );
		if ( sprite.getEmitSoundPaused() == false )
		{
			sprite.SetEmitSoundPaused(true);
		}
		sprite.RemoveSpriteLayer("laser");
	}
}

void Move( CBlob@ this )
{
	const bool myPlayer = this.isMyPlayer();
	const f32 camRotation = myPlayer ? getCamera().getRotation() : this.get_f32("cam rotation");
	const bool attached = this.isAttached();
	Vec2f pos = this.getPosition();	
	Vec2f aimpos = this.getAimPos();
	Vec2f forward = aimpos - pos;
	CShape@ shape = this.getShape();
	CSprite@ sprite = this.getSprite();
	
	string currentTool = this.get_string( "current tool" );

	if (myPlayer)
	{
		this.set_f32("cam rotation", camRotation);
		this.Sync("cam rotation", false);
	}
	
	if (!attached)
	{
		const bool up = this.isKeyPressed( key_up );
		const bool down = this.isKeyPressed( key_down );
		const bool left = this.isKeyPressed( key_left);
		const bool right = this.isKeyPressed( key_right );	
		const bool punch = this.isKeyPressed( key_action1 );
		const bool shoot = this.isKeyPressed( key_action2 );
		const u32 time = getGameTime();
		const f32 vellen = shape.vellen;
		Island@ isle = getIsland( this );
		CMap@ map = this.getMap();
		const bool solidGround = shape.getVars().onground = attached || isle !is null || isTouchingLand( pos );
		if ( !this.wasOnGround() && solidGround )
			this.set_u32("groundTouch time", time);//used on collisions

		// move
		Vec2f moveVel;

		if (up)	{
			moveVel.y -= Human::walkSpeed;
		}
		else if (down)	{
			moveVel.y += Human::walkSpeed;
		}
		
		if (left)	{
			moveVel.x -= Human::walkSpeed;
		}
		else if (right)	{
			moveVel.x += Human::walkSpeed;
		}

		if (!solidGround)
		{
			if ( isTouchingShoal(pos) )
			{
				moveVel *= 0.8f;
			}
			else
			{
				moveVel *= Human::swimSlow;
			}

			u8 tickStep = v_fastrender ? 15 : 5;

			if( (time + this.getNetworkID()) % tickStep == 0)
				MakeWaterParticle(pos, Vec2f()); 

			if ( this.wasOnGround() && time - this.get_u32( "lastSplash" ) > 45 )
			{
				directionalSoundPlay( "SplashFast", pos );
				this.set_u32( "lastSplash", time );
			}
		}
		else
		{		
			// punch
			if (punch && !Human::isHoldingBlocks(this) && canPunch(this))
			{
				Punch( this );
			}
			
			//speedup on own mothership
			if ( isle !is null && isle.isMothership && isle.centerBlock !is null )
			{
				CBlob@ thisCore = getMothership( this.getTeamNum() );
				if ( thisCore !is null && thisCore.getShape().getVars().customData == isle.centerBlock.getShape().getVars().customData )
					moveVel *= 1.35f;
			}
		}
		
		//tool actions
		if (shoot && !punch)
		{
			if ( currentTool == "pistol" && canShootPistol( this ) ) // shoot
			{
				ShootPistol( this );
				sprite.SetAnimation("shoot");
			}
			else if ( currentTool == "deconstructor" ) //reclaim
			{
				Construct( this );
				sprite.SetAnimation("reclaim");
			}
			else if ( currentTool == "reconstructor" ) //repair
			{
				Construct( this );
				sprite.SetAnimation("repair");
			}
		}		

		//canmove check
		if ( !getRules().get_bool( "whirlpool" ) || solidGround )
		{
			moveVel.RotateBy( camRotation );
			Vec2f nextPos = (pos + moveVel*4.0f);
			if ( isTouchingRock( nextPos ) )
			{
				moveVel = Vec2f(0,0);
			}
			
			this.setVelocity( moveVel );
		}

		// face

		f32 angle = camRotation;
		forward.Normalize();
		
		if (sprite.isAnimation("shoot") || sprite.isAnimation("reclaim") || sprite.isAnimation("repair"))
			angle = -forward.Angle();
		else
		{
			if (up && left) angle += 225;
			else if (up && right) angle += 315;
			else if (down && left) angle += 135;
			else if (down && right) angle += 45;
			else if (up) angle += 270;
			else if (down) angle += 90;
			else if (left) angle += 180;
			else if (right) angle += 0;
			else angle = -forward.Angle();
		}
		
		while(angle > 360)
			angle -= 360;
		while(angle < 0)
			angle += 360;

		shape.SetAngleDegrees( angle );	

		// artificial stay on ship
		if ( myPlayer )
		{
			CBlob@ islandBlob = getIslandBlob( this );
			if (islandBlob !is null)
			{
				this.set_u16( "shipID", islandBlob.getNetworkID() );	
				this.set_s8( "stay count", 3 );
			}
			else
			{
				CBlob@ shipBlob = getBlobByNetworkID( this.get_u16( "shipID" ) );
				if (shipBlob !is null)
				{
					s8 count = this.get_s8( "stay count" );		
					count--;
					if (count <= 0){
						this.set_u16( "shipID", 0 );	
					}
					else if ( !Block::isSolid( Block::getType( shipBlob ) ) && !up && !left && !right && !down )
					{
						Island@ isle = getIsland( shipBlob.getShape().getVars().customData );
						if ( isle !is null && isle.vel.Length() > 1.0f )
							this.setPosition( shipBlob.getPosition() );
					}
					this.set_s8( "stay count", count );		
				}
			}
		}
	}
	else
	{
		shape.getVars().onground = true;
	}
}

void PlayerControls( CBlob@ this )
{
	CHUD@ hud = getHUD();
	CControls@ controls = getControls();
	bool toolsKey = controls.isKeyJustPressed( controls.getActionKeyKey( AK_PARTY ) );
	CSprite@ sprite = this.getSprite();
	
	// bubble menu
	if (this.isKeyJustPressed(key_bubbles))
	{
		this.CreateBubbleMenu();
	}

	if (this.isAttached())
	{
	    // get out of seat
		if (this.isKeyJustPressed(key_use))
		{
			CBitStream params;
			this.SendCommand( this.getCommandID("get out"), params );
		}

		// aim cursor
		hud.SetCursorImage("AimCursor.png", Vec2f(32,32));
		hud.SetCursorOffset( Vec2f(-32, -32) );		
	}
	else
	{
		// use menu
	    if (this.isKeyJustPressed(key_use))
	    {
	        useClickTime = getGameTime();
	    }
	    if (this.isKeyPressed(key_use))
	    {
	        this.ClearMenus();
			this.ClearButtons();
	        this.ShowInteractButtons();
	    }
	    else if (this.isKeyJustReleased(key_use))
	    {
	    	bool tapped = (getGameTime() - useClickTime) < 10; 
			this.ClickClosestInteractButton( tapped ? this.getPosition() : this.getAimPos(), this.getRadius()*2 );

	        this.ClearButtons();
	    }

	    // default cursor
		if ( hud.hasMenus() )
			hud.SetDefaultCursor();
		else
		{
			hud.SetCursorImage("PointerCursor.png", Vec2f(32,32));
			hud.SetCursorOffset( Vec2f(-32, -32) );		
		}
	}

	// click action1 to click buttons
	if (hud.hasButtons() && this.isKeyPressed(key_action1) && !this.ClickClosestInteractButton( this.getAimPos(), 2.0f ))
	{
	}

	// click grid menus

    if (hud.hasButtons())
    {
        if (this.isKeyJustPressed(key_action1))
        {
		    CGridMenu @gmenu;
		    CGridButton @gbutton;
		    this.ClickGridMenu(0, gmenu, gbutton); 
	    } else if ( this.isKeyJustPressed(key_inventory) )
		{
			
		}
	}
	
	//build menu
	if ( this.isKeyJustPressed(key_inventory) && !this.isAttached() )
	{
		CBlob@ core = getMothership( this.getTeamNum() );
		if ( core !is null && !core.hasTag( "critical" ) )
		{
			Island@ pIsle = getIsland( this );
			bool canShop = pIsle !is null && pIsle.centerBlock !is null 
							&& ( (pIsle.centerBlock.getShape().getVars().customData == core.getShape().getVars().customData) 
									|| (pIsle.isStation && pIsle.centerBlock.getTeamNum() == this.getTeamNum()) );
									
			if ( !Human::isHoldingBlocks(this) )
			{
				if ( !hud.hasButtons() )
				{
					if ( canShop )
					{
						this.set_bool( "build menu open", true );
					
						CBitStream params;
						params.write_u16( core.getNetworkID() );
						u32 gameTime = getGameTime();
						
						if ( gameTime - this.get_u32( "menu time" ) > BUILD_MENU_COOLDOWN )
						{
							Sound::Play( "buttonclick.ogg" );
							this.set_u32( "menu time", gameTime );
							BuildShopMenu( this, core, "mCore Block Transmitter", Vec2f(0,0) );
						}
						else
							Sound::Play( "/Sounds/bone_fall1.ogg" );
					}
					else
						Sound::Play( "/Sounds/bone_fall1.ogg" );
				} 
				else if ( hud.hasMenus() )
				{
					this.ClearMenus();
					Sound::Play( "buttonclick.ogg" );
					
					if ( this.get_bool( "build menu open" ) )
					{
						CBitStream params;
						params.write_u16( this.getNetworkID() );
						params.write_string( this.get_string( "last buy" ) );
						
						core.SendCommand( core.getCommandID("buyBlock"), params );
					}
					this.set_bool( "build menu open", false );
				}
			}
			else if ( canShop )
			{
				CBitStream params;
				params.write_u16( this.getNetworkID() );
				core.SendCommand( core.getCommandID("returnBlocks"), params );
			}
		}
	}

	//tools menu
	if ( toolsKey && !this.isAttached() )
	{
		if ( !hud.hasButtons() )
		{	
			this.set_bool( "build menu open", false );
		
			CBitStream params;
			params.write_u16( this.getNetworkID() );
			
			Sound::Play( "buttonclick.ogg" );
			BuildToolsMenu( this, "Tools Menu", Vec2f(0,0) );
			
		} else if ( hud.hasMenus() )
		{
			this.ClearMenus();
			Sound::Play( "buttonclick.ogg" );
		}
	}
}

void BuildShopMenu( CBlob@ this, CBlob@ core, string description, Vec2f offset )
{
	CRules@ rules = getRules();
	Block::Costs@ c = Block::getCosts( rules );
	Block::Weights@ w = Block::getWeights( rules );
	
	if ( c is null || w is null )
		return;
		
	CGridMenu@ menu = CreateGridMenu( this.getScreenPos() + offset, core, BUILD_MENU_SIZE, description );
	u32 gameTime = getGameTime();
	string repBuyTip = "\nPress the inventory key to buy again.\n";
	u16 WARMUP_TIME = getPlayersCount() > 1 && !rules.get_bool("freebuild") ? rules.get_u16( "warmup_time" ) : 0;
	string warmupText = "Weapons are enabled after the warm-up time ends.\n";
	
	if ( menu !is null ) 
	{
		menu.deleteAfterClick = true;
		
		u16 netID = this.getNetworkID();
		string lastBuy = this.get_string( "last buy" );
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "seat" );
			
			CGridButton@ button = menu.AddButton( "$SEAT$", "Seat $" + c.seat, core.getCommandID("buyBlock"), params );
			
			bool select = lastBuy == "seat";
			if ( select )
				button.SetSelected(2);
			
			button.SetHoverText( "Use it to control your ship. It can also release and produce Couplings. Breaks on impact.\nWeight: " + w.seat * 100 + "rkt\n" + ( select ? repBuyTip : "" ) + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "propeller" );
				
			CGridButton@ button = menu.AddButton( "$PROPELLER$", "Engine $" + c.propeller, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "propeller";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A ship motor with some armor plating for protection. Resists flak.\nWeight: " + w.propeller * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "solid" );
				
			CGridButton@ button = menu.AddButton( "$SOLID$", "Wooden Hull $" + c.solid, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "solid";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A very tough block for protecting delicate components. Can effectively negate damage from bullets, flak, and to some extent cannons. \nWeight: " + w.solid * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}

		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "wood" );
				
			CGridButton@ button = menu.AddButton( "$WOOD$", "Wooden Platform $" + c.wood, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "wood";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A good quality wooden floor panel. Get that deck shining :)\nWeight: " + w.wood * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}

		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "door" );
				
			CGridButton@ button = menu.AddButton( "$DOOR$", "Wooden Door $" + c.door, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "door";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A wooden door. Opens and closes :)\nWeight: " + w.door * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}

		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "coupling" );
				
			CGridButton@ button = menu.AddButton( "$COUPLING$", "Coupling $" + c.coupling, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "coupling";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A versatile block used to hold and release other blocks.\nWeight: " + w.coupling * 200 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}
		{//blank
			CGridButton@ button = menu.AddEmptyButton();
			button.SetEnabled( false );
		}
		//TOOLS
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "harvester" );
				
			CGridButton@ button = menu.AddButton( "$HARVESTER$", "Harvester $" + c.harvester, core.getCommandID("buyBlock"), params );
		
			bool select = lastBuy == "harvester";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "An industrial-sized deconstructor that allows you to quickly mine resources from ship debris. Largely ineffective against owned ships. \nWeight: " + w.machinegun * 100 + "rkt \nAmmoCap: infinite\n" + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "ramEngine" );
				
			CGridButton@ button = menu.AddButton( "$RAMENGINE$", "Ram Engine $" + c.ramEngine, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "ramEngine";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "An engine that trades protection for extra power. Will break on impact with anything!\nWeight: " + w.ramEngine * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "ram" );
				
			CGridButton@ button = menu.AddButton( "$RAM$", "Ram Hull $" + c.ram, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "ram";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A rigid block that fractures on contact with other blocks. Will destroy itself as well as the block it hits. Can effectively negate damage from bullets, flak, and to some extent cannons. \nWeight: " + w.ram * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "repulsor" );
				
			CGridButton@ button = menu.AddButton( "$REPULSOR$", "Repulsor $" + c.repulsor, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "repulsor";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "Explodes pushing ships away. Can be triggered remotely or by impact. Activates in a chain.\nWeight: " + w.repulsor * 200 + "rkt\n" + ( select ? repBuyTip : "" ) );
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "bomb" );
				
			CGridButton@ button = menu.AddButton( "$BOMB$", "Bomb $" + c.bomb, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "bomb";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "Explodes on contact. Very useful against Solid blocks. (has buy-cooldown time).\nWeight: " + w.bomb * 100 + "rkt\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "harpoon" );
				
			CGridButton@ button = menu.AddButton( "$HARPOON$", "Harpoon $" + c.harpoon, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "harpoon";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A manual-fire harpoon launcher. Can be used for grabbing, towing, or water skiing!.\nWeight: " + w.harpoon * 100 + "rkt \nAmmoCap: medium\n" + ( select ? repBuyTip : "" ) );	
		}			
		//WEAPONS
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "pointDefense" );
				
			CGridButton@ button = menu.AddButton( "$POINTDEFENSE$", "Point Defense $" + c.pointDefense, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "pointDefense";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "A short-ranged automated defensive turret that fires lasers with pin-point accuracy. Able to deter enemy personnel and neutralize incoming projectiles such as flak.\nWeight: " 
										+ w.pointDefense * 100 + "rkt \nAmmoCap: medium\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "machinegun" );
				
			CGridButton@ button = menu.AddButton( "$MACHINEGUN$", "Machinegun $" + c.machinegun, core.getCommandID("buyBlock"), params );
		
			bool select = lastBuy == "machinegun";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "A fixed rapid-fire, lightweight, machinegun that fires high-velocity projectiles uncounterable by point defense. Effective against engines, flak cannons, and other weapons. \nWeight: " + w.machinegun * 100 + "rkt \nAmmoCap: high\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "cannon" );
				
			CGridButton@ button = menu.AddButton( "$CANNON$", "AP Cannon $" + c.cannon, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "cannon";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "A fixed cannon that fires momentum-bearing armor-piercing shells. Can penetrate up to 2 solid blocks, but deals less damage after each penetration. Effective against engines, flak cannons, and other weapons.\nWeight: " + w.cannon * 100 + "rkt \nAmmoCap: medium\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "flak" );
				
			CGridButton@ button = menu.AddButton( "$FLAK$", "Flak Cannon $" + c.flak, core.getCommandID("buyBlock"), params );
	
			bool select = lastBuy == "flak";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "A long-ranged automated defensive turret that fires high-explosive fragmentation shells with a proximity fuse. Best used as an unarmored ship deterrent. Effective against missiles, engines, and cores.\nWeight: " + w.flak * 100 + "rkt \nAmmoCap: medium\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "launcher" );
				
			CGridButton@ button = menu.AddButton( "$LAUNCHER$", "Missile Launcher $" + c.launcher, core.getCommandID("buyBlock"), params );
		
			bool select = lastBuy == "launcher";
			if ( select )
				button.SetSelected(2);
				
			if ( gameTime > WARMUP_TIME )
				button.SetHoverText( "A fixed tube that fires a slow missile with short-ranged guidance. Best used for close-ranged bombing, but can be used at range. Very effective against armored ships.\nWeight: " + w.launcher * 100 + "rkt \nAmmoCap: low\n" + ( select ? repBuyTip : "" ) );
			else
			{
				button.SetHoverText( warmupText );
				button.SetEnabled( false );
			}
		}
	}
}

void BuildToolsMenu( CBlob@ this, string description, Vec2f offset )
{
	CRules@ rules = getRules();
	Block::Costs@ c = Block::getCosts( rules );
	Block::Weights@ w = Block::getWeights( rules );
	
	if ( c is null || w is null )
		return;
		
	CGridMenu@ menu = CreateGridMenu( this.getScreenPos() + offset, this, TOOLS_MENU_SIZE, description );
	u32 gameTime = getGameTime();
	
	if ( menu !is null ) 
	{
		menu.deleteAfterClick = true;
		
		u16 netID = this.getNetworkID();
		string currentTool = this.get_string( "current tool" );
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "pistol" );
			
			CGridButton@ button = menu.AddButton( "$PISTOL$", "Pistol", this.getCommandID("swap tool"), params );
			
			bool select = currentTool == "pistol";
			if ( select )
				button.SetSelected(2);
			
			button.SetHoverText( "A basic, ranged, personal defence weapon.");
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "deconstructor" );
				
			CGridButton@ button = menu.AddButton( "$DECONSTRUCTOR$", "Deconstructor", this.getCommandID("swap tool"), params );
	
			bool select = currentTool == "deconstructor";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A tool that can reclaim ship parts for booty.");
		}
		{
			CBitStream params;
			params.write_u16( netID );
			params.write_string( "reconstructor" );
				
			CGridButton@ button = menu.AddButton( "$RECONSTRUCTOR$", "Reconstructor", this.getCommandID("swap tool"), params );
	
			bool select = currentTool == "reconstructor";
			if ( select )
				button.SetSelected(2);
				
			button.SetHoverText( "A tool that can repair ship parts at the cost of booty. Can repair cores at a rate of 10 booty per 1% health.");
		}
	}
}

void Punch( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	Vec2f aimVector = this.getAimPos() - pos;
	
    HitInfo@[] hitInfos;
    if ( this.getMap().getHitInfosFromCircle( pos, this.getRadius()*4.0f, this, @hitInfos) )
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			CBlob @b = hitInfos[i].blob;
			if (b is null)
				continue;
			//dirty fix: get occupier if seat
			if( b.hasTag( "seat" ) )
			{
				AttachmentPoint@ seat = b.getAttachmentPoint(0);
				@b = seat.getOccupied();
			}
			if (b !is null && b.getName() == "human" && b.getTeamNum() != this.getTeamNum())
			{
				if (this.isMyPlayer())
				{
					CBitStream params;
					params.write_u16( b.getNetworkID() );
					this.SendCommand( this.getCommandID("punch"), params );
				}
				return;
			}
		}
	}

	// miss
	directionalSoundPlay( "throw", pos );
	this.set_u32("punch time", getGameTime());	
}

void ShootPistol( CBlob@ this )
{
	if ( !this.isMyPlayer() )
		return;

	Vec2f pos = this.getPosition();
	Vec2f aimVector = this.getAimPos() - pos;
	const f32 aimdist = aimVector.Normalize();

	Vec2f offset(_shotspreadrandom.NextFloat() * BULLET_SPREAD,0);
	offset.RotateBy(_shotspreadrandom.NextFloat() * 360.0f, Vec2f());
	
	Vec2f vel = (aimVector * BULLET_SPEED) + offset;

	f32 lifetime = Maths::Min( 0.05f + BULLET_RANGE/BULLET_SPEED/32.0f, 1.35f);

	CBitStream params;
	params.write_Vec2f( vel );
	params.write_f32( lifetime );

	Island@ island = getIsland( this );
	if ( island !is null && island.centerBlock !is null )//relative positioning
	{
		params.write_bool( true );
		Vec2f rPos = ( pos + aimVector*3 ) - island.centerBlock.getPosition();
		params.write_Vec2f( rPos );
		u32 islandColor = island.centerBlock.getShape().getVars().customData;
		params.write_u32( islandColor );
	} else//absolute positioning
	{
		params.write_bool( false );
		Vec2f aPos = pos + aimVector*9;
		params.write_Vec2f( aPos );
	}
	
	this.SendCommand( this.getCommandID("shoot"), params );
}

void Construct( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	CBlob@ mBlob = getMap().getBlobAtPosition( aimPos );
	Vec2f aimVector = aimPos - pos;

	Vec2f offset(_shotspreadrandom.NextFloat() * BULLET_SPREAD,0);
	offset.RotateBy(_shotspreadrandom.NextFloat() * 360.0f, Vec2f());
	CSprite@ sprite = this.getSprite();
	
	string currentTool = this.get_string( "current tool" );

	if (mBlob !is null && aimVector.getLength() <= CONSTRUCT_RANGE)
	{
		if ( this.isMyPlayer() )
		{
			CBitStream params;
			params.write_Vec2f( pos );
			params.write_Vec2f( aimPos );
			params.write_netid( mBlob.getNetworkID() );
			
			this.SendCommand( this.getCommandID("construct"), params );
		}
		
		if ( getNet().isClient() )//effects
		{
			Vec2f barrelPos = pos + Vec2f(0.0f, 0.0f).RotateBy(aimVector.Angle());
			f32 offsetAngle = aimVector.Angle() - (mBlob.getPosition() - pos).Angle(); 
			
			CSpriteLayer@ laser = sprite.getSpriteLayer("laser");
			if (laser !is null)//laser management
			{
				laser.SetVisible(true);
				f32 laserLength = Maths::Max(0.1f, (aimPos - barrelPos).getLength() / 32.0f);						
				laser.ResetTransform();						
				laser.ScaleBy( Vec2f(laserLength, 1.0f) );							
				laser.TranslateBy( Vec2f(laserLength*16.0f, + 0.5f) );
				laser.RotateBy( offsetAngle, Vec2f());
				laser.setRenderStyle(RenderStyle::light);
			}
		}
		if ( sprite.getEmitSoundPaused() == true )
		{
			sprite.SetEmitSoundPaused(false);
		}	
	}
	else
	{
		if ( getNet().isClient() )//effects
		{
			sprite.RemoveSpriteLayer("laser");
			
			string beamSpriteFilename;
			if ( currentTool == "deconstructor" )
				beamSpriteFilename = "ReclaimBeam";
			else if ( currentTool == "reconstructor" )
				beamSpriteFilename = "RepairBeam";
				
			CSpriteLayer@ laser = sprite.addSpriteLayer("laser", beamSpriteFilename + ".png", 32, 16);
			
			if (laser !is null)//laser management
			{
				Animation@ defaultAnim = laser.addAnimation( "default", 1, true );
				int[] defaultAnimFrames = { 16 };
				defaultAnim.AddFrames(defaultAnimFrames);
				laser.SetAnimation("default");
				laser.SetVisible(true);
				f32 laserLength = Maths::Min(1.0f*CONSTRUCT_RANGE / 32.0f, (aimPos - pos).getLength() / 32.0f);						
				laser.ResetTransform();						
				laser.ScaleBy( Vec2f(laserLength, 0.5f) );							
				laser.TranslateBy( Vec2f(laserLength*16.0f, + 0.5f) );
				laser.setRenderStyle(RenderStyle::light);
				laser.SetRelativeZ(-1); 
			}
		}
		if ( sprite.getEmitSoundPaused() == false )
		{
			sprite.SetEmitSoundPaused(true);
		}
	}
}

bool canPunch( CBlob@ this )
{
	return !this.hasTag( "dead" ) && this.get_u32("punch time") + PUNCH_RATE < getGameTime();
}

bool canShootPistol( CBlob@ this )
{
	return !this.hasTag( "dead" ) && this.get_string( "current tool" ) == "pistol" && this.get_u32("fire time") + FIRE_RATE < getGameTime();
}

bool canConstruct( CBlob@ this )
{
	return !this.hasTag( "dead" ) && (this.get_string( "current tool" ) == "deconstructor" || this.get_string( "current tool" ) == "reconstructor")
				&& this.get_u32("fire time") + CONSTRUCT_RATE < getGameTime();
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (getNet().isServer() && this.getCommandID("get out") == cmd){
		this.server_DetachFromAll();
	}
	else if (this.getCommandID("punch") == cmd  && canPunch( this ) )
	{
		CBlob@ b = getBlobByNetworkID( params.read_u16() );
		if (b !is null && b.getName() == "human" && b.getDistanceTo( this ) < 100.0f)
		{
			Vec2f pos = b.getPosition();
			this.set_u32("punch time", getGameTime());
			directionalSoundPlay( "Kick.ogg", pos );
			ParticleBloodSplat( pos, false );

			if ( getNet().isServer() )
				this.server_Hit( b, pos, Vec2f_zero, 0.25f, 0, false );
		}
	}
	else if (this.getCommandID("shoot") == cmd && canShootPistol( this ) )
	{
		Vec2f velocity = params.read_Vec2f();
		f32 lifetime = params.read_f32();
		Vec2f pos;
		
		if ( params.read_bool() )//relative positioning
		{
			Vec2f rPos = params.read_Vec2f();
			int islandColor = params.read_u32();
			Island@ island = getIsland( islandColor );
			if ( island !is null && island.centerBlock !is null )
			{
				pos = rPos + island.centerBlock.getPosition();
				velocity += island.vel;
			}
			else
			{
				warn( "BulletSpawn: island or centerBlock is null" );
				Vec2f pos = this.getPosition();//failsafe (bullet will spawn lagging behind player)
			}
		}
		else
			pos = params.read_Vec2f();
		
		if (getNet().isServer())
		{
            CBlob@ bullet = server_CreateBlob( "bullet", this.getTeamNum(), pos );
            if (bullet !is null)
            {
            	if (this.getPlayer() !is null){
                	bullet.SetDamageOwnerPlayer( this.getPlayer() );
                }
                bullet.setVelocity( velocity );
                bullet.server_SetTimeToDie( lifetime ); 
            }
    	}
		
		this.set_u32("fire time", getGameTime());	
		shotParticles(pos + Vec2f(1,0).RotateBy(-velocity.Angle())*6.0f, velocity.Angle());
		directionalSoundPlay( "Gunshot.ogg", pos, 0.75f );
	}
	else if (this.getCommandID("construct") == cmd && canConstruct( this ) )
	{
		Vec2f pos = params.read_Vec2f();
		Vec2f aimPos = params.read_Vec2f();
		CBlob@ mBlob = getBlobByNetworkID( params.read_netid() );
		
		CPlayer@ thisPlayer = this.getPlayer();						
		if ( thisPlayer is null ) 
			return;		
		
		string currentTool = this.get_string( "current tool" );
		Vec2f aimVector = aimPos - pos;	 
		
		if (mBlob !is null)
		{		
			CRules@ rules = getRules();
			const int blockType = mBlob.getSprite().getFrame();
			Island@ island = getIsland( mBlob.getShape().getVars().customData );
				
			const f32 mBlobCost = mBlob.get_u32("cost");
			f32 mBlobHealth = mBlob.getHealth();
			f32 mBlobInitHealth = mBlob.getInitialHealth();
			const f32 initialReclaim = mBlob.get_f32("initial reclaim");
			f32 currentReclaim = mBlob.get_f32("current reclaim");
			
			f32 fullConstructAmount;
			if ( mBlobCost > 0 )
				fullConstructAmount = (CONSTRUCT_VALUE/mBlobCost)*initialReclaim;
			else if ( blockType == Block::MOTHERSHIP5 )
				fullConstructAmount = (0.01f)*mBlobInitHealth;
			else
				fullConstructAmount = 0.0f;
							
			if ( island !is null)
			{
				string islandOwnerName = island.owner;
				CBlob@ mBlobOwnerBlob = getBlobByNetworkID(mBlob.get_u16( "ownerID" ));
				
				if ( currentTool == "deconstructor" && !(blockType == Block::MOTHERSHIP5) && mBlobCost > 0 )
				{
					f32 deconstructAmount = 0;
					if ( islandOwnerName == "" 
						|| (islandOwnerName == "" && mBlob.get_string( "playerOwner" ) == "")
						|| islandOwnerName == thisPlayer.getUsername() 
						|| mBlob.get_string( "playerOwner" ) == thisPlayer.getUsername()
						|| blockType == Block::STATION)
					{
						deconstructAmount = fullConstructAmount; 
					}
					else
					{
						deconstructAmount = (1.0f/mBlobCost)*initialReclaim; 
						this.set_bool( "reclaimPropertyWarn", true );
					}
					
					if ( blockType != Block::STATION && island.isStation && mBlob.getTeamNum() != this.getTeamNum() )
					{
						deconstructAmount = (1.0f/mBlobCost)*initialReclaim; 
						this.set_bool( "reclaimPropertyWarn", true );					
					}
					
					if ( (currentReclaim - deconstructAmount) <=0 )
					{		
						if ( blockType == Block::STATION )
						{
							if ( mBlob.getTeamNum() != this.getTeamNum() && mBlob.getTeamNum() != 255 )
							{
								mBlob.server_setTeamNum( 255 );
								mBlob.getSprite().SetFrame( Block::STATION );
							}
						}
						else
						{
							string cName = thisPlayer.getUsername();
							u16 cBooty = server_getPlayerBooty( cName );

							server_setPlayerBooty( cName, cBooty + mBlobCost*(mBlobHealth/mBlobInitHealth) );
							directionalSoundPlay( "/ChaChing.ogg", pos );
							mBlob.Tag( "disabled" );
							mBlob.server_Die();
						}
					}
					else
						mBlob.set_f32("current reclaim", currentReclaim - deconstructAmount);
				}
				else if ( currentTool == "reconstructor" )
				{			
					f32 reconstructAmount = 0;
					u16 reconstructCost = 0;
					string cName = thisPlayer.getUsername();
					u16 cBooty = server_getPlayerBooty( cName );
					
					if ( blockType == Block::MOTHERSHIP5 )
					{
						const f32 motherInitHealth = 8.0f;
						if ( (mBlobHealth + reconstructAmount) <= motherInitHealth  )
						{
							reconstructAmount = fullConstructAmount;
							reconstructCost = CONSTRUCT_VALUE;
						}
						else if ( (mBlobHealth + reconstructAmount) > motherInitHealth  )
						{
							reconstructAmount = motherInitHealth - mBlobHealth;
							reconstructCost = (CONSTRUCT_VALUE - CONSTRUCT_VALUE*(reconstructAmount/fullConstructAmount));
						}
						
						if ( cBooty >= reconstructCost && mBlobHealth < motherInitHealth )
						{
							mBlob.server_SetHealth( mBlobHealth + reconstructAmount );
							server_setPlayerBooty( cName, cBooty - reconstructCost );
						}
					}
					else if ( blockType == Block::STATION )
					{							
						if ( (currentReclaim + reconstructAmount) <= initialReclaim )
						{
							reconstructAmount = fullConstructAmount;
							reconstructCost = CONSTRUCT_VALUE;
						}
						else if ( (currentReclaim + reconstructAmount) > initialReclaim  )
						{
							reconstructAmount = initialReclaim - currentReclaim;
							reconstructCost = CONSTRUCT_VALUE - CONSTRUCT_VALUE*(reconstructAmount/fullConstructAmount);
							
							if ( mBlob.getTeamNum() == 255 ) //neutral
							{
								mBlob.server_setTeamNum( this.getTeamNum() );
								mBlob.getSprite().SetFrame( Block::STATION );
							}
						}
						
						mBlob.set_f32("current reclaim", currentReclaim + reconstructAmount);
					}
					else if ( currentReclaim < initialReclaim )
					{					
						if ( (currentReclaim + reconstructAmount) <= initialReclaim )
						{
							reconstructAmount = fullConstructAmount;
							reconstructCost = CONSTRUCT_VALUE;
						}
						else if ( (currentReclaim + reconstructAmount) > initialReclaim  )
						{
							reconstructAmount = initialReclaim - currentReclaim;
							reconstructCost = CONSTRUCT_VALUE - CONSTRUCT_VALUE*(reconstructAmount/fullConstructAmount);
						}
						
						if ( (currentReclaim + reconstructAmount > mBlobHealth) && cBooty >= reconstructCost)
						{
							mBlob.server_SetHealth( mBlobHealth + reconstructAmount );
							mBlob.set_f32("current reclaim", currentReclaim + reconstructAmount);
							server_setPlayerBooty( cName, cBooty - reconstructCost );
						}
						else if ( (currentReclaim + reconstructAmount) < mBlobHealth )
							mBlob.set_f32("current reclaim", currentReclaim + reconstructAmount);
					}
					
					if ( currentReclaim >= initialReclaim*0.75f )	//visually repair block
					{
						CSprite@ mBlobSprite = mBlob.getSprite();
						for (uint frame = 0; frame < 11; ++frame)
						{
							mBlobSprite.RemoveSpriteLayer("dmg"+frame);
						}
					}
				}
			}
			
			//laser creation
			if ( getNet().isClient() )//effects
			{
				Vec2f barrelPos = pos + Vec2f(0.0f, 0.0f).RotateBy(aimVector.Angle());
				f32 offsetAngle = aimVector.Angle() - (mBlob.getPosition() - pos).Angle(); 
				
				this.getSprite().RemoveSpriteLayer("laser");
				
				string beamSpriteFilename;
				if ( currentTool == "deconstructor" )
					beamSpriteFilename = "ReclaimBeam";
				else if ( currentTool == "reconstructor" )
					beamSpriteFilename = "RepairBeam";
					
				CSpriteLayer@ laser = this.getSprite().addSpriteLayer("laser", beamSpriteFilename + ".png", 32, 16);

				if (laser !is null)//partial length laser
				{
					Animation@ reclaimingAnim = laser.addAnimation( "constructing", 1, true );
					int[] reclaimingAnimFrames = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
					reclaimingAnim.AddFrames(reclaimingAnimFrames);
					laser.SetAnimation("constructing");
					laser.SetVisible(true);
					f32 laserLength = Maths::Max(0.1f, (aimPos - barrelPos).getLength() / 32.0f);						
					laser.ResetTransform();						
					laser.ScaleBy( Vec2f(laserLength, 1.0f) );							
					laser.TranslateBy( Vec2f(laserLength*16.0f, + 0.5f) );
					laser.RotateBy( offsetAngle, Vec2f());
					laser.setRenderStyle(RenderStyle::light);
					laser.SetRelativeZ(-1);
				}
			}
		}
		
		this.set_u32("fire time", getGameTime());
	}
	else if ( getNet().isServer() && this.getCommandID( "releaseOwnership" ) == cmd )
	{
		CPlayer@ player = this.getPlayer();
		CBlob@ seat = getBlobByNetworkID( params.read_u16() );
		
		if ( player is null || seat is null ) return;
	
		string owner;
		seat.get( "playerOwner", owner );
		if ( owner == player.getUsername() )
		{
			print( "$ " + owner + " released seat" );
			owner = "";
			seat.set( "playerOwner", owner );
			seat.set_string( "playerOwner", "" );
			seat.Sync( "playerOwner", true );
		}
	}
	else if ( getNet().isServer() && this.getCommandID( "giveBooty" ) == cmd )//transfer booty
	{
		CRules@ rules = getRules();
		if ( getGameTime() < rules.get_u16( "warmup_time" ) )	return;
			
		u8 teamNum = this.getTeamNum();
		CPlayer@ player = this.getPlayer();
		string cName = getCaptainName( teamNum );		
		CPlayer@ captain = getPlayerByUsername( cName );
		
		if ( captain is null || player is null ) return;
		
		u16 transfer = rules.get_u16( "booty_transfer" );
		u16 fee = Maths::Round( transfer * rules.get_f32( "booty_transfer_fee" ) );		
		string pName = player.getUsername();
		u16 playerBooty = server_getPlayerBooty( pName );
		if ( playerBooty < transfer + fee )	return;
			
		if ( player !is captain )
		{
			print( "$ " + pName + " transfers Booty to captain " + cName );
			u16 captainBooty = server_getPlayerBooty( cName );
			server_setPlayerBooty( pName, playerBooty - transfer - fee );
			server_setPlayerBooty( cName, captainBooty + transfer );
		} else
		{
			CBlob@ core = getMothership( teamNum );
			if ( core !is null )
			{
				int coreColor = core.getShape().getVars().customData;
				CBlob@[] crew;
				CBlob@[] humans;
				getBlobsByName( "human", @humans );
				for ( u8 i = 0; i < humans.length; i++ )
					if ( humans[i].getTeamNum() == teamNum && humans[i] !is this )
					{
						CBlob@ islandBlob = getIslandBlob( humans[i] );
						if ( islandBlob !is null && islandBlob.getShape().getVars().customData == coreColor )
							crew.push_back( humans[i] );
					}
				
				if ( crew.length > 0 )
				{
					print( "$ " + pName + " transfers Booty to crew" );
					server_setPlayerBooty( pName, playerBooty - transfer - fee );
					u16 shareBooty = Maths::Floor( transfer/crew.length );
					for ( u8 i = 0; i < crew.length; i++ )
					{
						CPlayer@ crewPlayer = crew[i].getPlayer();						
						if ( player is null ) continue;
						
						string cName = crewPlayer.getUsername();
						u16 cBooty = server_getPlayerBooty( cName );

						server_setPlayerBooty( cName, cBooty + shareBooty );
					}
				}
			}
		}
	}
	else if ( this.getCommandID( "swap tool" ) == cmd )
	{
		u16 netID = params.read_u16();
		string tool = params.read_string();
		CPlayer@ player = this.getPlayer();
		
		if ( player is null ) return;
		
		if (tool == "deconstructor")
		{
			this.getSprite().SetEmitSound("/ReclaimSound.ogg");
			this.getSprite().SetEmitSoundVolume(0.5f);
			this.getSprite().SetEmitSoundPaused(true);
		}
		if (tool == "reconstructor")
		{
			this.getSprite().SetEmitSound("/ReclaimSound.ogg");
			this.getSprite().SetEmitSoundVolume(0.5f);
			this.getSprite().SetEmitSoundPaused(true);
		}
		
		this.set_string("current tool", tool);
	}
}

void onAttached( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.ClearMenus();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint )
{
	this.set_u16( "shipID", detached.getNetworkID() );
	this.set_s8( "stay count", 3 );
}

void onDie( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();
	
	ParticleBloodSplat( pos, true );
	directionalSoundPlay( "BodyGibFall", pos );
	
	if (!sprite.getVars().gibbed) 
	{
		directionalSoundPlay( "SR_ManDeath" + ( XORRandom(4) + 1 ), pos, 0.75f );
		sprite.Gib();
	}
	
	//return held blocks
	CRules@ rules = getRules();
	CBlob@[]@ blocks;
	if (this.get( "blocks", @blocks ) && blocks.size() > 0)                 
	{
		if ( getNet().isServer() )
		{
			CPlayer@ player = this.getPlayer();
			if ( player !is null )
			{
				string pName = player.getUsername();
				u16 pBooty = server_getPlayerBooty( pName );
				u16 returnBooty = 0;
				for (uint i = 0; i < blocks.length; ++i)
				{
					int type = Block::getType( blocks[i] );
					if ( type != Block::COUPLING && blocks[i].getShape().getVars().customData == -1 )
						returnBooty += Block::getCost( type );
				}
				
				if ( returnBooty > 0 && !(getPlayersCount() == 1 || rules.get_bool("freebuild")))
					server_setPlayerBooty( pName, pBooty + returnBooty );
			}
		}
		Human::clearHeldBlocks( this );
		this.set_bool( "blockPlacementWarn", false );
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//when killed: reward hitterBlob if this was boarding his mothership
	if ( hitterBlob.getName() == "human" && hitterBlob !is this && this.getHealth() - damage <= 0 )
	{
		Island@ pIsle = getIsland( this );
		CPlayer@ hitterPlayer = hitterBlob.getPlayer();
		u8 teamNum = hitterBlob.getTeamNum();
		if ( hitterPlayer !is null && pIsle !is null && pIsle.isMothership && pIsle.centerBlock !is null && pIsle.centerBlock.getTeamNum() == teamNum )
		{
			if ( hitterPlayer.isMyPlayer() )
				Sound::Play( "snes_coin.ogg" );

			if ( getNet().isServer() )
			{
				string attackerName = hitterPlayer.getUsername();
				u16 reward = 50;
				if ( getRules().get_bool( "whirlpool" ) ) reward *= 3;
				
				server_setPlayerBooty( attackerName, server_getPlayerBooty( attackerName ) + reward );
				server_updateTotalBooty( teamNum, reward );
			}
		}
	}
	
	if ( this.getTickSinceCreated() > 60 )
		return damage;
	else
		return 0.0f;
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	if ( this.getHealth() > oldHealth )
		directionalSoundPlay( "Heal.ogg", this.getPosition(), 2.0f );
}

Random _shotrandom(0x15125); //clientside
void shotParticles(Vec2f pos, float angle)
{
	//muzzle flash
	{
		CParticle@ p = ParticleAnimated( "Entities/Block/turret_muzzle_flash.png",
												  pos, Vec2f(),
												  -angle, //angle
												  1.0f, //scale
												  3, //animtime
												  0.0f, //gravity
												  true ); //selflit
		if(p !is null)
			p.Z = 540.0f;
	}

	Vec2f shot_vel = Vec2f(0.5f,0);
	shot_vel.RotateBy(-angle);

	//smoke
	for(int i = 0; i < 5; i++)
	{
		//random velocity direction
		Vec2f vel(0.03f + _shotrandom.NextFloat()*0.03f, 0);
		vel.RotateBy(_shotrandom.NextFloat() * 360.0f);
		vel += shot_vel * i;

		CParticle@ p = ParticleAnimated( "Entities/Block/turret_smoke.png",
												  pos, vel,
												  _shotrandom.NextFloat() * 360.0f, //angle
												  0.6f, //scale
												  3+_shotrandom.NextRanged(4), //animtime
												  0.0f, //gravity
												  true ); //selflit
		if(p !is null)
			p.Z = 550.0f;
	}
}

