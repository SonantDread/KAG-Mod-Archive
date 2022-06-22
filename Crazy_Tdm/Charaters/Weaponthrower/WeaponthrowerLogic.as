// Weaponthrower logic

#include "ThrowCommon.as"
#include "WeaponthrowerCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "KnockedCommon.as"
#include "Help.as";
#include "Requirements.as"


//attacks limited to the one time per-actor before reset.

void onInit(CBlob@ this)
{
	WeaponthrowerInfo wter;

	wter.state = WeaponthrowerStates::normal;
	wter.weaponTimer = 0;
	wter.slideTime = 0;
	wter.doublethrow = false;
	wter.shield_down = getGameTime();
	wter.fletch_cooldown = 0;
	wter.weapon_type = WeaponType::boomerang;

	this.set("weaponthrowerInfo", @wter);

	WeaponthrowerState@[] states;
	states.push_back(NormalState());
	states.push_back(ShieldingState());
	states.push_back(ShieldGlideState());
	states.push_back(ShieldSlideState());
	states.push_back(WeaponDrawnState());
	states.push_back(ThrowState(WeaponthrowerStates::weapon_throw));
	states.push_back(ThrowState(WeaponthrowerStates::weapon_throw_super));
	states.push_back(ResheathState(WeaponthrowerStates::resheathing_throw, WeaponthrowerVars::resheath_throw_time));

	this.set("weaponthrowerStates", @states);
	this.set_s32("currentWeaponthrowerState", 0);

	this.set_f32("gib health", -1.5f);
	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");

	this.addCommandID("pickup chakram");

	for (uint i = 0; i < weaponTypeNames.length; i++)
	{
		this.addCommandID("pick " + weaponTypeNames[i]);
	}

	//centered on weapon select
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	AddIconToken("$Help_Weapon$", "LWBHelpIcons.png", Vec2f(16, 16), 16);
	AddIconToken("$Help_Weapon1$", "LWBHelpIcons.png", Vec2f(8, 16), 34);
	AddIconToken("$Help_Weapon2$", "LWBHelpIcons.png", Vec2f(8, 16), 35);

	const string texName = "Entities/Characters/Weaponthrower/WeaponthrowerIcons.png";
	AddIconToken("$Boomerang$", texName, Vec2f(16, 32), 0);
	AddIconToken("$Chakram$", texName, Vec2f(16, 32), 1);

	SetHelp(this, "help self action", "weaponthrower", getTranslatedString("$Help_Weapon$Throw        $LMB$"), "", 4);
	SetHelp(this, "help self action2", "weaponthrower", getTranslatedString("$Shield$Shield    $KEY_HOLD$$RMB$"), "", 4);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("LWBScoreboardIcons.png", 10, Vec2f(16, 16));
	}
}


void RunStateMachine(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
{
	WeaponthrowerState@[]@ states;
	if (!this.get("weaponthrowerStates", @states))
	{
		return;
	}

	s32 currentStateIndex = this.get_s32("currentWeaponthrowerState");

	if (getNet().isClient())
	{
		if (this.exists("serverWeaponthrowerState"))
		{
			s32 serverStateIndex = this.get_s32("serverWeaponthrowerState");
			this.set_s32("serverWeaponthrowerState", -1);
			if (serverStateIndex != -1 && serverStateIndex != currentStateIndex)
			{
				WeaponthrowerState@ serverState = states[serverStateIndex];
				u8 net_state = states[serverStateIndex].getStateValue();
				if (this.isMyPlayer())
				{
					if (net_state >= WeaponthrowerStates::weapon_throw && net_state <= WeaponthrowerStates::weapon_throw_super)
					{
						if (wter.state != WeaponthrowerStates::weapon_drawn && wter.state != WeaponthrowerStates::resheathing_throw)
						{
							if ((getGameTime() - serverState.stateEnteredTime) > 20)
							{
								wter.state = net_state;
								serverState.stateEnteredTime = getGameTime();
								serverState.StateEntered(this, wter, serverState.getStateValue());
								this.set_s32("currentWeaponthrowerState", serverStateIndex);
								currentStateIndex = serverStateIndex;
							}

						}

					}
				}
				else
				{
					wter.state = net_state;
					serverState.stateEnteredTime = getGameTime();
					serverState.StateEntered(this, wter, serverState.getStateValue());
					this.set_s32("currentWeaponthrowerState", serverStateIndex);
					currentStateIndex = serverStateIndex;
				}

			}
		}
	}



	u8 state = wter.state;
	WeaponthrowerState@ currentState = states[currentStateIndex];

	bool tickNext = false;
	tickNext = currentState.TickState(this, wter, moveVars);

	if (state != wter.state)
	{
		for (s32 i = 0; i < states.size(); i++)
		{
			if (states[i].getStateValue() == wter.state)
			{
				s32 nextStateIndex = i;
				WeaponthrowerState@ nextState = states[nextStateIndex];
				currentState.StateExited(this, wter, nextState.getStateValue());

				nextState.stateEnteredTime = getGameTime();
				nextState.StateEntered(this, wter, currentState.getStateValue());
				this.set_s32("currentWeaponthrowerState", nextStateIndex);
				if (getNet().isServer() && wter.state >= WeaponthrowerStates::weapon_drawn && wter.state <= WeaponthrowerStates::weapon_throw_super)
				{
					this.set_s32("serverWeaponthrowerState", nextStateIndex);
					this.Sync("serverWeaponthrowerState", true);
				}

				if (tickNext)
				{
					RunStateMachine(this, wter, moveVars);

				}
				break;
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if(this.hasTag("ShieldBash"))
	{
		this.Untag("ShieldBash");
	}

	bool knocked = isKnocked(this);
	CHUD@ hud = getHUD();

	//weaponthrower logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	WeaponthrowerInfo@ wter;
	if (!this.get("weaponthrowerInfo", @wter))
	{
		return;
	}

	if (this.isInInventory())
	{
		//prevent players from insta-throwing when exiting crates
		wter.state = 0;
		wter.weaponTimer = 0;
		wter.slideTime = 0;
		wter.doublethrow = false;
		hud.SetCursorFrame(0);
		this.set_s32("currentWeaponthrowerState", 0);
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);
	bool shieldState = isShieldState(wter.state);
	bool specialShieldState = isSpecialShieldState(wter.state);
	bool weaponState = isWeaponState(wter.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	if (getNet().isClient() && !this.isInInventory() && myplayer)  //Weaponthrower charge cursor
	{
		WeaponCursorUpdate(this, wter);
	}

	if (knocked)
	{
		wter.state = WeaponthrowerStates::normal; //cancel any attacks or shielding
		wter.weaponTimer = 0;
		wter.slideTime = 0;
		wter.doublethrow = false;
		this.set_s32("currentWeaponthrowerState", 0);

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else
	{
		RunStateMachine(this, wter, moveVars);

	}

	if (myplayer)
	{
		if (wter.fletch_cooldown > 0)
		{
			wter.fletch_cooldown--;
		}

		CControls@ controls = getControls();
		if (this.isKeyPressed(key_action3) && controls.ActionKeyPressed(AK_BUILD_MODIFIER))
		{
			// pickup from ground

			if (wter.fletch_cooldown == 0)
			{
				if (getPickupChakram(this) !is null)   // pickup weapon from ground
				{
					this.SendCommand(this.getCommandID("pickup chakram"));
					wter.fletch_cooldown = PICKUP_COOLDOWN;
				}
			}
		}

		// space
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}

		// help

		if (this.isKeyJustPressed(key_action1) && getGameTime() > 150)
		{
			SetHelp(this, "help self action", "weaponthrower", getTranslatedString("$Help_Weapon$ Throw!    $KEY_HOLD$$LMB$"), "", 13);
		}
	}

	//setting the shield direction properly
	if (shieldState)
	{
		int horiz = this.isFacingLeft() ? -1 : 1;
		setShieldEnabled(this, true);
		setShieldAngle(this, SHIELD_BLOCK_ANGLE);

		if (specialShieldState)
		{
			if (wter.state == WeaponthrowerStates::shieldgliding)
			{
				setShieldDirection(this, Vec2f(0, -1));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_GLIDING);
			}
			else //shield dropping
			{
				setShieldDirection(this, Vec2f(horiz, 2));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_SLIDING);
			}
			this.Tag("prevent crouch");
		}
		else if (walking)
		{
			if (direction == 0) //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else
			{
				setShieldDirection(this, Vec2f(horiz, -3));
			}

			this.Tag("prevent crouch");
		}
		else
		{
			if (direction == 0)   //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else //up
			{
				if (vec.y < -0.97)
				{
					setShieldDirection(this, Vec2f(0, -1));
				}
				else
				{
					setShieldDirection(this, Vec2f(horiz, -3));
				}
			}
		}

		// shield up = collideable

		if ((wter.state == WeaponthrowerStates::shielding && direction == -1) ||
		        wter.state == WeaponthrowerStates::shieldgliding)
		{
			if (!this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Tag("shieldplatform");
			}
		}
		else
		{
			if (this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Untag("shieldplatform");
			}
		}
	}
	else
	{
		setShieldEnabled(this, false);

		if (this.hasTag("shieldplatform"))
		{
			this.getShape().checkCollisionsAgain = true;
			this.Untag("shieldplatform");
		}
	}

}

bool getInAir(CBlob@ this)
{
	bool inair = (!this.isOnGround() && !this.isOnLadder());
	return inair;

}

void ShieldMovement(RunnerMoveVars@ moveVars)
{
	moveVars.jumpFactor *= 0.5f;
	moveVars.walkFactor *= 0.9f;
}

class NormalState : WeaponthrowerState
{
	u8 getStateValue() { return WeaponthrowerStates::normal; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
		this.set_u8("weaponSheathPlayed", 0);
		this.set_u8("animeWeaponPlayed", 0);
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action2))
		{
			if (canRaiseShield(this))
			{
				wter.state = WeaponthrowerStates::shielding;
				return true;
			}
			else
			{
				resetShieldKnockdown(this);
			}

			ShieldMovement(moveVars);

		}
		else if (this.isKeyPressed(key_action1) && !moveVars.wallsliding)
		{
			wter.state = WeaponthrowerStates::weapon_drawn;
			return true;
		}

		return false;
	}
}

bool getForceDrop(CBlob@ this, RunnerMoveVars@ moveVars)
{
	Vec2f vel = this.getVelocity();
	bool forcedrop = (vel.y > Maths::Max(Maths::Abs(vel.x), 2.0f) &&
					  moveVars.fallCount > WeaponthrowerVars::glide_down_time);
	return forcedrop;
}

class ShieldingState : WeaponthrowerState
{
	u8 getStateValue() { return WeaponthrowerStates::shielding; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			wter.state = WeaponthrowerStates::weapon_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			wter.state = WeaponthrowerStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				wter.state = WeaponthrowerStates::shieldgliding;
				return true;
			}
			else if (forcedrop || direction == 1)
			{
				wter.state = WeaponthrowerStates::shielddropping;
				return true;
			}
		}

		ShieldMovement(moveVars);

		return false;
	}
}

class ShieldGlideState : WeaponthrowerState
{
	u8 getStateValue() { return WeaponthrowerStates::shieldgliding; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			wter.state = WeaponthrowerStates::weapon_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			wter.state = WeaponthrowerStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				// already in WeaponthrowerStates::shieldgliding;
			}
			else if (forcedrop || direction == 1)
			{
				wter.state = WeaponthrowerStates::shielddropping;
				return true;
			}
			else
			{
				wter.state = WeaponthrowerStates::shielding;
				ShieldMovement(moveVars);
				return false;
			}

		}

		ShieldMovement(moveVars);

		if (this.isInWater() || forcedrop)
		{
			wter.state = WeaponthrowerStates::shielding;
		}
		else
		{
			Vec2f vel = this.getVelocity();

			moveVars.stoppingFactor *= 0.5f;
			f32 glide_amount = 1.0f - (moveVars.fallCount / f32(WeaponthrowerVars::glide_down_time * 2));

			if (vel.y > -1.0f)
			{
				this.AddForce(Vec2f(0, -20.0f * glide_amount));
			}

			if (!inair)
			{
				wter.state = WeaponthrowerStates::shielding;
			}

		}

		return false;
	}
}

class ShieldSlideState : WeaponthrowerState
{
	u8 getStateValue() { return WeaponthrowerStates::shielddropping; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			wter.state = WeaponthrowerStates::weapon_drawn;
			return true;
		}
		else if (!this.isKeyPressed(key_action2))
		{
			wter.state = WeaponthrowerStates::normal;
			return false;
		}

		Vec2f pos = this.getPosition();
		bool forcedrop = getForceDrop(this, moveVars);

		bool inair = getInAir(this);
		if (inair && !this.isInWater())
		{
			Vec2f vec;
			const int direction = this.getAimDirection(vec);
			if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
			{
				wter.state = WeaponthrowerStates::shieldgliding;
				return true;
			}
			else if (forcedrop || direction == 1)
			{
				// already in WeaponthrowerStates::shielddropping;
				wter.slideTime = 0;
			}
			else
			{
				wter.state = WeaponthrowerStates::shielding;
				ShieldMovement(moveVars);
				return false;
			}
		}

		ShieldMovement(moveVars);

		Vec2f vel = this.getVelocity();

		if (this.isInWater())
		{
			if (vel.y > 1.5f && Maths::Abs(vel.x) * 3 > Maths::Abs(vel.y))
			{
				vel.y = Maths::Max(-Maths::Abs(vel.y) + 1.0f, -8.0);
				this.setVelocity(vel);
			}
			else
			{
				wter.state = WeaponthrowerStates::shielding;
			}
		}

		if (!inair && this.getShape().vellen < 1.0f)
		{
			wter.state = WeaponthrowerStates::shielding;
		}
		else
		{
			// faster sliding
			if (!inair)
			{
				wter.slideTime++;
				if (wter.slideTime > 0)
				{
					if (wter.slideTime == 5)
					{
						this.getSprite().PlayRandomSound("/Scrape");
					}

					f32 factor = Maths::Max(1.0f, 2.2f / Maths::Sqrt(wter.slideTime));
					moveVars.walkFactor *= factor;

					if (wter.slideTime > 30)
					{
						moveVars.walkFactor *= 0.75f;
						if (wter.slideTime > 45)
						{
							wter.state = WeaponthrowerStates::shielding;
						}
					}
					else if (XORRandom(3) == 0)
					{
						Vec2f pos = this.getPosition();
						Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
						velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
						ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);
					}
				}
			}
			else if (vel.y > 1.05f)
			{
				wter.slideTime = 0;
			}

		}

		return false;

	}
}

s32 getWeaponTimerDelta(WeaponthrowerInfo@ wter)
{
	s32 delta = wter.weaponTimer;
	if (wter.weaponTimer < 128)
	{
		wter.weaponTimer++;
	}
	return delta;
}

void AttackMovement(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
{
	Vec2f vel = this.getVelocity();

	bool strong = (wter.weaponTimer > WeaponthrowerVars::throw_charge_level2);
	moveVars.jumpFactor *= (strong ? 0.6f : 0.8f);
	moveVars.walkFactor *= (strong ? 0.8f : 0.9f);

	bool inair = getInAir(this);
	if (!inair)
	{
		this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
	}

	moveVars.canVault = false;
}

class WeaponDrawnState : WeaponthrowerState
{
	u8 getStateValue() { return WeaponthrowerStates::weapon_drawn; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
		this.set_u8("swordSheathPlayed", 0);
		this.set_u8("animeSwordPlayed", 0);
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			wter.state = WeaponthrowerStates::normal;
			return false;

		}

		Vec2f pos = this.getPosition();

		if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			if (wter.weaponTimer == WeaponthrowerVars::throw_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeSwordPlayed", 1);

			}
			else if (wter.weaponTimer == WeaponthrowerVars::throw_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("swordSheathPlayed",  1);
			}
		}

		if (wter.weaponTimer >= WeaponthrowerVars::throw_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			setKnocked(this, 15);
			wter.state = WeaponthrowerStates::normal;
		}

		if (this.isKeyPressed(key_action2))// cancel throwing
		{
			wter.state = WeaponthrowerStates::normal;
			this.getSprite().PlaySound("PopIn.ogg");
			return false;
		}

		AttackMovement(this, wter, moveVars);
		s32 delta = getWeaponTimerDelta(wter);

		if (!this.isKeyPressed(key_action1))
		{
			if (delta < WeaponthrowerVars::throw_charge)
			{
				wter.state = WeaponthrowerStates::normal;
			}
			else if (delta < WeaponthrowerVars::throw_charge_level2)
			{
				wter.state = WeaponthrowerStates::weapon_throw;
			}
			else if(delta < WeaponthrowerVars::throw_charge_limit)
			{
				wter.state = WeaponthrowerStates::weapon_throw_super;
			}
		}

		return false;
	}
}

class ThrowState : WeaponthrowerState
{
	u8 state;
	ThrowState(u8 s) { state = s; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			wter.state = WeaponthrowerStates::normal;
			return false;

		}

		if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			Vec2f pos = this.getPosition();
			if (wter.state == WeaponthrowerStates::weapon_throw_super && this.get_u8("animeSwordPlayed") == 0)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeSwordPlayed", 1);
				this.set_u8("swordSheathPlayed", 1);

			}
			else if (wter.state == WeaponthrowerStates::weapon_throw && this.get_u8("swordSheathPlayed") == 0)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("swordSheathPlayed",  1);
			}
		}

		this.Tag("prevent crouch");

		AttackMovement(this, wter, moveVars);
		s32 delta = getWeaponTimerDelta(wter);

		if (wter.state == WeaponthrowerStates::weapon_throw_super
			&& this.isKeyJustPressed(key_action1))
		{
			wter.doublethrow = true;
		}

		if (delta == 2)
		{
			if(hasWeapons(this, wter.weapon_type))
			{
				Sound::Play("/ArgLong", this.getPosition());
				Sound::Play("/SwordSlash", this.getPosition());
			}
			else if(this.isMyPlayer())
			{
				Sound::Play("/NoAmmo");
			}
		}
		else if (delta == DELTA_BEGIN_ATTACK + 1)
		{
			DoThrow(this, wter);
			wter.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make chakram
		}
		else if (delta >= WeaponthrowerVars::throw_time
			|| (wter.doublethrow && delta >= WeaponthrowerVars::double_throw_time) && !(delta < 10))
		{
			if (wter.doublethrow)
			{
				wter.doublethrow = false;
				wter.state = WeaponthrowerStates::weapon_throw;
			}
			else
			{
				wter.state = WeaponthrowerStates::resheathing_throw;
			}
		}

		return false;

	}
}

class ResheathState : WeaponthrowerState
{
	u8 state;
	s32 time;
	ResheathState(u8 s, s32 t) { state = s; time = t; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, WeaponthrowerInfo@ wter, u8 previous_state)
	{
		wter.weaponTimer = 0;
		this.set_u8("swordSheathPlayed", 0);
		this.set_u8("animeSwordPlayed", 0);
	}

	bool TickState(CBlob@ this, WeaponthrowerInfo@ wter, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			wter.state = WeaponthrowerStates::normal;
			return false;

		}
		else if (this.isKeyPressed(key_action1))
		{
			wter.state = WeaponthrowerStates::weapon_drawn;
			return true;
		}

		AttackMovement(this, wter, moveVars);
		s32 delta = getWeaponTimerDelta(wter);

		if (delta > time)
		{
			wter.state = WeaponthrowerStates::normal;
		}

		return false;
	}
}

CBlob@ getPickupChakram(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "chakram")
			{
				return b;
			}
		}
	}
	return null;
}

bool canPickSpriteChakram(CBlob@ this, bool takeout)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "chakram")
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("default") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("default");
					return true;
				}
			}
		}
	}
	return false;
}

void WeaponCursorUpdate(CBlob@ this, WeaponthrowerInfo@ wter)
{
		if (wter.weaponTimer >= WeaponthrowerVars::throw_charge_level2 || wter.doublethrow || wter.state == WeaponthrowerStates::weapon_throw_super)
		{
			getHUD().SetCursorFrame(19);
		}
		else if (wter.weaponTimer >= WeaponthrowerVars::throw_charge)
		{
			int frame = 1 + int((float(wter.weaponTimer - WeaponthrowerVars::throw_charge) / (WeaponthrowerVars::throw_charge_level2 - WeaponthrowerVars::throw_charge)) * 9) * 2;
			getHUD().SetCursorFrame(frame);
		}
		// the yellow circle stays for the duration of a throw, helpful for newplayers (note: you cant attack while its yellow)
		else if (wter.state == WeaponthrowerStates::normal || wter.state == WeaponthrowerStates::resheathing_throw) // disappear after throw is done
		// the yellow circle dissapears after mouse button release, more intuitive for improving throw timing
		// else if (wter.weaponTimer == 0) (disappear right after mouse release)
		{
			getHUD().SetCursorFrame(0);
		}
		else if (wter.weaponTimer < WeaponthrowerVars::throw_charge && wter.state == WeaponthrowerStates::weapon_drawn)
		{
			int frame = 2 + int((float(wter.weaponTimer) / WeaponthrowerVars::throw_charge) * 8) * 2;
			getHUD().SetCursorFrame(frame);
		}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pickup chakram"))
	{
		CBlob@ chakram = getPickupChakram(this);
		bool spriteChakram = canPickSpriteChakram(this, false); // unnecessary

		if (chakram !is null || spriteChakram)
		{

			if (getNet().isServer())
			{
				CBlob@ mat_chakrams = server_CreateBlobNoInit('mat_chakrams');

				if (mat_chakrams !is null)
				{
					mat_chakrams.Tag('custom quantity');
					mat_chakrams.Init();

					mat_chakrams.server_SetQuantity(1); // unnecessary

					if (not this.server_PutInInventory(mat_chakrams))
					{
						mat_chakrams.setPosition(this.getPosition());
					}

					if (chakram !is null)
					{
						chakram.server_Die();
					}
					else
					{
						canPickSpriteChakram(this, true);
					}
				}
			}

			this.getSprite().PlaySound("Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg");
		}
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle weapons
		WeaponthrowerInfo@ wter;
		if (!this.get("weaponthrowerInfo", @wter))
		{
			return;
		}
		if (isWeaponState(wter.state))
		{
			return;
		}
		u8 type = wter.weapon_type;

		type++;
		if (type >= weaponTypeNames.length)
		{
			type = 0;
		}

		wter.weapon_type = type;
		if (this.isMyPlayer())
		{
			Sound::Play("/CycleInventory.ogg");
		}
	}
	else
	{
		WeaponthrowerInfo@ wter;
		if (!this.get("weaponthrowerInfo", @wter))
		{
			return;
		}
		if (isWeaponState(wter.state))
		{
			return;
		}
		for (uint i = 0; i < weaponTypeNames.length; i++)
		{
			if (cmd == this.getCommandID("pick " + weaponTypeNames[i]))
			{
				wter.weapon_type = i;
				break;
			}
		}
	}
}

/////////////////////////////////////////////////


bool isSliding(WeaponthrowerInfo@ wter)
{
	return (wter.slideTime > 0 && wter.slideTime < 45);
}

void DoThrow(CBlob@ this, WeaponthrowerInfo info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (!hasWeapons(this, info.weapon_type))
	{
		return;
	}

	CBlob@ weapon = server_CreateBlobNoInit((info.weapon_type == WeaponType::chakram) ? "chakram" : "boomerang");
	if (weapon !is null)
	{
		weapon.SetDamageOwnerPlayer(this.getPlayer());
		weapon.Init();

		Vec2f offset(this.isFacingLeft() ? 2 : -2, -2);
		Vec2f weaponPos = this.getPosition() + offset;
		Vec2f weaponVel = this.getAimPos() - weaponPos;
		weaponVel.Normalize();
		Vec2f weaponOffset = weaponVel;
		weaponVel *= (info.weapon_type == WeaponType::chakram) ? 12.0f : 17.59f;

		weapon.IgnoreCollisionWhileOverlapped(this);
		weapon.server_setTeamNum(this.getTeamNum());
		weapon.setPosition(weaponPos + weaponOffset * 2);
		weapon.setVelocity(weaponVel);
		this.TakeBlob(weaponTypeNames[info.weapon_type], 1);
	}
}

// shieldbash

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	const bool onground = this.isOnGround();
	if (this.getShape().vellen > SHIELD_KNOCK_VELOCITY || onground)
	{
		WeaponthrowerInfo@ wter;
		if (!this.get("weaponthrowerInfo", @wter))
		{
			return;
		}

		//printf("wter.stat " + wter.state );
		if (wter.state == WeaponthrowerStates::shielddropping &&
		        (!onground || isSliding(wter)) &&
		        (blob.getShape() !is null && !blob.getShape().isStatic()) &&
		        !isKnocked(blob))
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getOldVelocity();
			vel.Normalize();

			//printf("nor " + vel * normal );
			if (vel * normal < 0.0f && this.hasTag("ShieldBash")) //only bash one thing per tick, knight uses limited actors system
			{
				ShieldVars@ shieldVars = getShieldVars(this);
				//printf("shi " + shieldVars.direction * normal );
				if (shieldVars.direction * normal < 0.0f)
				{
					this.Tag("ShieldBash");
					this.server_Hit(blob, pos, vel, 0.0f, Hitters::shield);

					Vec2f force = Vec2f(shieldVars.direction.x * this.getMass(), -this.getMass()) * 3.0f;

					blob.AddForce(force);
					this.AddForce(Vec2f(-force.x, force.y));
				}
			}
		}
	}
}

//weapon management

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::shield)
	{
		setKnocked(hitBlob, 20, true);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
	}
}

// weapon pick menu

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (weaponTypeNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(weaponTypeNames.length, 2), getTranslatedString("Current weapon"));

	WeaponthrowerInfo@ wter;
	if (!this.get("weaponthrowerInfo", @wter))
	{
		return;
	}
	const u8 weaponSel = wter.weapon_type;

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < weaponTypeNames.length; i++)
		{
			string matname = weaponTypeNames[i];
			CGridButton @button = menu.AddButton(weaponIcons[i], getTranslatedString(weaponNames[i]), this.getCommandID("pick " + matname));

			if (button !is null)
			{
				bool enabled = this.getBlobCount(weaponTypeNames[i]) > 0;
				button.SetEnabled(enabled);
				button.selectOneOnClick = true;
				if (weaponSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	if (!ap.socket) {
		WeaponthrowerInfo@ wter;
		if (!this.get("weaponthrowerInfo", @wter))
		{
			return;
		}

		wter.state = WeaponthrowerStates::normal; //cancel any attacks or shielding
		wter.weaponTimer = 0;
		wter.doublethrow = false;
		this.set_s32("currentWeaponthrowerState", 0);
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
	if (this.isMyPlayer() && this.getInventory().getItemsCount() > 1)
	{
		for (uint j = 1; j < weaponTypeNames.length; j++)
		{
			if (itemname == weaponTypeNames[j])
			{
				SetHelp(this, "help inventory", "weaponthrower", "$Help_Weapon1$$Swap$$Help_Weapon2$         $KEY_TAP$$KEY_F$", "", 2);
				break;
			}
		}
	}
}