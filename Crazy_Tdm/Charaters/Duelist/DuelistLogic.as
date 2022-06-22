// Duelist logic

#include "DuelistCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";

//attacks limited to the one time per-actor before reset.

void duelist_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool duelist_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 duelist_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void duelist_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void duelist_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
	this.set_u8("specialhit", 0);
}

void onInit(CBlob@ this)
{
	DuelistInfo duel;
	this.set("duelistInfo", @duel);

	duel.state = DuelistStates::normal;
	duel.rapierTimer = 0;
	duel.tileDestructionLimiter = 0;
	duel.decrease = false;

	this.set("duelistInfo", @duel);
	
	DuelistState@[] states;
	states.push_back(NormalState());
	states.push_back(RapierDrawnState());
	states.push_back(CutState(DuelistStates::rapier_cut));
	states.push_back(SlashState(DuelistStates::rapier_power));
	states.push_back(ResheathState(DuelistStates::resheathing_cut, DuelistVars::resheath_cut_time));
	states.push_back(ResheathState(DuelistStates::resheathing_slash, DuelistVars::resheath_slash_time));

	this.set("duelistStates", @states);
	this.set_s32("currentDuelistState", 0);

	this.set_f32("gib health", -1.5f);
	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	duelist_actorlimit_setup(this);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));


	this.addCommandID(grapple_sync_cmd);

	AddIconToken("$Rapier$", "LWBHelpIcons.png", Vec2f(16, 16), 15);

	SetHelp(this, "help self action", "duelist", getTranslatedString("$Rapier$Rapier        $LMB$"), "", 3);
	SetHelp(this, "help self hide", "duelist", getTranslatedString("Hide    $KEY_S$"), "", 1);
	SetHelp(this, "help self action2", "duelist", getTranslatedString("$Grapple$ Grappling hook    $RMB$"), "", 3);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("LWBScoreboardIcons.png", 8, Vec2f(16, 16));
	}
}

void ManageGrapple(CBlob@ this, DuelistInfo@ duel)
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);
	if (right_click)
	{
		if (canSend(this)) //otherwise grapple
		{
			duel.grappling = true;
			duel.grapple_id = 0xffff;
			duel.grapple_pos = pos;

			duel.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				duel.grapple_vel = direction * duelist_grapple_throw_speed;
			}
			else
			{
				duel.grapple_vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}
	}

	if (duel.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				duel.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 duelist_grapple_range = duelist_grapple_length * duel.grapple_ratio;
			const f32 duelist_grapple_force_limit = this.getMass() * duelist_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (duel.grapple_ratio > 0.2f)
				duel.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = duel.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - duelist_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * duelist_grapple_stiffness);
					force *= Maths::Min(duelist_grapple_force_limit, Maths::Max(0.0f, offdist + duelist_grapple_slack) * duelist_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? too long? close grapple
			if (duel.grapple_pos.x < 0 ||
			        duel.grapple_pos.x > (map.tilemapwidth)*map.tilesize ||
			        dist > duelist_grapple_length * 3.0f)
			{
				if (canSend(this))
				{
					duel.grappling = false;
					SyncGrapple(this);
				}
			}
			else if (duel.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(duel.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				duel.grapple_vel = (duel.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = duel.grapple_pos + duel.grapple_vel;
				next -= offset;

				Vec2f dir = next - duel.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						duel.grapple_pos += dir * step;
					}
					else
					{
						duel.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, duel, map, dist);
				}

			}
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if (this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - duel.grapple_pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (duel.grapple_id != 0)
				{
					@b = getBlobByNetworkID(duel.grapple_id);
					if (b is null)
					{
						duel.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					duel.grapple_pos = b.getPosition();
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							duel.grappling = false;
							SyncGrapple(this);
						}
					}
				}
				else if (shouldReleaseGrapple(this, duel, map))
				{
					if (canSend(this))
					{
						duel.grappling = false;
						SyncGrapple(this);
					}
				}

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target) &&
					(this.getVelocity().Length() > 2 || !this.isOnMap()))
				{
					this.setPosition(target);
				}

				if (b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}
}

void RunStateMachine(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
{
	DuelistState@[]@ states;
	if (!this.get("duelistStates", @states))
	{
		return;
	}

	s32 currentStateIndex = this.get_s32("currentDuelistState");

	if (getNet().isClient())
	{
		if (this.exists("serverDuelistState"))
		{
			s32 serverStateIndex = this.get_s32("serverDuelistState");
			this.set_s32("serverDuelistState", -1);
			if (serverStateIndex != -1 && serverStateIndex != currentStateIndex)
			{
				DuelistState@ serverState = states[serverStateIndex];
				u8 net_state = states[serverStateIndex].getStateValue();
				if (this.isMyPlayer())
				{
					if (net_state >= DuelistStates::rapier_cut && net_state <= DuelistStates::rapier_power)
					{
						if ((getGameTime() - serverState.stateEnteredTime) > 20)
						{
							if (duel.state != DuelistStates::rapier_drawn && duel.state != DuelistStates::resheathing_cut && duel.state != DuelistStates::resheathing_slash)
							{
								duel.state = net_state;
								serverState.stateEnteredTime = getGameTime();
								serverState.StateEntered(this, duel, serverState.getStateValue());
								this.set_s32("currentDuelistState", serverStateIndex);
								currentStateIndex = serverStateIndex;
							}
						}

					}
				}
				else
				{
					duel.state = net_state;
					serverState.stateEnteredTime = getGameTime();
					serverState.StateEntered(this, duel, serverState.getStateValue());
					this.set_s32("currentDuelistState", serverStateIndex);
					currentStateIndex = serverStateIndex;
				}

			}
		}
	}



	u8 state = duel.state;
	DuelistState@ currentState = states[currentStateIndex];

	bool tickNext = false;
	tickNext = currentState.TickState(this, duel, moveVars);

	if (state != duel.state)
	{
		for (s32 i = 0; i < states.size(); i++)
		{
			if (states[i].getStateValue() == duel.state)
			{
				s32 nextStateIndex = i;
				DuelistState@ nextState = states[nextStateIndex];
				currentState.StateExited(this, duel, nextState.getStateValue());
				nextState.StateEntered(this, duel, currentState.getStateValue());
				this.set_s32("currentDuelistState", nextStateIndex);
				if (getNet().isServer() && duel.state >= DuelistStates::rapier_drawn && duel.state <= DuelistStates::rapier_power)
				{
					this.set_s32("serverDuelistState", nextStateIndex);
					this.Sync("serverDuelistState", true);
				}

				if (tickNext)
				{
					RunStateMachine(this, duel, moveVars);

				}
				break;
			}
		}
	}
}

void onTick(CBlob@ this)
{
	DuelistInfo@ duel;
	if (!this.get("duelistInfo", @duel))
	{
		return;
	}

	ManageGrapple(this, duel);

	const bool myplayer = this.isMyPlayer();

	if(myplayer)
	{
		// space
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	bool knocked = isKnocked(this);
	CHUD@ hud = getHUD();

	//duelist logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	if (this.isInInventory())
	{
		//prevent players from insta-slashing when exiting crates
		duel.state = 0;
		duel.rapierTimer = 0;
		hud.SetCursorFrame(0);
		this.set_s32("currentDuelistState", 0);
		duel.grappling = false;
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);
	bool rapierState = isRapierState(duel.state);
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	if (getNet().isClient() && !this.isInInventory() && myplayer)  //Duel charge cursor
	{
		RapierCursorUpdate(this, duel);
	}

	if (knocked)
	{
		duel.state = DuelistStates::normal; //cancel any attacks or shielding
		duel.rapierTimer = 0;
		this.set_s32("currentDuelistState", 0);

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
		duel.grappling = false;

	}
	else
	{
		RunStateMachine(this, duel, moveVars);

	}


	if (!rapierState && getNet().isServer())
	{
		duelist_clear_actor_limits(this);
	}
}

bool getInAir(CBlob@ this)
{
	bool inair = (!this.isOnGround() && !this.isOnLadder());
	return inair;

}

class NormalState : DuelistState
{
	u8 getStateValue() { return DuelistStates::normal; }
	void StateEntered(CBlob@ this, DuelistInfo@ duel, u8 previous_state)
	{
		duel.rapierTimer = 0;
		this.set_u8("rapierSheathPlayed", 0);
		this.set_u8("animeRapierPlayed", 0);
	}

	bool TickState(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
	{
		if (this.isKeyPressed(key_action1))
		{
			duel.state = DuelistStates::rapier_drawn;
			return true;
		}

		return false;
	}
}


s32 getRapierTimerDelta(DuelistInfo@ duel, bool decrease = false)
{
	s32 delta = duel.rapierTimer;
	if (duel.rapierTimer < 128 && !decrease)
	{
		duel.rapierTimer++;
	}
	else if (duel.rapierTimer > 0 && decrease)
	{
		duel.rapierTimer--;
	}
	return delta;
}

void AttackMovement(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
{
	Vec2f vel = this.getVelocity();

	//bool strong = (duel.rapierTimer > DuelistVars::slash_charge_level2);
	moveVars.jumpFactor *= (0.8f);
	moveVars.walkFactor *= (0.9f);

	bool inair = getInAir(this);
	if (!inair)
	{
		this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
	}

	moveVars.canVault = false;
}

class RapierDrawnState : DuelistState
{
	u8 getStateValue() { return DuelistStates::rapier_drawn; }
	void StateEntered(CBlob@ this, DuelistInfo@ duel, u8 previous_state)
	{
		duel.rapierTimer = 0;
		duel.decrease = false;
		this.set_u8("rapierSheathPlayed", 0);
		this.set_u8("animeRapierPlayed", 0);
	}

	bool TickState(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			duel.state = DuelistStates::normal;
			return false;

		}

		Vec2f pos = this.getPosition();

		if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			if (duel.rapierTimer == DuelistVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeRapierPlayed", 1);
			}
		}

		if (duel.rapierTimer >= DuelistVars::slash_charge_limit)// begin discharging, other classes will be knocked when at the time like it
		{
			duel.rapierTimer = DuelistVars::slash_charge;
			duel.decrease = true;
		}
		else if (duel.rapierTimer == 0)
		{
			duel.decrease = false;
		}

		AttackMovement(this, duel, moveVars);
		s32 delta = getRapierTimerDelta(duel, duel.decrease);

		if (!this.isKeyPressed(key_action1))
		{
			if (delta < DuelistVars::slash_charge)
			{
				duel.state = DuelistStates::rapier_cut;
			}
			else if(delta < DuelistVars::slash_charge_limit)
			{
				duel.state = DuelistStates::rapier_power;
			}
		}

		return false;
	}
}

class CutState : DuelistState
{
	u8 state;
	CutState(u8 s) { state = s; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, DuelistInfo@ duel, u8 previous_state)
	{
		duelist_clear_actor_limits(this);
		duel.rapierTimer = 0;
	}

	bool TickState(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			duel.state = DuelistStates::normal;
			return false;

		}

		this.Tag("prevent crouch");

		AttackMovement(this, duel, moveVars);
		s32 delta = getRapierTimerDelta(duel);

		if (delta == DELTA_BEGIN_ATTACK)
		{
			Sound::Play("/SwordSlash", this.getPosition());
		}
		else if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
		{
			Vec2f vec;
			this.getAimDirection(vec);
			DoAttack(this, 1.0f, -(vec.Angle()), 60.0f, Hitters::sword, delta, duel);//half arc
		}
		else if (delta >= 9)
		{
			duel.state = DuelistStates::resheathing_cut;
		}

		return false;

	}
}

Vec2f getSlashDirection(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	Vec2f aiming_direction = vel;
	aiming_direction.y *= 2;
	aiming_direction.Normalize();

	return aiming_direction;
}

class SlashState : DuelistState
{
	u8 state;
	SlashState(u8 s) { state = s; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, DuelistInfo@ duel, u8 previous_state)
	{
		duelist_clear_actor_limits(this);
		duel.rapierTimer = 0;
		duel.slash_direction = getSlashDirection(this);
	}

	bool TickState(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			duel.state = DuelistStates::normal;
			return false;

		}

		/*if (getNet().isClient())
		{
			const bool myplayer = this.isMyPlayer();
			Vec2f pos = this.getPosition();
			if (duel.state == DuelistStates::rapier_power_super && this.get_u8("animeRapierPlayed") == 0)
			{
				Sound::Play("AnimeRapier.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("animeRapierPlayed", 1);
				this.set_u8("rapierSheathPlayed", 1);

			}
			else if (duel.state == DuelistStates::rapier_power && this.get_u8("rapierSheathPlayed") == 0)
			{
				Sound::Play("RapierSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
				this.set_u8("rapierSheathPlayed",  1);
			}
		}*/

		this.Tag("prevent crouch");

		AttackMovement(this, duel, moveVars);
		s32 delta = getRapierTimerDelta(duel);

		if (delta == 2)
		{
			Sound::Play("/ArgLong", this.getPosition());
			Sound::Play("/SwordSlash", this.getPosition());
		}
		else if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
		{
			Vec2f vec;
			this.getAimDirection(vec);
			DoAttack(this, 1.5f, -(vec.Angle()), 60.0f, Hitters::sword, delta, duel);//half arc
		}
		else if (delta >= DuelistVars::slash_time)
		{
			duel.state = DuelistStates::resheathing_slash;
		}

		Vec2f vel = this.getVelocity();
		if (duel.state == DuelistStates::rapier_power &&
				delta < DuelistVars::slash_move_time)
		{

			if (Maths::Abs(vel.x) < DuelistVars::slash_move_max_speed &&
					vel.y > -DuelistVars::slash_move_max_speed)
			{
				Vec2f slash_vel =  duel.slash_direction * this.getMass() * 0.5f;
				this.AddForce(slash_vel);
			}
		}

		return false;

	}
}

class ResheathState : DuelistState
{
	u8 state;
	s32 time;
	ResheathState(u8 s, s32 t) { state = s; time = t; }
	u8 getStateValue() { return state; }
	void StateEntered(CBlob@ this, DuelistInfo@ duel, u8 previous_state)
	{
		duel.rapierTimer = 0;
		this.set_u8("rapierSheathPlayed", 0);
		this.set_u8("animeRapierPlayed", 0);
	}

	bool TickState(CBlob@ this, DuelistInfo@ duel, RunnerMoveVars@ moveVars)
	{
		if (moveVars.wallsliding)
		{
			duel.state = DuelistStates::normal;
			return false;

		}
		else if (this.isKeyPressed(key_action1))
		{
			duel.state = DuelistStates::rapier_drawn;
			return true;
		}

		AttackMovement(this, duel, moveVars);
		s32 delta = getRapierTimerDelta(duel);

		if (delta > time)
		{
			duel.state = DuelistStates::normal;
		}

		return false;
	}
}

void RapierCursorUpdate(CBlob@ this, DuelistInfo@ duel)
{
		if (duel.rapierTimer >= DuelistVars::slash_charge && duel.state == DuelistStates::rapier_drawn)
		{
			getHUD().SetCursorFrame(9);
		}
		// the yellow circle stays for the duration of a slash, helpful for newplayers (note: you cant attack while its yellow)
		else if (duel.state == DuelistStates::normal || duel.state == DuelistStates::resheathing_cut || duel.state == DuelistStates::resheathing_slash) // disappear after slash is done
		// the yellow circle dissapears after mouse button release, more intuitive for improving slash timing
		// else if (duelist.rapierTimer == 0) (disappear right after mouse release)
		{
			getHUD().SetCursorFrame(0);
		}
		else if (duel.rapierTimer < DuelistVars::slash_charge && duel.state == DuelistStates::rapier_drawn)
		{
			int frame = 1 + int((float(duel.rapierTimer) / (DuelistVars::slash_charge)) * 8);
			if (duel.rapierTimer <= DuelistVars::resheath_cut_time) //prevent from appearing when jabbing/jab spamming
			{
				getHUD().SetCursorFrame(0);
			}
			else
			{
				getHUD().SetCursorFrame(frame);
			}
		}
}


bool checkGrappleStep(CBlob@ this, DuelistInfo@ duel, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(duel.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			duel.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(duel, map, dist))
	{
		duel.grapple_id = 0;

		duel.grapple_ratio = Maths::Max(0.2, Maths::Min(duel.grapple_ratio, dist / duelist_grapple_length));

		duel.grapple_pos.y = Maths::Max(0.0, duel.grapple_pos.y);

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(duel.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (duel.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					duel.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic() && !b.hasTag("ignore_arrow"))
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				duel.grapple_ratio = Maths::Max(0.2, Maths::Min(duel.grapple_ratio, b.getDistanceTo(this) / duelist_grapple_length));

				duel.grapple_id = b.getNetworkID();
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(DuelistInfo@ duel, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(duel.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(duel.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(duel.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(duel.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(duel.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, DuelistInfo@ duel, CMap@ map)
{
	return !grappleHitMap(duel, map) || this.isKeyPressed(key_use);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
}

bool isJab(f32 damage)
{
	return damage < 1.5f;
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, int deltaInt, DuelistInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = isJab(damage);
	bool dontHitMoreLogs = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore rapier")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks rapier") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (duelist_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				f32 temp_damage = damage;

				duelist_add_actor_limit(this, b);
				if (!dontHitMore && (b.getName() != "log" || !dontHitMoreLogs))
				{
					Vec2f velocity = b.getPosition() - pos;

					if (b.getName() == "log")
					{
						temp_damage /= 3;
						dontHitMoreLogs = true;
						CBlob@ wood = server_CreateBlobNoInit("mat_wood");
						if (wood !is null)
						{
							int quantity = Maths::Ceil(float(temp_damage) * 20.0f);
							int max_quantity = b.getHealth() / 0.024f; // initial log health / max mats
							
							quantity = Maths::Max(
								Maths::Min(quantity, max_quantity),
								0
							);

							wood.Tag('custom quantity');
							wood.Init();
							wood.setPosition(hi.hitpos);
							wood.server_SetQuantity(quantity);
						}

					}

					this.server_Hit(b, hi.hitpos, velocity, temp_damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							if (jab) //fake damage
							{
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);
							}
							else //reset fake dmg for next time
							{
								info.tileDestructionLimiter = 0;
							}

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, this);
								if (gold)
								{
									// Note: 0.1f damage doesn't harvest anything I guess
									// This puts it in inventory - include MaterialCommon
									//Material::fromTile(this, hi.tile, 1.f);

									CBlob@ ore = server_CreateBlobNoInit("mat_gold");
									if (ore !is null)
									{
										ore.Tag('custom quantity');
	     								ore.Init();
	     								ore.setPosition(hi.hitpos);
	     								ore.server_SetQuantity(4);
	     							}
								}
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	DuelistInfo@ duel;
	if (!this.get("duelistInfo", @duel))
	{
		return;
	}

	if (customData == Hitters::sword && duel.state == DuelistStates::rapier_cut && blockAttack(hitBlob, velocity, 0.0f))
	{
		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			setKnocked(this, 20, true);
		}
	}
}

// Blame Fuzzle.
// as same as duel
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	DuelistInfo@ duel;
	if (!this.get("duelistInfo", @duel))
	{
		return;
	}

	if (this.isAttached() && canSend(this))
	{
		duel.grappling = false;
		SyncGrapple(this);

		duel.state = DuelistStates::normal; //cancel any attacks or shielding
		duel.rapierTimer = 0;
		this.set_s32("currentDuelistState", 0);
	}
}
