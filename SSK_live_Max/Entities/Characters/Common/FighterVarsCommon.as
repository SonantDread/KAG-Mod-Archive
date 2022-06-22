#include "SSKExplosion.as"
#include "FighterMovesetCommon.as"
#include "TeamColour.as"

// Status Common

const f32 MAX_DAMAGE = 1000.0f;
const f32 MAX_KNOCKBACK_SPEED = 25.0f;

const int MIN_GRABTIME = 60;

const f32 MAX_SHIELD_HEALTH = 50.0f;
const f32 SHIELD_REGENERATION = 0.08f;
const f32 SHIELD_DEPLETION = 0.15f;

shared class SSKFighterVars
{
	u8 fighterClass;

	f32 damageStatus;  // accumulated damage

	u8 hitstunTime;
	Vec2f oldVel;	// velocity before hitstun came into effect
	bool applyOldVel;

	u16 grabTime;

	u16 dazeTime;

	bool disableItemActions;

	Vec2f knockbackForce;

	u16 tumbleTime;
	Vec2f tumbleVec;
	bool startTumble;

	bool gravityEnabled;

	bool fallSpecial;

	bool fastFalling;

	bool inMoveAnimation;
	MoveAnimation currMoveAnimation;
	u16 currMoveFrameIndex;
	s16 currMoveFrameTimer;
	bool hasAttackedOnCurrFrame;
	bool isAttackingLeft;

	bool inMiscAttack;

	bool isShielding;
	f32 shieldHealth;

	AutoTickFunc[] autoTickFuncs;

	void runAutoTickFunc(string effectName, FIGHTER_CALLBACK @whileActive = null, FIGHTER_CALLBACK @onDeactivate = null, bool disableOnHit = false, bool activeDuringHitstun = false, u16 ticksActive = 1)
	{
		AutoTickFunc@ effect = getAutoTickFunc(effectName);
		if (effect !is null)
		{
			effect.ticksActive = Maths::Max(ticksActive, effect.ticksActive);
		}
		else
		{
			autoTickFuncs.push_back(AutoTickFunc(effectName, whileActive, onDeactivate, disableOnHit, activeDuringHitstun, ticksActive));
		}
	}

	AutoTickFunc@ getAutoTickFunc(string effectName)
	{
		for(int i = 0; i < autoTickFuncs.length(); i++)
		{
			if (effectName == autoTickFuncs[i].name)
			{
				return @autoTickFuncs[i];
			}
		}
		return null;
	}
};

shared class FighterHitData
{
	u8 minHitstunTime;
	f32 minKnockback;
	f32 scalingKnockback;
	u16 dazeTime;

	string soundEffect;

	FighterHitData(u8 _minHitstunTime = 0, f32 _minKnockback = 0.0f, f32 _scalingKnockback = 0.0f, u16 _dazeTime = 0)
	{
		minHitstunTime = _minHitstunTime;
		minKnockback = _minKnockback;
		scalingKnockback = _scalingKnockback;
		dazeTime = _dazeTime;

		soundEffect = "";
	}
};

void server_fighterHit(CBlob@ hitterBlob, CBlob@ victimBlob, Vec2f hitPos, Vec2f velocity, f32 damage, u8 customData, bool teamKill, FighterHitData@ fighterHitData)
{
	// This damage function works on all blobs (not just fighters)

	if (victimBlob.hasTag("invincible")) // pass through if invincible
	{
		return;
	}

	SSKFighterVars@ victimFighterVars;
	if (victimBlob.get("fighterVars", @victimFighterVars))
	{
		SSKFighterVars@ hitterFighterVars;
		hitterBlob.get("fighterVars", @hitterFighterVars);

		f32 victimDamageStatus = victimFighterVars.damageStatus;

		f32 knockbackSpeed = fighterHitData.scalingKnockback*victimDamageStatus;
		if (hitterFighterVars !is null)
		{
			knockbackSpeed += hitterFighterVars.damageStatus*0.04f;	// add more knockback if attacker is damaged
		}
		knockbackSpeed = Maths::Min(knockbackSpeed + fighterHitData.minKnockback, MAX_KNOCKBACK_SPEED);
		u16 tumbleTime = knockbackSpeed*5.0f;
		u16 finalHitstunTime = Maths::Max(fighterHitData.minHitstunTime, knockbackSpeed*1.25f);

		// shield bubble hit
		if (victimFighterVars.isShielding && victimFighterVars.shieldHealth > 0)
		{
			victimFighterVars.shieldHealth -= Maths::Min(damage, victimFighterVars.shieldHealth);
			victimFighterVars.hitstunTime = finalHitstunTime;

			if (getNet().isServer())
			{
				SyncShieldHit(victimBlob, hitPos);
				SyncHitstun(victimBlob);
			}

			// apply a longer hitstun to attacker if they hit shield
			SSKFighterVars@ hitterFighterVars;
			if (hitterBlob.get("fighterVars", @hitterFighterVars))
			{
				hitterFighterVars.hitstunTime = finalHitstunTime + 4; // give slight frame advantage to shielder
				if (getNet().isServer())
				{
					SyncHitstun(hitterBlob);				
				}
			}

			return;
		}

		// add to player damage status
		bool attackBlocked = victimBlob.hasTag("shielded") && canBlockThisType(customData) && blockAttack(victimBlob, velocity, 0.0f);
		if ( !attackBlocked )
		{
			if (getNet().isServer())
			{
				victimFighterVars.damageStatus += damage;
				SyncDamageStatus(victimBlob);
			}

			// play hit sound
			if (fighterHitData.soundEffect != "")
			{
				victimBlob.getSprite().PlaySound(fighterHitData.soundEffect, 1.0f);
			}
		}

		f32 x_side = 0.0f;
		f32 y_side = 0.0f;
		//if (hitterBlob !is null)
		{
			//Vec2f dif = hitterBlob.getPosition() - victimBlob.getPosition();
			if (velocity.x > 0.7)
			{
				x_side = 1.0f;
			}
			else if (velocity.x < -0.7)
			{
				x_side = -1.0f;
			}

			if (velocity.y > 0.5)
			{
				y_side = 1.0f;
			}
			else
			{
				y_side = -1.0f;
			}
		}

		bool force = victimBlob.hasTag("force_knock");
		if (force)
		{
			victimBlob.Untag("force_knock");
		}

		if (damage == 0 || force)
		{
			//get sponge
			CBlob@ sponge = null;
			//find the sponge with lowest absorbed
			CInventory@ inv = victimBlob.getInventory();
			if (inv !is null) 
			{
				u8 lowest_absorbed = 100;
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ invitem = inv.getItem(i);
					if(invitem.getName() == "sponge")
					{
						if(invitem.get_u8("absorbed") < lowest_absorbed)
						{
							lowest_absorbed = invitem.get_u8("absorbed");
							@sponge = invitem;
						}
					}
				}
			}
		}

		if (fighterHitData.dazeTime > 0)
		{
			u16 currDazeTime = victimFighterVars.dazeTime;
			victimFighterVars.dazeTime = Maths::Max(fighterHitData.dazeTime, currDazeTime);

			if (getNet().isServer())
			{
				SyncDazeTime(victimBlob);
			}
		}

		Vec2f velNorm = velocity;
		velNorm.Normalize();
		//Vec2f knockbackVec(x_side, y_side);

		victimFighterVars.hitstunTime = finalHitstunTime;
		if (getNet().isServer())
		{
			u16 currTumbleTime = victimFighterVars.tumbleTime;

			CBitStream params;
			params.write_u8( finalHitstunTime );
			params.write_u16( Maths::Max(tumbleTime, currTumbleTime) );	
			params.write_Vec2f( velNorm*knockbackSpeed );	// was using knockbackVec
			victimBlob.SendCommand(victimBlob.getCommandID("sync knockback"), params);		
		}

		// kill player if damage exceeds the max
		if (victimFighterVars.damageStatus >= MAX_DAMAGE)
		{
			victimBlob.getSprite().Gib();
			victimBlob.server_Die();
		}

		// apply hitstun to attacker if they hit another fighter
		if (hitterFighterVars !is null)
		{
			hitterFighterVars.hitstunTime = finalHitstunTime;
			hitterFighterVars.oldVel = hitterBlob.getVelocity();
			hitterFighterVars.applyOldVel = true;

			if (getNet().isServer())
			{
				SyncHitstun(hitterBlob);				
			}
		}
	}

	// Send an actual hit command just in case victim is not a fighter
	hitterBlob.server_Hit(victimBlob, hitPos, velocity, damage, customData, teamKill);
}

// keep damage status synced wwith server
void SyncDamageStatus(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_f32( fighterVars.damageStatus );

	this.SendCommand(this.getCommandID("sync damage"), bt);
}

void HandleDamageStatus(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	f32 damageStatus = bt.read_f32();

	if (apply)
	{
		fighterVars.damageStatus = damageStatus;
	}
}

// shield
void SyncShieldHit(CBlob@ this, Vec2f hitPos)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_f32( fighterVars.shieldHealth );
	bt.write_Vec2f( hitPos );

	this.SendCommand(this.getCommandID("sync shield hit"), bt);
}

Random _shieldSpark_r;
void HandleShieldHit(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	f32 shieldHealth = bt.read_f32();
	Vec2f hitPos = bt.read_Vec2f();

	// if shield happens to be desynced and deactivated for some reason, make sure it's activated
	if (shieldHealth > 0)
	{
		fighterVars.runAutoTickFunc("shield", MovesetFuncs::Shield::whileShielding, MovesetFuncs::Shield::onShieldEnd, true);
	}
	
	fighterVars.shieldHealth = shieldHealth;

	if ( getNet().isClient() )
	{
		for (int i = 0; i < 8; i++)
	    {
	        Vec2f vel(_shieldSpark_r.NextFloat() * 2.0f, 0);
	        vel.RotateBy(_shieldSpark_r.NextFloat() * 360.0f);

	        CParticle@ p = ParticlePixel( hitPos, vel, color_white, true );
	        if(p is null) return; //bail if we stop getting particles

	        p.timeout = 30 + _shieldSpark_r.NextRanged(20);
	        p.damping = 0.98f;
	        p.bounce = 0.9f;
	        p.gravity = Vec2f(0,0.05f);
	    }

		CParticle@ p = ParticleAnimated("shieldimpact.png", hitPos, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 3, 0.0f, true);
		if (p !is null)
		{
			p.Z = 1000.0f;
		}	

		this.getSprite().PlaySound("shieldbubblehit.ogg");
	}
}

void SendShieldBreak(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	fighterVars.isShielding = false;
	fighterVars.inMoveAnimation = false;
	fighterVars.hitstunTime = 16;
	fighterVars.dazeTime = 150;
	fighterVars.tumbleTime = 60;
	fighterVars.tumbleVec = Vec2f(0,-8);

	fighterVars.fastFalling = false;

	this.SendCommand(this.getCommandID("shield break"));
}

void HandleShieldBreak(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	fighterVars.shieldHealth = 0;
	fighterVars.isShielding = false;
	fighterVars.inMoveAnimation = false;
	fighterVars.hitstunTime = 16;
	fighterVars.dazeTime = 150;
	fighterVars.tumbleTime = 60;
	fighterVars.tumbleVec = Vec2f(0,-8);

	fighterVars.fastFalling = false;

	if (getNet().isClient())
	{
		CSprite@ sprite = this.getSprite();
		Vec2f thisPos = this.getPosition();

		CSpriteLayer@ shieldWave = sprite.getSpriteLayer("shield wave");
		if (shieldWave !is null)
		{
			shieldWave.SetAnimation("break");
			Animation@ waveAnim = shieldWave.getAnimation("break");
			if (waveAnim !is null)
			{
				waveAnim.SetFrameIndex(0);
			}
		}

		for (int i = 0; i < 6; i++)
		{	
			const f32 rad = 10.0f;
			Vec2f random = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ p = ParticleAnimated( "shieldimpact.png", thisPos + random, Vec2f(0,0), float(XORRandom(360)), 1.0f, 4 + XORRandom(3), 0.0f, false );
			if ( p !is null)
			{
				p.Z = 1000.0f;
			}
		}

		for (int i = 0; i < 10; i++)
	    {
	        Vec2f vel(_shieldSpark_r.NextFloat() * 3.0f, 0);
	        vel.RotateBy(_shieldSpark_r.NextFloat() * 360.0f);

	        CParticle@ p = ParticlePixel( thisPos, vel, color_white, true );
	        if(p is null) return; //bail if we stop getting particles

	        p.timeout = 30 + _shieldSpark_r.NextRanged(20);
	        p.damping = 0.98f;
	        p.bounce = 0.9f;
	        p.gravity = Vec2f(0,0.025f);
	    }

		sprite.PlaySound("shieldbreak.ogg", 2.0f);
	}
}

// grab timer
void SyncGrabEvent(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_u16( fighterVars.grabTime );

	this.SendCommand(this.getCommandID("sync grab event"), bt);
}

void HandleGrabEvent(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	u16 grabTime = bt.read_u16();

	if (apply)
	{
		fighterVars.grabTime = grabTime;

		fighterVars.inMoveAnimation = false;
	}
}

// being dazed
void SyncDazeTime(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_u16( fighterVars.dazeTime );	

	this.SendCommand(this.getCommandID("sync daze time"), bt);
}

// tumbling through the air after being hit
void SyncTumbling(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_u16( fighterVars.tumbleTime );	

	this.SendCommand(this.getCommandID("sync tumbling"), bt);
}

void HandleTumbling(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	u16 tumbleTime = bt.read_u16();

	if (apply)
	{
		fighterVars.tumbleTime = tumbleTime;
		fighterVars.startTumble = true;
	}
}

// hitstun
void SyncHitstun(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	CBitStream bt;
	bt.write_u8( fighterVars.hitstunTime );

	this.SendCommand(this.getCommandID("sync hitstun"), bt);
}

void HandleHitstun(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	u8 hitstunTime = bt.read_u8();

	if (apply)
	{
		fighterVars.hitstunTime = hitstunTime;

		fighterVars.fastFalling = false;
	}
}

void HandleKnockback(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	u8 hitstunTime = bt.read_u8();
	u16 tumbleTime = bt.read_u16();
	Vec2f tumbleVec = bt.read_Vec2f();

	if (apply)
	{
		fighterVars.hitstunTime = hitstunTime;
		fighterVars.tumbleTime = tumbleTime;
		fighterVars.tumbleVec = tumbleVec;
		fighterVars.startTumble = true;

		fighterVars.isShielding = false;

		fighterVars.fastFalling = false;
	}
}

// hitting walls
void HandleBounce(CBlob@ this, CBitStream@ bt, bool apply)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }

	u8 hitstunTime = bt.read_u8();
	Vec2f tumbleVec = bt.read_Vec2f();
	f32 effectAngle = bt.read_f32();

	if (apply)
	{
		fighterVars.hitstunTime = hitstunTime;
		fighterVars.tumbleVec = tumbleVec;

		fighterVars.isShielding = false;

		fighterVars.fastFalling = false;

		// make some craters!!!
		f32 tumbleVecLen = tumbleVec.getLength();
		if (tumbleVecLen >= 15.0f)
			Explode(this, 16.0f, 2.0f);	
		else if (tumbleVecLen >= 12.0f)	
			Explode(this, 16.0f, 1.0f);		

		Vec2f effectOffset = Vec2f(0.0f, -22.0f).RotateBy(effectAngle);
		CParticle@ p = ParticleAnimated("impact1.png", this.getPosition() + effectOffset, Vec2f(0, 0), effectAngle, 1.0f, 2, 0.0f, true);
		if (p !is null)
		{
			p.Z = 1000.0f;
		}

		this.getSprite().PlaySound("slam" + (XORRandom(3)+1) + ".ogg");
	}
}