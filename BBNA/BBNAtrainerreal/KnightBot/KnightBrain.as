// Script by Yeti5000707 (Blav)
// Good Bots

#define SERVER_ONLY

#include "BrainCommon.as"
#include "KnockedCommon.as"

// Show emotes?
bool emote = false;

void onInit(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	InitBrain(this);
	this.server_SetActive(true);

	blob.set_s16("slashtime", 0);
	blob.set_s16("target_slashtime", 0);
	blob.set_u8("moveover", 0);
	blob.set_s16("shieldbash_confidence", 0);
	blob.set_u8("myKey", XORRandom(250)+1); // 1-250
}

void onTick(CBrain@ this)
{	
	CBlob @blob = this.getBlob();
	// Look for closest enemy.
	SearchTarget(this, false, true);

	
	CBlob @target = this.getTarget();
	CBlob @check;


	this.getCurrentScript().tickFrequency = 18;

	bool knocked = isKnocked(blob);

	// Attacking AI
	if (target !is null)
	{
		Vec2f mypos = blob.getPosition();
		Vec2f targetPos = target.getPosition();
		Vec2f targetVector = targetPos - mypos;
		f32 targetDistance = targetVector.Length();

		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");

		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);

		if (visibleTarget && distance < 94.0f - blob.get_u8("myKey")/6) //44.0f
		{
			strategy = Strategy::attacking;
		}

		if (strategy == Strategy::idle)
		{
			strategy = Strategy::chasing;
		}
		else if (strategy == Strategy::attacking)
		{
			if (distance > 145.0f + blob.get_u8("myKey")/5)
			{
				strategy = Strategy::chasing;
			}
		}

		// Look for healing
		if (blob.getInitialHealth() > blob.getHealth() && (blob.getPosition() - target.getPosition()).getLength() > 24.0f)
		{
			if (!blob.hasBlob("food", 1) && !blob.hasBlob("heart", 1) && target !is null)
			{
				Vec2f mypos = blob.getPosition();
				Vec2f targetpos = target.getPosition();

				CBlob@[] healing;
				getBlobsByName("food", @healing);
				getBlobsByName("heart", @healing);
				for( int i = 0; i < healing.size(); i++ )
				{
					@check = healing[i];
					Vec2f dist = check.getPosition() - mypos;
					Vec2f disttoenemy = check.getPosition() - targetpos;
					if (check.isInInventory() || check.isAttached())
					{
						healing.removeAt(i);
					}
					else
					{
						if (dist.getLength() > 96.0f)
						{
							healing.removeAt(i);
						}
						else if (dist.getLength() > 40.0f && disttoenemy.getLength() < 10.0f)
						{
							healing.removeAt(i);
						}
					}
				}

				if (healing.size() > 0 && check != null)
				{
					strategy = Strategy::find_healing;
				}

				healing.clear();
			}
		}
		else
		{
			@check = null;
		}

	
		UpdateBlob(blob, target, strategy, check);

		// Shield slide if target is distant enough.
		if (targetDistance > 76.0f + blob.get_u8("myKey")/4 && !blob.isOnWall())
		{
			ShieldSlide(blob, target);

			if (!blob.isOnGround())
			{
				blob.setKeyPressed(key_up, true);
			}
		}

		// Eat if lost hp
		if (blob.getInitialHealth()-0.5f > blob.getHealth())
		{
			blob.setKeyPressed(key_eat, true);
		}

		bool knocked = isKnocked(blob);

		if (knocked)
		{
			blob.set_s16("slashtime", 0);
		}

		if (target.isKeyPressed(key_action1) && target.getName() == "knight")
		{
			blob.set_s16("target_slashtime", blob.get_s16("target_slashtime") + 1);
		}
		else
		{
			if (blob.get_s16("target_slashtime") > 1)
			{
				blob.set_s16("target_slashtime", blob.get_s16("target_slashtime") - 2);
			}

			if (blob.get_s16("target_slashtime") == 1)
			{
				blob.set_s16("target_slashtime", 0);
			}
			
			//blob.set_s16("target_slashtime", 0);
		}

		// Lose target if its killed
		if (LoseTarget(this, target))
		{
			strategy = Strategy::idle;

			blob.set_s16("target_slashtime", 0);
			blob.set_s16("shieldbash_confidence", 0);

			if (emote)
			{
				set_emote(blob, Emotes::thumbsdown, 16);
			}
		}

		blob.set_u8("strategy", strategy);
	}

	if (blob.isKeyPressed(key_action1))
	{
		blob.set_s16("slashtime", blob.get_s16("slashtime") + 1);
	}
	else if (blob.get_s16("slashtime") > 0)
	{
		blob.set_s16("slashtime", 0);
	}

	if (blob.get_s16("shieldbash_confidence") > 0)
	{
		blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") - 1);
	}

	FloatInWater(blob);
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy, CBlob@ check)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::chasing)
	{
		DefaultChaseBlob(blob, target);
	}
	else if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
	}
	else if (strategy == Strategy::find_healing)
	{
		CBrain@ brain = blob.getBrain();
		FindHeal(brain, @check, target);
	}
}

void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();

	// Aim at target, or direction of movement for more speed.
	if (targetDistance > 66.0f - blob.get_u8("myKey")/6)
	{
		blob.setAimPos(mypos + blob.getVelocity());
	}
	else
	{
		blob.setAimPos(targetPos);
	}

	if (blob.getInitialHealth()/2 > blob.getHealth())
	{
		if (targetDistance > blob.getRadius() + 15.0f)
		{
			Chase(blob, target);
		}
	}
	else
	{
		if (targetDistance > blob.getRadius() + 7.0f)
		{
			Chase(blob, target);
		}
	}

	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();

	bool shieldTime = gametime - blob.get_u32("shield time") < uint(9 * 1.33f + XORRandom(2));
	bool backOffTime = gametime - blob.get_u32("backoff time") < uint(5 + XORRandom(2));

	// Quick block an incoming jab.
	if (targetDistance < 29.0f && blob.get_s16("target_slashtime") < 14)
	{
		blob.set_u32("shield time", gametime);
		shieldTime = true;
		blob.setKeyPressed(key_action2, true);
	}

	// Target is about to attack!
	if (blob.get_s16("target_slashtime") > 10)
	{
		// Play safe if not full HP
		if (blob.getInitialHealth() != blob.getHealth())
		{
			if (!backOffTime)
			{
				blob.set_u32("shield time", gametime);
				shieldTime = true;
				blob.setKeyPressed(key_action2, true);
			}
			else if (!shieldTime)
			{
				// raycast to check if there is a hole behind

				Vec2f raypos = mypos;
				raypos.x += targetPos.x < mypos.x ? 32.0f : -32.0f;
				Vec2f col;
				if (getMap().rayCastSolid(raypos, raypos + Vec2f(0.0f, 32.0f), col))
				{
					blob.set_u32("backoff time", gametime);
					backOffTime = true;
					blob.setKeyPressed(key_action2, true);
				}
			}
		}

		if (targetDistance < 170.0f - blob.get_u8("myKey")/3 && !isKnocked(target))
		{
			if (target.getPosition().x * (target.getVelocity().x * 2) > blob.getPosition().x * blob.getVelocity().x || target.getPosition().x * (target.getVelocity().x * 2) < blob.getPosition().x * blob.getVelocity().x)
			{
				if (targetDistance < 90.0f && ((blob.getVelocity().x > 1.5f && target.getPosition().x > blob.getPosition().x) || (blob.getVelocity().x < -1.5f && target.getPosition().x < blob.getPosition().x)))
				{
					Runaway(blob, target);
					blob.setAimPos(targetPos);

					blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 1);

					if (emote)
					{
						set_emote(blob, Emotes::mad, 16);
					}
				}
				else
				{
					Runaway(blob, target);
					blob.setAimPos(targetPos);

					if (emote)
					{
						set_emote(blob, Emotes::attn, 16);
					}
				}

				if (XORRandom(6) == 0 && targetDistance < 17.0f && blob.get_s16("shieldbash_confidence") < 5)
				{
					blob.setKeyPressed(key_action1, true);
				}

				if (!blob.isOnGround())
				{
					blob.setKeyPressed(key_up, true);
				}
			}
			else
			{
				blob.setKeyPressed(key_action1, false);
				blob.setKeyPressed(key_action2, true);
			}
		}
	}
	else
	{
		// start attack
		if ((getGameTime() - blob.get_u32("attack time")) > 10)
		{
			blob.set_u32("attack time", gametime);
		}
	}

	if (targetDistance < 18.0f + blob.get_u8("myKey")/20 && target.getName() != "knight")
	{
		if (gametime % 3 == 0)
		{
			blob.setKeyPressed(key_action1, true);
		}
		else
		{
			blob.setKeyPressed(key_action1, false);
		}
	}

	// Jab spam a stunned target. 
	if (targetDistance < 18.0f - blob.get_u8("myKey")/25 && ((getKnockedRemaining(target) > 10 && blob.getInitialHealth() != blob.getHealth()) || (getKnockedRemaining(target) > 6 && blob.getInitialHealth() == blob.getHealth())))
	{
		if (emote)
		{
			set_emote(blob, Emotes::skull, 16);
		}

		if (gametime % 2 == 0)
		{
			blob.setKeyPressed(key_action1, true);
		}
		else
		{
			blob.setKeyPressed(key_action1, false);
			blob.setKeyPressed(key_up, true);
		}
	}
	//Jab spam an enemy that missed a shield bash/stomp.
	else if (targetDistance < 8.5f && (!target.isKeyPressed(key_action1)))
	{
		if (gametime % 2 == 0)
		{
			blob.setKeyPressed(key_action1, true);
		}
		else
		{
			blob.setKeyPressed(key_action1, false);
			blob.setKeyPressed(key_up, true);
		}

		if (target.isKeyPressed(key_action2) && target.getName() == "knight")
		{
			blob.setAimPos(target.getAimPos());
		}
		else
		{
			if (emote)
			{
				set_emote(blob, Emotes::skull, 16);
			}
		}
	}
	// Shield crouch to avoid target's shield bash stomp from above.
	else if (targetDistance < 61.0f && target.getVelocity().y > 3.5f && target.getAimPos().y > target.getPosition().y && target.getPosition().y < blob.getPosition().y && !isKnocked(target) && target.isKeyPressed(key_action2))
	{
		if (emote)
		{
			set_emote(blob, Emotes::laugh, 16);
		}

		blob.setKeyPressed(key_down, true);
		blob.setKeyPressed(key_action2, true);

		blob.setKeyPressed(key_up, false);
		blob.setKeyPressed(key_left, false);
		blob.setKeyPressed(key_right, false);
	}
	// Shield crouch to avoid target's shield bash rush from the side.
	else if (targetDistance < 41.0f && !isKnocked(target) && target.isKeyPressed(key_action2) && (blob.isOnGround() || blob.wasOnGround()) && !blob.isInWater())
	{
		// Enemy is facing the right direction to bash us.
		if (target.getAimPos().x > target.getPosition().x && blob.getPosition().x > target.getPosition().x || target.getAimPos().x < target.getPosition().x && blob.getPosition().x < target.getPosition().x)
		{
			blob.setKeyPressed(key_down, true);
			blob.setKeyPressed(key_action2, true);

			blob.setKeyPressed(key_up, false);
			blob.setKeyPressed(key_left, false);
			blob.setKeyPressed(key_right, false);
		}
	}
	// Shielding time.
	else if (shieldTime)
	{
		blob.setKeyPressed(key_action2, true);
	}
	// Slashing logic.
	else if ((targetDistance > 70.0f && targetDistance < 160.0f && blob.get_s16("target_slashtime") > 41) || targetDistance < 105.0f) // hold and release when timed
	{
		if ((targetDistance < 51.0f && blob.get_s16("slashtime") >= 41) || (targetDistance < 26.0f && blob.get_s16("slashtime") >= 15 && !target.isKeyPressed(key_action2))) // && !target.isKeyPressed(key_action1)
		{
			// Release, Jab, Slash, 2xSlash
			blob.setKeyPressed(key_action1, false);
			// Jump for velocity
			blob.setKeyPressed(key_up, true);

			if (emote)
			{
				set_emote(blob, Emotes::knight, 16);
			}
		}
		else
		{
			if (!target.isKeyPressed(key_action1) || target.getName() != "knight")
			{
				blob.setKeyPressed(key_action2, false);
			}

			// Hold
			if (targetDistance < 47.0f && blob.get_s16("slashtime") > 16 && target.isKeyPressed(key_action1) && blob.get_s16("target_slashtime") < 14)
			{
				blob.setKeyPressed(key_action1, false);
			}
			else
			{
				blob.setKeyPressed(key_action1, true);
			}
		}
	}

	// If both are charging slash, release asap if in range.
	if (targetDistance < 29.0f + blob.get_u8("myKey")/15 && blob.get_s16("target_slashtime") > 15 && blob.get_s16("slashtime") > 15)
	{
		blob.setKeyPressed(key_action1, false);
		Chase(blob, target);
	}
	else if (targetDistance < 36.0f && blob.get_s16("target_slashtime") > 15 && blob.get_s16("slashtime") > 15)
	{
		Chase(blob, target);
	}

	

	// If in a stalemate, try to shield bash.
	if (targetDistance < 56.0f && target.isKeyPressed(key_action2) && !target.isKeyPressed(key_action1) && Maths::Abs(target.getVelocity().x) < 0.4f && Maths::Abs(blob.getVelocity().x) < 0.8f && blob.isKeyPressed(key_action2))
	{
		if (target.getName() != "knight")
		{
			return;
		}

		if (blob.get_s16("shieldbash_confidence") <= 28 && XORRandom(2) == 0)
		{
			if (isFriendAheadOfMe(blob, target))
			{
				blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 9);
				Chase(blob, target);
			}
			else
			{
				blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 8);
			}
		}
	}

	// Shield bash logic.
	if (blob.get_s16("shieldbash_confidence") > 26)
	{
		if (blob.get_s16("shieldbash_confidence") > 46)
		{
			if (emote)
			{
				if (gametime % 2 == 0)
				{
					set_emote(blob, Emotes::attn, 8);
				}
				else
				{
					set_emote(blob, Emotes::finger, 8);
				}
			}

			// Ram.
			blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 2);

			blob.setKeyPressed(key_action1, false);
			blob.setKeyPressed(key_action2, false);

			blob.setKeyPressed(key_left, false);
			blob.setKeyPressed(key_right, false);
			blob.setKeyPressed(key_down, false);

			if (target.getPosition().x < blob.getPosition().x)
			{
				blob.setKeyPressed(key_left, true);
			}
			else
			{
				blob.setKeyPressed(key_right, true);
			}

			ShieldSlide(blob, target);

			blob.setKeyPressed(key_up, true);
		}
		else
		{
			// Backup.
			blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 2);

			blob.setKeyPressed(key_action1, false);
			blob.setKeyPressed(key_action2, false);

			blob.setKeyPressed(key_up, false);
			blob.setKeyPressed(key_left, false);
			blob.setKeyPressed(key_right, false);
			blob.setKeyPressed(key_down, false);

			if (target.getPosition().x > blob.getPosition().x)
			{
				blob.setKeyPressed(key_left, true);
			}
			else
			{
				blob.setKeyPressed(key_right, true);
			}

			ShieldSlide(blob, target);
		}
 
		// End bash
		if (isKnocked(target) || (target.isKeyPressed(key_down) && XORRandom(3) == 0) || targetDistance > 170.0f || (blob.isOnWall() && blob.get_s16("shieldbash_confidence") < 23) || target.getPosition().y + 9.0f < blob.getPosition().y)
		{
			blob.set_s16("shieldbash_confidence", 0);
		}

		if (target.getPosition().y - 30.0f > blob.getPosition().y)
		{
			blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 1);
		}

		if (blob.get_s16("shieldbash_confidence") > 110)
		{
			blob.set_s16("shieldbash_confidence", 0);
		}
	}

	// Don't do a stupid jab. ////Big Improvement!
	if (blob.get_s16("slashtime") < 15 && target.isKeyPressed(key_action2) && !blob.isKeyPressed(key_action1) && blob.wasKeyPressed(key_action1))
	{
		blob.setKeyPressed(key_action1, true);
	}

	// Don't stun myself. //// Big Improvement!
	if (blob.get_s16("slashtime") > 62)
	{
		if (emote)
		{
			set_emote(blob, Emotes::sweat, 8);
		}

		blob.setKeyPressed(key_action1, false);
	}



	// unpredictable movement
	if (gametime % blob.get_u8("myKey") == 0 && XORRandom(2) == 0)
	{
		print('asddddd!!!!!!!!!!');
		if (blob.get_u8("moveover") == 0)
		{
			blob.set_u8("moveover", XORRandom(2)+1); // rand dir
		}
		else
		{
			blob.set_u8("moveover", 0); // stop move dir
		}
	}

	//secondary random

	if (blob.get_u8("moveover") != 0)
	{
		if (emote)
		{
			set_emote(blob, Emotes::attn, 16);
		}

		if (XORRandom(100) == 0)
		{
			blob.set_u8("moveover", 0); //end
		}

		blob.setKeyPressed(key_left, false);
		blob.setKeyPressed(key_right, false);

		if (blob.get_u8("moveover") == 1) // 1 == right
		{
			blob.setKeyPressed(key_right, true);
		}
		else // 0 == left
		{		
			blob.setKeyPressed(key_left, true);
		}

		// hardcode rand
		if (blob.get_u8("myKey") > 160)
		{
			blob.setKeyPressed(key_up, true);
		}
		if (blob.get_u8("myKey") < 50)
		{
			blob.setKeyPressed(key_up, false);
		}
		if (blob.get_u8("myKey") > 220)
		{
			blob.setKeyPressed(key_down, true);
		}
	}
}

void FindHeal(CBrain@ this, CBlob @check, CBlob @target)
{
	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();

	if (check is null)
	{
		return;
	}

	Vec2f healpos = check.getPosition();

	Vec2f targetVector = healpos - blob.getPosition();
	f32 targetDistance = targetVector.Length();

	// face the healing
	blob.setAimPos(healpos);

	u8 strategy = blob.get_u8("strategy");

	// Pick it up pog
	
	if (check.canBePickedUp(blob) && (healpos - mypos).getLength() < 36.0f)
	{
		check.setPosition(mypos);
		blob.server_Pickup(@check);

		@check = null;

		strategy = Strategy::attacking;

		AttackBlob(blob, target);

		return;
	}

	const f32 horiz_distance = Maths::Abs(healpos.x - mypos.x);

	if (horiz_distance > blob.getRadius() * 0.75f)
	{
		if (healpos.x < mypos.x)
		{
			blob.setKeyPressed(key_left, true);
		}
		else
		{
			blob.setKeyPressed(key_right, true);
		}

		if (healpos.y + getMap().tilesize * 0.7f < mypos.y && check.isOnGround())  	 // dont hop with me
		{
			blob.setKeyPressed(key_up, true);
		}
	}

	// jump over small blocks

	JumpOverObstacles(blob);
}