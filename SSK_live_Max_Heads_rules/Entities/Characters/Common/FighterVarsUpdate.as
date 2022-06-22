// Runner Movement

#include "FighterVarsCommon.as"
#include "FighterMovesetCommon.as"

bool damageSynced = false;

void onInit(CBlob@ this)
{
	SSKFighterVars fighterVars;

	fighterVars.damageStatus = 0.0f;

	fighterVars.hitstunTime = 0;
	fighterVars.oldVel = Vec2f_zero;
	fighterVars.applyOldVel = false;

	fighterVars.grabTime = 0;

	fighterVars.dazeTime = 0;
	fighterVars.disableItemActions = false;

	fighterVars.knockbackForce = Vec2f_zero;

	fighterVars.tumbleTime = 0;
	fighterVars.tumbleVec = Vec2f_zero;
	fighterVars.startTumble = false;

	fighterVars.gravityEnabled = true;

	fighterVars.fallSpecial = false;

	fighterVars.fastFalling = false;

	fighterVars.inMoveAnimation = false;
	fighterVars.currMoveFrameIndex = 0;
	fighterVars.currMoveFrameTimer = 0;
	fighterVars.hasAttackedOnCurrFrame = false;

	fighterVars.inMiscAttack = false;

	fighterVars.isShielding = false;
	fighterVars.shieldHealth = MAX_SHIELD_HEALTH;

	this.set("fighterVars", fighterVars);

	this.addCommandID("sync damage");
	this.addCommandID("sync shield hit");
	this.addCommandID("shield break");
	this.addCommandID("sync grab event");
	this.addCommandID("sync daze time");
	this.addCommandID("sync tumbling");
	this.addCommandID("sync hitstun");
	this.addCommandID("sync knockback");
	this.addCommandID("sync bounce");

	this.set_bool("damageSynced", false);
}

void onTick(CBlob@ this)
{
	bool damageSynced = this.get_bool("damageSynced");
	if (!damageSynced && getNet().isServer() && this.getTickSinceCreated() > 10)
	{
		SyncDamageStatus(this);
		this.set_bool("damageSynced", true);
		this.Sync("damageSynced", true);
	}

	SSKFighterVars@ fighterVars;
	if (this.get("fighterVars", @fighterVars)) 
	{
		updateHitstun(this, fighterVars);
		updateGrabTime(this, fighterVars);
		updateDazeTime(this, fighterVars);
		updateTumble(this, fighterVars);

		updateAutoTickFuncs(this, fighterVars);
	}
}

void updateAutoTickFuncs(CBlob@ this, SSKFighterVars@ fighterVars)
{
	for(int i = 0; i < fighterVars.autoTickFuncs.length(); i++)
	{
		AutoTickFunc @autoTickFunc = fighterVars.autoTickFuncs[i];

		// keep the AutoTickFuncs going until attack hitstun time expires
		if (fighterVars.hitstunTime > 0 && !autoTickFunc.activeDuringHitstun)	
		{
			//autoTickFunc.ticksActive++;
			continue;
		}

		// switch AutoTickFuncs on and off
		if (autoTickFunc.ticksActive > 0)
		{
			if (autoTickFunc.whileActive !is null)
			{
				autoTickFunc.whileActive(this, fighterVars);
			}

			autoTickFunc.ticksActive--;
		}
		else
		{
			autoTickFunc.onDeactivate(this, fighterVars);

			// delete autoTickFunc so it's no longer in our array
			fighterVars.autoTickFuncs.removeAt(i);
		}
	}
}

// tumble and hitstun functions

void updateTumble(CBlob@ this, SSKFighterVars@ fighterVars)
{
	u16 tumbleTime = fighterVars.tumbleTime;
	if (fighterVars.hitstunTime <= 0 && tumbleTime > 0)
	{
		// Play the launch sound when knockback/tumbling starts
		if (fighterVars.startTumble)
		{
			CSprite@ sprite = this.getSprite();
			f32 tumbleVecLen = fighterVars.tumbleVec.getLength();
			if ( tumbleVecLen >= 5.0f && tumbleVecLen < 8.0f )
			{
				sprite.PlaySound("launch1.ogg", 0.5f);
			}
			else if ( tumbleVecLen >= 8.0f && tumbleVecLen < 13.0f )
			{
				sprite.PlaySound("launch2.ogg", 0.5f);
			}
			else if ( tumbleVecLen >= 13.0f && tumbleVecLen < 20.0f )
			{
				sprite.PlaySound("launch3.ogg", 0.5f);
				sprite.PlaySound("stronghit1.ogg", 1.0f);
			}
			else if ( tumbleVecLen >= 20.0f )
			{
				sprite.PlaySound("launch3.ogg");
				sprite.PlaySound("homerun1.ogg");
			}

			fighterVars.startTumble = false;
		}

		fighterVars.tumbleTime--;
	}
}

void updateHitstun(CBlob@ this, SSKFighterVars@ fighterVars) 
{
	u8 hitstunned = fighterVars.hitstunTime;
	if (hitstunned > 0)
	{
		fighterVars.hitstunTime--;
	}
}

void updateGrabTime(CBlob@ this, SSKFighterVars@ fighterVars)
{
	if (!this.hasAttached())
		return;

	u16 grabTime = fighterVars.grabTime;

	bool shouldDetach = false;

	CBlob @carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.hasTag("player"))
		{
			SSKFighterVars@ heldFighterVars;
			if (carried.get("fighterVars", @heldFighterVars)) 
			{
				if ( grabTime > (MIN_GRABTIME + heldFighterVars.damageStatus*0.5f) )
				{
					shouldDetach = true;
				}
			}
			else if (grabTime > MIN_GRABTIME)
			{
				shouldDetach = true;
			}

			if (shouldDetach)
			{
				this.DropCarried();
				fighterVars.grabTime = 0;
			}
			else
			{
				grabTime++;
				fighterVars.grabTime = grabTime;
			}
		}
	}
}

void updateDazeTime(CBlob@ this, SSKFighterVars@ fighterVars)
{
	u16 dazeTime = fighterVars.dazeTime;
	if (dazeTime > 0)
	{
		dazeTime--;

		fighterVars.dazeTime = dazeTime;
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("sync damage"))
	{
		HandleDamageStatus(this, params, true);
	}
	else if (cmd == this.getCommandID("sync shield hit"))
	{
		HandleShieldHit(this, params, true);
	}
	else if (cmd == this.getCommandID("shield break"))
	{
		HandleShieldBreak(this, params, true);
	}
	else if (cmd == this.getCommandID("sync grab event"))
	{
		HandleGrabEvent(this, params, true);
	}
	else if (cmd == this.getCommandID("sync daze time"))
	{
		SSKFighterVars@ fighterVars;
		if (!this.get("fighterVars", @fighterVars)) { return; }

		u16 dazeTime = params.read_u16();
		fighterVars.dazeTime = dazeTime;
	}
	else if (cmd == this.getCommandID("sync tumbling"))
	{
		HandleTumbling(this, params, true);
	}
	else if (cmd == this.getCommandID("sync hitstun"))
	{
		HandleHitstun(this, params, true);
	}
	else if (cmd == this.getCommandID("sync knockback"))
	{
		HandleKnockback(this, params, true);
	}
	else if (cmd == this.getCommandID("sync bounce"))
	{
		HandleBounce(this, params, true);
	}
}

bool canSend(CBlob@ this)
{
	//return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());

	return getNet().isServer();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	// play sound for letting players and items go
	if (detached.hasTag("player"))
	{
		this.getSprite().PlaySound("fighterletgo1.ogg", 3.0f);	
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars)) { return; }
	fighterVars.inMoveAnimation = false;

	if(attached.hasTag("player"))
	{
		this.getSprite().PlaySound("grab3.ogg", 1.0f);
	}
	else
	{
		this.getSprite().PlaySound("grab2.ogg", 2.0f);
		CParticle@ p = ParticleAnimated( "impulse1.png", attached.getPosition(), Vec2f_zero, float(XORRandom(360)), 1.0f, 1, 0.0f, false );
		if ( p !is null)
		{
			p.Z = 10.0f;
		}
	}
}
