#include "WaterEffects.as"
#include "BlockCommon.as"
#include "IslandsCommon.as"
#include "Booty.as"
#include "AccurateSoundPlay.as"
#include "CustomMap.as";
 
const f32 BULLET_SPREAD = 2.5f;
const f32 BULLET_RANGE = 250.0f;

const int MIN_TICKS_PER_SHOT = 3;
const int SHOT_VARIATION = 4;
const int RELOAD_TICKS = 200;
const u8 MAX_AMMO = 30; //maximum carryable ammunition

const f32 MIN_FIRE_PAUSE = 2.75f; //only used for animations

Random _shotspreadrandom(0x11598); //clientside

void onInit( CBlob@ this )
{
	//this.getCurrentScript().tickFrequency = 2;

	this.Tag("weapon");
	this.Tag("usesAmmo");
	this.Tag("machinegun");
	this.Tag("fixed_gun");
	
	this.addCommandID("fire");
	this.addCommandID("disable");
	
	this.set_string("barrel", "left");

	if ( getNet().isServer() )
	{	
		this.set_u16( "ammo", MAX_AMMO );
		this.set_u16( "maxAmmo", MAX_AMMO );
		this.set_bool( "mShipDocked", false );
		this.set_u32("fire time", 0);
		this.set_u32("reload time", 0);
		this.set_bool( "reloading", false );
		
		this.Sync("ammo", true );
		this.Sync("maxAmmo", true );
		this.Sync("fire time", true );
		this.Sync("reload time", true );
		this.Sync( "reloading", true );
	}
   
	CSprite@ sprite = this.getSprite();
    CSpriteLayer@ layer = sprite.addSpriteLayer( "weapon", 16, 16 );
    if (layer !is null)
    {
        layer.SetRelativeZ(2);
        layer.SetLighting( false );
        Animation@ anim = layer.addAnimation( "fire left", Maths::Round( MIN_FIRE_PAUSE ), false );
        anim.AddFrame(Block::MACHINEGUN_A2);
        anim.AddFrame(Block::MACHINEGUN_A1);
               
		Animation@ anim2 = layer.addAnimation( "fire right", Maths::Round( MIN_FIRE_PAUSE ), false );
        anim2.AddFrame(Block::MACHINEGUN_A3);
        anim2.AddFrame(Block::MACHINEGUN_A1);
               
		Animation@ anim3 = layer.addAnimation( "default", 1, false );
		anim3.AddFrame(Block::MACHINEGUN_A1);
        layer.SetAnimation("default");  
    }
	
	_shotspreadrandom.Reset( getGameTime() );
}
 
void onTick( CBlob@ this )
{
	if ( this.getShape().getVars().customData <= 0 )//not placed yet
		return;
		
	u32 gameTime = getGameTime();
	Vec2f pos = this.getPosition();
	
	CSprite@ sprite = this.getSprite();
    CSpriteLayer@ laser = sprite.getSpriteLayer( "laser" );
	
	u32 fireTime = this.get_u32("fire time");
	this.set_bool( "fire ready", canShoot(this) );
	
	//kill laser after a certain time
	if ( laser !is null && this.get_u32("fire time") + 4 < gameTime )
		sprite.RemoveSpriteLayer("laser");
	
	bool isReloading = this.get_bool( "reloading" );
	u32 reloadTime = this.get_u32( "reload time" );
	if ( isReloading )
	{
		//update reloading progress
		CSpriteLayer@ progressBar = sprite.getSpriteLayer( "progress bar" );
		if (progressBar !is null)
		{				
			f32 barScale = (1.0f-(1.0f*(gameTime-reloadTime)/(1.0f*RELOAD_TICKS)));						
			progressBar.ResetTransform();						
			progressBar.ScaleBy( Vec2f(barScale, 1.0f) );				
			progressBar.TranslateBy( Vec2f(-4.0f*(1.0f-barScale), 4.0f) );
		}
		
		if ( (reloadTime + RELOAD_TICKS) < gameTime )
		{
			//reload ammo
			this.set_u16( "ammo", MAX_AMMO );
			this.Sync( "ammo", true );

			this.set_bool( "reloading", false );
			this.Sync( "reloading", true );
			
			directionalSoundPlay( "ReloadEnd", pos, 2.0f );
			
			sprite.RemoveSpriteLayer("black bar");
			sprite.RemoveSpriteLayer("progress bar");
		}
	}
	
	//reload if out of ammo
	if ( !isReloading && this.get_u16( "ammo" ) <= 0  )
	{		
		this.set_bool( "reloading", true );
		this.set_u32("reload time", getGameTime());
		
		directionalSoundPlay( "ReloadStart", pos, 2.0f );
		
		if ( getNet().isClient() ) //reload bar
		{
			sprite.RemoveSpriteLayer("black bar");
			CSpriteLayer@ blackBar = sprite.addSpriteLayer("black bar", "reload_bar.png", 8, 2);
			if (blackBar !is null)
			{
				blackBar.SetRelativeZ(4);
				blackBar.SetFrame(0);
				blackBar.SetVisible(true);						
				blackBar.ResetTransform();												
				blackBar.TranslateBy( Vec2f(0.0f, 4.0f) );	
			}
			sprite.RemoveSpriteLayer("progress bar");
			CSpriteLayer@ progressBar = sprite.addSpriteLayer("progress bar", "reload_bar.png", 8, 2);
			if (progressBar !is null)
			{
				progressBar.SetRelativeZ(5);
				progressBar.SetFrame(1);
				progressBar.SetVisible(true);					
				progressBar.ResetTransform();										
				progressBar.TranslateBy( Vec2f(0.0f, 4.0f) );
			}
		}
	}
	
	//reset the random seed periodically so joining clients see the same bullet paths
	if ( gameTime % 450 == 0 )
		_shotspreadrandom.Reset( gameTime );
}
 
bool canShoot( CBlob@ this )
{
	return ( (this.get_u32("fire time") + MIN_TICKS_PER_SHOT) < getGameTime() );
}
 
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("fire"))
    {	
		if ( !canShoot(this) )
			return;
	
		u16 shooterID;
		if ( !params.saferead_u16(shooterID) )
			return;
		
		CBlob@ shooter = getBlobByNetworkID( shooterID );
		if (shooter is null)
			return;
		
		Island@ island = getIsland( this.getShape().getVars().customData );
		if ( island is null )
			return;
			
		bool isServer = getNet().isServer();
		Vec2f pos = this.getPosition();
		
		//ammo
		u16 ammo = this.get_u16( "ammo" );
		
		if ( ammo <= 0 )
		{
			directionalSoundPlay( "LoadingTick1", pos, 0.5f );
			
			return;
		}
		
		ammo--;
		this.set_u16( "ammo", ammo );
			
		//effects
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ layer = sprite.getSpriteLayer( "weapon" );
		layer.SetAnimation( "default" );
	   
		Vec2f aimVector = Vec2f(1, 0).RotateBy(this.getAngleDegrees());
		   
		Vec2f barrelOffset;
		Vec2f barrelOffsetRelative;
		if (this.get_string("barrel") == "left")
		{
			barrelOffsetRelative = Vec2f(0, -2.0);
			barrelOffset = Vec2f(0, -2.0).RotateBy(-aimVector.Angle());
			this.set_string("barrel", "right");
		}
		else
		{
			barrelOffsetRelative = Vec2f(0, 2.0);
			barrelOffset = Vec2f(0, 2.0).RotateBy(-aimVector.Angle());
			this.set_string("barrel", "left");
		}
			
		Vec2f barrelPos = this.getPosition() + aimVector*9 + barrelOffset;

		//hit stuff
		u8 teamNum = shooter.getTeamNum();//teamNum of the player firing
		HitInfo@[] hitInfos;
		CMap@ map = this.getMap();
		bool killed = false;
		bool blocked = false;
		
		f32 offsetAngle = ( _shotspreadrandom.NextFloat() - 0.5f ) * BULLET_SPREAD * 2.0f;
		aimVector.RotateBy(offsetAngle);
		
		f32 rangeOffset = ( _shotspreadrandom.NextFloat() - 0.5f ) * BULLET_SPREAD * 64.0f;
			
		if( map.getHitInfosFromRay( barrelPos, -aimVector.Angle(), BULLET_RANGE + rangeOffset, this, @hitInfos ) )
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;	  
				u16 tileType = hi.tile;
				
				if( b is null || b is this ) continue;

				const int thisColor = this.getShape().getVars().customData;
				int bColor = b.getShape().getVars().customData;
				bool sameIsland = bColor != 0 && thisColor == bColor;
				
				const int blockType = b.getSprite().getFrame();
				const bool isBlock = b.getName() == "block";

				if ( !b.hasTag( "booty" ) && (bColor > 0 || !isBlock) )
				{
					if ( isBlock || b.hasTag("rocket") )
					{
						if ( Block::isSolid(blockType) || ( b.getTeamNum() != teamNum && ( blockType == Block::MOTHERSHIP5 || b.hasTag("weapon") || b.hasTag("rocket") || blockType == Block::BOMB ) ) )//hit these and die
							killed = true;
						else if ( sameIsland && b.hasTag("weapon") && (b.getTeamNum() == teamNum) ) //team weaps
						{
							killed = true;
							blocked = true;
							directionalSoundPlay( "lightup", barrelPos );
							break;
						}
						else if ( blockType == Block::SEAT || blockType == Block::RAMCHAIR )
						{
							AttachmentPoint@ seat = b.getAttachmentPoint(0);
							if (seat !is null)
							{
								CBlob@ occupier = seat.getOccupied();
								if ( occupier !is null && occupier.getName() == "human" && occupier.getTeamNum() != this.getTeamNum() )
									killed = true;
								else
									continue;
							}
						}
						else
							continue;
					}
					else
					{
						if ( b.getTeamNum() == teamNum || ( b.hasTag("player") && b.isAttached() ) )
							continue;
					}
					
					if ( getNet().isClient() )//effects
					{
						sprite.RemoveSpriteLayer("laser");
						CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Beam1.png", 16, 16);
						if (laser !is null)//partial length laser
						{
							laser.SetRelativeZ(3);
							//laser.setRenderStyle(RenderStyle::light);
							Animation@ anim = laser.addAnimation( "default", 2, false );
							int[] frames = { 0, 1, 2, 3, 4, 5 };
							anim.AddFrames(frames);
							laser.SetVisible(true);
							f32 laserLength = Maths::Max(0.1f, (hi.hitpos - barrelPos).getLength() / 16.0f);						
							laser.ResetTransform();						
							laser.ScaleBy( Vec2f(laserLength, 0.5f) );							
							laser.TranslateBy( Vec2f(laserLength*8.0f + 8.0f, barrelOffsetRelative.y) );							
							laser.RotateBy( offsetAngle, Vec2f());
						}

						hitEffects(b, hi.hitpos);
					}				
					
					f32 damage = getDamage( b, blockType );
					
					if ( isServer )
					{
						if ( b.hasTag( "propeller" ) && b.getTeamNum() != teamNum && XORRandom(3) == 0 )
							b.SendCommand(b.getCommandID("off"));
						this.server_Hit( b, hi.hitpos, Vec2f_zero, damage, 0, true );
					}
					
					CPlayer@ attacker = shooter.getPlayer();
					if ( attacker !is null )
						damageBooty( attacker, shooter, b, damage );	
					
					if ( killed ) break;
				}
			}
		
		if ( !blocked )
		{
			shotParticles( barrelPos, aimVector.Angle() );
			directionalSoundPlay( "M60Fire" + ( XORRandom(6) ) + ".ogg", barrelPos );
			if (this.get_string("barrel") == "left")
				layer.SetAnimation( "fire left" );
			if (this.get_string("barrel") == "right")
				layer.SetAnimation( "fire right" );
		}
		
		Vec2f solidPos;
		if ( !killed && map.rayCastSolid(pos, pos + aimVector * (BULLET_RANGE + rangeOffset), solidPos) )
		{
			//print( "hit a rock" );
			if ( getNet().isClient() )//effects
			{
				sprite.RemoveSpriteLayer("laser");
				CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Beam1.png", 16, 16);
				if (laser !is null)//partial length laser
				{
					laser.SetRelativeZ(3);
					//laser.setRenderStyle(RenderStyle::light);
					Animation@ anim = laser.addAnimation( "default", 2, false );
					int[] frames = { 0, 1, 2, 3, 4, 5 };
					anim.AddFrames(frames);
					laser.SetVisible(true);
					f32 laserLength = Maths::Max(0.1f, (solidPos - barrelPos).getLength() / 16.0f);						
					laser.ResetTransform();						
					laser.ScaleBy( Vec2f(laserLength, 0.5f) );							
					laser.TranslateBy( Vec2f(laserLength*8.0f + 8.0f, barrelOffsetRelative.y) );							
					laser.RotateBy( offsetAngle, Vec2f());
				}

				hitEffects(this, solidPos);
			}
		}
	
		else if ( !killed && getNet().isClient() )//full length 'laser'
		{
			sprite.RemoveSpriteLayer("laser");
			CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Beam1.png", 16, 16);
			if (laser !is null)
			{
				laser.SetRelativeZ(3);
				//laser.setRenderStyle(RenderStyle::light);
				Animation@ anim = laser.addAnimation( "default", 2, false );
				int[] frames = { 0, 1, 2, 3, 4, 5 };
				anim.AddFrames(frames);
				laser.SetVisible(true);
				f32 laserLength = Maths::Max(0.1f, (aimVector * (BULLET_RANGE + rangeOffset)).getLength() / 16.0f);						
				laser.ResetTransform();						
				laser.ScaleBy( Vec2f(laserLength, 0.5f) );							
				laser.TranslateBy( Vec2f(laserLength*8.0f + 8.0f, barrelOffsetRelative.y) );								
				laser.RotateBy( offsetAngle, Vec2f());
			}
			
			MakeWaterParticle( barrelPos + aimVector * (BULLET_RANGE + rangeOffset), Vec2f_zero );
		}
		
		this.set_u32( "fire time", getGameTime() ); // +_shotspreadrandom.NextRanged(SHOT_VARIATION)
    }
}
 
f32 getDamage( CBlob@ hitBlob, int blockType )
{	
	if ( hitBlob.hasTag( "rocket" ) )
		return 0.4f;

	if ( blockType == Block::PROPELLER )
		return 0.15f;
		
	if ( blockType == Block::RAMENGINE )
		return 0.30f;
	
	if ( hitBlob.hasTag( "weapon" ) )
		return 0.075f;
		
	if ( hitBlob.getName() == "shark" || hitBlob.getName() == "human" )
		return 0.5f;
			
	if ( blockType == Block::SEAT )
		return 0.05f;
		
	if ( blockType == Block::RAMCHAIR )
		return 0.10f;
		
	if ( Block::isBomb( blockType ) )
		return 1.0f;
	
	if ( blockType == Block::MOTHERSHIP5 )
		return 0.1f;
	
	return 0.14f;	//solids
}

void hitEffects( CBlob@ hitBlob, Vec2f worldPoint )
{
	CSprite@ sprite = hitBlob.getSprite();
	const int blockType = sprite.getFrame();
	
	if (hitBlob.getName() == "shark"){
		ParticleBloodSplat( worldPoint, true );
		directionalSoundPlay( "BodyGibFall", worldPoint );
	}
	else	if (hitBlob.hasTag("player") )
	{
		directionalSoundPlay( "ImpactFlesh", worldPoint );
		ParticleBloodSplat( worldPoint, true );
	}
	else	if (Block::isSolid(blockType) || blockType == Block::MOTHERSHIP5 || hitBlob.hasTag("weapon") 
					|| blockType == Block::PLATFORM || blockType == Block::SEAT || blockType == Block::RAMCHAIR || blockType == Block::BOMB)
	{
		sparks(worldPoint, 4);
		directionalSoundPlay( "Ricochet" +  ( XORRandom(3) + 1 ) + ".ogg", worldPoint, 0.50f );
	}
}
 
void shotParticles(Vec2f pos, float angle )
{
	//muzzle flash
	CParticle@ p = ParticleAnimated( "Entities/Block/turret_muzzle_flash.png",
																					  pos, Vec2f(),
																					  -angle, //angle
																					  1.0f, //scale
																					  3, //animtime
																					  0.0f, //gravity
																					  true ); //selflit
	if(p !is null)
	{
		p.Z = 10.0f;
	}
}

Random _sprk_r;
void sparks(Vec2f pos, int amount)
{
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 1.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 255, 255, 128+_sprk_r.NextRanged(128), _sprk_r.NextRanged(128)), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 10 + _sprk_r.NextRanged(20);
        p.scale = 0.5f + _sprk_r.NextFloat();
        p.damping = 0.95f;
    }
}

void damageBooty( CPlayer@ attacker, CBlob@ attackerBlob, CBlob@ victim, f32 damage )
{
	if ( victim.getName() == "block" )
	{
		const int blockType = victim.getSprite().getFrame();
		u8 teamNum = attacker.getTeamNum();
		u8 victimTeamNum = victim.getTeamNum();
		string attackerName = attacker.getUsername();
		Island@ victimIsle = getIsland( victim.getShape().getVars().customData );
		
		if ( victimIsle !is null
			&& ( victimIsle.owner != "" || victimIsle.isMothership )
			&& victimTeamNum != teamNum
			)
		{
			if ( attacker.isMyPlayer() )
			{
				u8 n = XORRandom(4);
				if ( n == 3 )
					Sound::Play( "Pinball_" + XORRandom(4), attackerBlob.getPosition(), 0.5f );
				else
					Sound::Play( "Pinball_" + n, attackerBlob.getPosition(), 0.5f );					
			}

			if ( getNet().isServer() )
			{
				CRules@ rules = getRules();
				
				//u16 reward = 3;//propellers, seat
				//if ( victim.hasTag( "weapon" ) || Block::isBomb( blockType ) )
				//	reward += 2;
				
				f32 reward = (damage/4.0f)*Block::getCost( blockType );
				if ( blockType == Block::MOTHERSHIP5 )
					reward = damage*200.0f;
								
				f32 bFactor = ( rules.get_bool( "whirlpool" ) ? 3.0f : 1.0f ) * Maths::Min( 2.5f, Maths::Max( 0.15f,
				( 2.0f * rules.get_u16( "bootyTeam_total" + victimTeamNum ) - rules.get_u16( "bootyTeam_total" + teamNum ) + 1000 )/( rules.get_u32( "bootyTeam_median" ) + 1000 ) ) );
				
				reward = Maths::Round( reward * bFactor );
				
				server_setPlayerBooty( attackerName, server_getPlayerBooty( attackerName ) + reward );
				server_updateTotalBooty( teamNum, reward );
			}
		}
	}
}