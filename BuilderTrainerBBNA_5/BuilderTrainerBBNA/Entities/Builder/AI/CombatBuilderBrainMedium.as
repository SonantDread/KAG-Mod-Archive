// Combat builder brain

// Script by Blav

#define SERVER_ONLY

#include "/Entities/Common/Emotes/EmotesCommon.as"
#include "CombatBuilderCommon.as"

void onInit(CBrain@ this)
{
	CBlob @blob = this.getBlob();

	if (blob.getTeamNum() == 1)
	{
		return;
	}

	blob.set_bool("justgo", false);
	blob.set_Vec2f("target spot", Vec2f_zero);
	blob.set_u8("strategy", Strategy::idle); // spawn idle
	blob.set_u8("attackType", 1);
	blob.set_u8("myKey", XORRandom(250)+1); // 1-250

	this.getCurrentScript().removeIfTag = "dead";   //won't be removed if not bot cause it isnt ran
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	if (blob !is null && blob.getTeamNum() == 1)
	{
		return;
	}
	CBlob @target = this.getTarget();

	CBlob @check;

	u8 strategy = blob.get_u8("strategy");
	
	if (getAttacker(this, blob) != null)
	{
		// Attack target
		SetStrategy(blob, Strategy::attack_blob);		
	}
	else
	{
		// Idle
		SetStrategy(blob, Strategy::idle);
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
					else if (dist.getLength() > 40.0f && disttoenemy.getLength() < 32.0f)
					{
						healing.removeAt(i);
					}
				}
			}

			if (healing.size() > 0)
			{
				SetStrategy(blob, Strategy::find_healing);
			}
		}
	}

	CBlob @carried = blob.getCarriedBlob();
	if (carried is null)
	{
		if (!blob.hasBlob("drill", 1) && target !is null)
		{
			Vec2f mypos = blob.getPosition();
			Vec2f targetpos = target.getPosition();

			CBlob@[] drills;
			getBlobsByName("drill", @drills);
			for( int i = 0; i < drills.size(); i++ )
			{
				@check = drills[i];
				Vec2f dist = check.getPosition() - mypos;
				Vec2f disttoenemy = check.getPosition() - targetpos;
				if (check.isInInventory() || check.isAttached())
				{
					drills.removeAt(i);
				}
				else
				{
					if (dist.getLength() > 120.0f)
					{
						drills.removeAt(i);
					}
					else if (dist.getLength() > 50.0f && disttoenemy.getLength() < 8.0f)
					{
						drills.removeAt(i);
					}
				}
			}

			if (drills.size() > 0)
			{
				SetStrategy(blob, Strategy::find_drill);
			}
		}
		else
		{
			// Take out of inventory
		}
	}

	// Swim up / dont drown
	if (blob.isInWater())
	{
		blob.setKeyPressed(key_up, true);
	}

	// Idle dance
	if (strategy == Strategy::idle && getMap().getTimeSinceStart() > 5.0f && blob.getInitialHealth() == blob.getHealth())
	{
		if (getGameTime() % 6 == 0)
		{
			blob.setAimPos(blob.getPosition() + Vec2f(20.0f-XORRandom(40), 20.0f-XORRandom(40)));

			blob.setKeyPressed(key_down, true);
		}
		if (blob.get_u8("myKey") > 140)
		{
			if (XORRandom(10) == 0)
			{
				if (getGameTime() % 2 == 0)
					set_emote(blob, Emotes::thumbsdown);
				else
					set_emote(blob, Emotes::frown);
			}
		}
		else if (blob.get_u8("myKey") > 30)
		{
			if (XORRandom(12) == 0)
			{
				if (getGameTime() % 2 == 0)
					set_emote(blob, Emotes::laugh);
				else
					set_emote(blob, Emotes::troll);
			}
		}
		else
		{
			set_emote(blob, Emotes::smile);
		}
		
		return;
	}

	// Eat if lost hp
	if (blob.getInitialHealth() > blob.getHealth() && getGameTime() % 10 == 0)
	{
		blob.setKeyPressed(key_eat, true);
	}

	// Find some healing
	if (strategy == Strategy::find_healing)
	{
		if (check !is null && (target.getPosition() - blob.getPosition()).getLength() > 36.0f)
		{
			FindHeal(this, @check);
		}
		else
		{
			SetStrategy(blob, Strategy::idle);
		}
	}

	// Find a drill to pickup
	if (strategy == Strategy::find_drill)
	{
		if (check !is null)
		{
			if (target !is null)
			{
				FindDrill(this, @check, @target);
			}
		}
		else
		{
			SetStrategy(blob, Strategy::idle);
		}
	}

	// Attack enemy
	if (strategy == Strategy::attack_blob)
	{
		CBlob@ attacker = getAttacker(this, blob);
		if (attacker !is null)
		{
			//set brain param
			this.SetTarget(attacker);
			AttackBlob(this, attacker);
		}
	}
	
	// Stop running away
	if (strategy == Strategy::runaway)
	{
		if (!Runaway(this, blob, this.getTarget()))
		{
			blob.set_u8("strategy", Strategy::idle);
			this.SetTarget(null);
		}
	}
}

void SetStrategy(CBlob@ blob, const u8 strategy)
{
	blob.set_u8("strategy", strategy);
	blob.Sync("strategy", true);
}

f32 getSeekTeamPriority(CBlob @this, CBlob @other)
{
	const string othername = other.getName();
	if (othername == "factory")
	{
		//if (!isRoomFullOfMigrants(other))
			return 0.0f;
	}
	else
	{
		//if (other.hasTag("migrant room"))
		//	return 1.0f;
		if (other.getPlayer() !is null)
			return 10.0f;
	}
	return 100.9f;
}

CBlob@ getNewTarget(CBrain@ this, CBlob @blob)
{
	const u8 strategy = blob.get_u8("strategy");
	Vec2f pos = blob.getPosition();

	CBlob@[] potentials;
	CBlob@[] blobsInRadius;
	if (blob.getMap().getBlobsInRadius(pos, SEEK_RANGE, @blobsInRadius))
	{
		if (strategy == Strategy::idle)
		{
			// find players or campfires

			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b !is blob && b.getTeamNum() == blob.getTeamNum() && !b.isInFlames() && !b.isInWater())
				{
					// omit full beds or when bot
					const string name = b.getName();
					if (name == "dorm" && blob.getPlayer() !is null)
					{
						continue;
					}

					potentials.push_back(b);
				}
			}
		}

		// pick closest/best

		if (potentials.length > 0)
		{
			while (potentials.size() > 0)
			{
				f32 closestDist = 999999.9f;
				uint closestIndex = 999;

				for (uint i = 0; i < potentials.length; i++)
				{
					CBlob @b = potentials[i];
					Vec2f bpos = b.getPosition();
					f32 distToPlayer = (bpos - pos).getLength();
					f32 dist = distToPlayer * getSeekTeamPriority(blob, b);
					if (distToPlayer > 0.0f && dist < closestDist)
					{
						closestDist = dist;
						closestIndex = i;
					}
				}
				if (closestIndex >= 999)
				{
					break;
				}

				return potentials[closestIndex];
			}
		}
	}
	return null;
}

CBlob@ getAttacker(CBrain@ this, CBlob @blob)
{
	Vec2f pos = blob.getPosition();

	CBlob@[] potentials;
	CBlob@[] blobsInRadius;
	CMap@ map = blob.getMap();
	if (map.getBlobsInRadius(pos, ENEMY_RANGE, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is blob
			        && (((b.getTeamNum() != blob.getTeamNum() && b.hasTag("player") && !b.hasTag("migrant") && !b.hasTag("dead")) || (b.isInFlames() || b.hasTag("animal"))))) 	// runaway from enemies and from burning stuff
			{
				potentials.push_back(b);
			}
		}
	}

	// pick closest/best

	if (potentials.length > 0)
	{
		CBlob@[] closest;
		while (potentials.size() > 0)
		{
			f32 closestDist = 999999.9f;
			uint closestIndex = 999;

			for (uint i = 0; i < potentials.length; i++)
			{
				CBlob @b = potentials[i];
				Vec2f bpos = b.getPosition();
				f32 dist = (bpos - pos).getLength();
				if (dist < closestDist)
				{
					closestDist = dist;
					closestIndex = i;
				}
			}
			if (closestIndex >= 999)
			{
				break;
			}
			return potentials[closestIndex];
		}
	}

	return null;
}

void Repath(CBrain@ this)
{
	this.SetPathTo(this.getTarget().getPosition(), false);
}

void FindHeal(CBrain@ this, CBlob @check)
{
	// Attack a blob

	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f healpos = check.getPosition();

	// face the healing
	blob.setAimPos(healpos);

	// check if we have a clear area to the target
	bool justGo = false;

	Vec2f col;
	if (!getMap().rayCastSolid(mypos, healpos, col))
	{
		justGo = true;
	}

	// repath if no clear path after going at it
	if (!justGo && blob.get_bool("justgo"))
	{
		Repath(this);
	}
	else // occasionally repath when target is off of our spot
		if (XORRandom(50) == 0 && (blob.get_Vec2f("target spot") - healpos).getLength() > 50.0f)
		{
			Repath(this);
		}

	blob.set_bool("justgo", justGo);

	const bool stuck = this.getState() == CBrain::stuck;

	if (justGo)
	{
		if (!stuck || XORRandom(100) < 10)
		{
			JustGo(this, check);
			if (!stuck)
			{
				blob.set_u8("emote", Emotes::off);
			}
		}
		else
			justGo = false;
	}

	// pathfinding
	if (!justGo)
	{
		switch (this.getState())
		{
			case CBrain::idle:
				Repath(this);
				break;

			case CBrain::searching:
				break;

			case CBrain::has_path:
				this.SetSuggestedKeys();  // set walk keys here
				break;

			case CBrain::stuck:
				Repath(this);
				if (XORRandom(70) == 0)
				{
					set_emote(blob, Emotes::frown);
				}
				break;

			case CBrain::wrong_path:
				Repath(this);
				break;
		}
	}

	// jump over small blocks

	JumpOverObstacles(blob);
}

void FindDrill(CBrain@ this, CBlob @check, CBlob @target)
{
	// Attack a blob

	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f drillpos = check.getPosition();

	Vec2f targetpos = target.getPosition();
	Vec2f targetVector = targetpos - blob.getPosition();
	f32 targetDistance = targetVector.Length();

	// face the healing
	blob.setAimPos(drillpos);

	// Pick it up pog
	if (check.canBePickedUp(blob) && (drillpos - mypos).getLength() < 32.0f && getGameTime() % 5 == 0)
	{
		u8 heat = check.get_u8("drill heat");
		if (heat < 114)
		{
			if (check !is null)
			{
				check.setPosition(blob.getPosition());
				blob.server_Pickup(@check);
			}

			SetStrategy(blob, Strategy::attack_blob);

			blob.setKeyPressed(key_left, true);
			blob.setAimPos(target.getPosition());

			// Attack enemy (try to attack again)
			CBlob@ attacker = getAttacker(this, blob);
			if (attacker !is null)
			{
				//set brain param
				this.SetTarget(attacker);
				AttackBlob(this, attacker);
			}

			return;
		}
	}

	// check if we have a clear area to the target
	bool justGo = false;

	Vec2f col;
	if (!getMap().rayCastSolid(mypos, drillpos, col))
	{
		justGo = true;
	}

	// repath if no clear path after going at it
	if (!justGo && blob.get_bool("justgo"))
	{
		Repath(this);
	}
	else // occasionally repath when target is off of our spot
		if (XORRandom(50) == 0 && (blob.get_Vec2f("target spot") - drillpos).getLength() > 50.0f)
		{
			Repath(this);
		}

	blob.set_bool("justgo", justGo);

	const bool stuck = this.getState() == CBrain::stuck;

	if (justGo)
	{
		if (!stuck || XORRandom(100) < 10)
		{
			JustGo(this, check);
			if (!stuck)
			{
				blob.set_u8("emote", Emotes::off);
			}
		}
		else
			justGo = false;
	}

	// pathfinding
	if (!justGo)
	{
		switch (this.getState())
		{
			case CBrain::idle:
				Repath(this);
				break;

			case CBrain::searching:
				break;

			case CBrain::has_path:
				this.SetSuggestedKeys();  // set walk keys here
				break;

			case CBrain::stuck:
				Repath(this);
				if (XORRandom(70) == 0)
				{
					set_emote(blob, Emotes::frown);
				}
				break;

			case CBrain::wrong_path:
				Repath(this);
				break;
		}
	}

	// jump over small blocks

	JumpOverObstacles(blob);
}

void AttackBlob(CBrain@ this, CBlob @target)
{
	// Attack a blob

	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f targetpos = target.getPosition();
	Vec2f targetVector = targetpos - blob.getPosition();
	f32 targetDistance = targetVector.Length();

	u8 atk_type = blob.get_u8("attackType");

	// face the enemy
	blob.setAimPos(targetpos);

	// check if we have a clear area to the target
	bool justGo = false;

	Vec2f col;
	if (!getMap().rayCastSolid(mypos, targetpos, col))
	{
		justGo = true;
	}
	
	if (targetDistance > 48.0f)
	{
		CBlob @carried = blob.getCarriedBlob();
		if (carried !is null)
		{
			if (carried.getName() == "drill")
			{
				u8 heat = carried.get_u8("drill heat");

				if (heat < 50 && targetDistance > 56.0f)
				{
					f32 distance;
					if (!isVisible(blob, target, distance))
					{
						CBrain@ brain = blob.getBrain();

						if ((blob.getPosition() - brain.getNextPathPosition()).getLength() < 15.0f)
						{
							if (brain.getState() == CBrain::stuck || brain.getState() == CBrain::wrong_path || blob.getVelocity().x + blob.getVelocity().y < 0.05f)
							{
								if (brain.getHighPathSize() > 0 && getGameTime() % 3 == 0)
								{
									blob.setAimPos(brain.getNextPathPosition() + Vec2f(8.0f - XORRandom(16), 8.0f - XORRandom(16)));
									blob.setKeyPressed(key_action1, true);
								}
							}
						}	
					}
				}
			}
		}
	}
	else
	{
		CBlob @carried = blob.getCarriedBlob();
		if (carried !is null)
	    {
	    	// Drill
	        if (carried.getName() == "drill") 
	        {
	        	u8 last_drill_prop = carried.get_u32("drill last active");

	            if (targetDistance < XORRandom(7) + 23.0f)   // && !(getGameTime() < last_drill_prop + 8)
				{
					blob.setKeyPressed(key_action1, true);
				}

				switch (atk_type)
				{
				case 1: // Reverse stepping
				{
					if (targetDistance < 20.0f)
					{
						justGo = false;

						if (targetpos.x < mypos.x)
						{
							blob.setKeyPressed(key_right, true);
						}
						else
						{
							blob.setKeyPressed(key_left, true);
						}
					}
					else if (targetDistance < 90.0f)
					{
						//justGo = true;

						if (blob.isOnGround() && !blob.isOnLadder())
						{
							blob.setKeyPressed(key_up, true);
						}
					}

					break;
				}
				}
	        }
	    }
	    else
	    {
	    	// Pickaxe
	    	if (targetDistance < 21.0f)
			{
				//blob.setKeyPressed(key_action2, true);
			}
	    }
	}

    
	// repath if no clear path after going at it
	if (!justGo && blob.get_bool("justgo"))
	{
		Repath(this);
	}
	else // occasionally repath when target is off of our spot
		if (XORRandom(50) == 0 && (blob.get_Vec2f("target spot") - targetpos).getLength() > 50.0f)
		{
			Repath(this);
		}

	blob.set_bool("justgo", justGo);

	const bool stuck = this.getState() == CBrain::stuck;

	if (justGo)
	{
		if (!stuck || XORRandom(100) < 10)
		{
			JustGo(this, target);
			if (!stuck)
			{
				blob.set_u8("emote", Emotes::off);
			}
		}
		else
			justGo = false;

		/*
		CBlob @carried = blob.getCarriedBlob();
		if (carried !is null)
		{
			if (carried.getName() == "drill")
			{
				u8 heat = carried.get_u8("drill heat");

				CBlob @targetcarried = target.getCarriedBlob();
				if (targetcarried !is null)
				{
					if (heat < 84 && targetcarried.getName() == "drill")
					{
						// Don't rush until drill is heated
						justGo = false;
					}
				}
			}
		}
		*/
	}

	// pathfinding
	if (!justGo)
	{
		switch (this.getState())
		{
			case CBrain::idle:
				Repath(this);
				break;

			case CBrain::searching:
				break;

			case CBrain::has_path:
				this.SetSuggestedKeys();  // set walk keys here
				break;

			case CBrain::stuck:
				Repath(this);
				if (XORRandom(70) == 0)
				{
					set_emote(blob, Emotes::frown);
					f32 dist = Maths::Abs(targetpos.x - mypos.x);
					if (dist > 20.0f)
					{
						if (dist < 50.0f)
							set_emote(blob, targetpos.y > mypos.y ? Emotes::down : Emotes::up);
						else
							set_emote(blob, targetpos.x > mypos.x ? Emotes::right : Emotes::left);
					}
				}
				break;

			case CBrain::wrong_path:
				Repath(this);
				if (XORRandom(100) == 0)
				{
					if (Maths::Abs(targetpos.x - mypos.x) < 50.0f)
						set_emote(blob, targetpos.y > mypos.y ? Emotes::down : Emotes::up);
					else
						set_emote(blob, targetpos.x > mypos.x ? Emotes::right : Emotes::left);
				}
				break;
		}
	}

	// jump over small blocks

	JumpOverObstacles(blob);
}

void GoToBlob(CBrain@ this, CBlob @target)
{
	// Walk to a blob

	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f targetpos = target.getPosition();
	Vec2f targetVector = targetpos - blob.getPosition();
	f32 targetDistance = targetVector.Length();
	// check if we have a clear area to the target
	bool justGo = false;

	if (targetDistance < 80.0f)
	{
		Vec2f col;
		if (!getMap().rayCastSolid(mypos, targetpos, col))
		{
			justGo = true;
		}
	}

	// repath if no clear path after going at it
	if (!justGo && blob.get_bool("justgo"))
	{
		Repath(this);
	}
	else // occasionally repath when target is off of our spot
		if (XORRandom(50) == 0 && (blob.get_Vec2f("target spot") - targetpos).getLength() > 50.0f)
		{
			Repath(this);
		}

	blob.set_bool("justgo", justGo);

	const bool stuck = this.getState() == CBrain::stuck;

	if (justGo)
	{
		if (!stuck || XORRandom(100) < 10)
		{
			JustGo(this, target);
			if (!stuck)
			{
				blob.set_u8("emote", Emotes::off);
			}
		}
		else
			justGo = false;
	}

	// pathfinding
	if (!justGo)
	{
		switch (this.getState())
		{
			case CBrain::idle:
				Repath(this);
				break;

			case CBrain::searching:
				break;

			case CBrain::has_path:
				this.SetSuggestedKeys();  // set walk keys here
				break;

			case CBrain::stuck:
				Repath(this);
				break;

			case CBrain::wrong_path:
				Repath(this);
				break;
		}
	}

	// face the blob
	blob.setAimPos(targetpos);

	// jump over small blocks

	JumpOverObstacles(blob);
}

void JumpOverObstacles(CBlob@ blob)
{
	Vec2f pos = blob.getPosition();
	if (!blob.isOnLadder())
		if ((blob.isKeyPressed(key_right) && (getMap().isTileSolid(pos + Vec2f(1.3f * blob.getRadius(), blob.getRadius()) * 1.0f) || blob.getShape().vellen < 0.1f)) ||
		        (blob.isKeyPressed(key_left)  && (getMap().isTileSolid(pos + Vec2f(-1.3f * blob.getRadius(), blob.getRadius()) * 1.0f) || blob.getShape().vellen < 0.1f)))
		{
			blob.setKeyPressed(key_up, true);
		}
}

bool JustGo(CBrain@ this, CBlob@ target)
{
	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f point = target.getPosition();
	const f32 horiz_distance = Maths::Abs(point.x - mypos.x);

	if (horiz_distance > blob.getRadius() * 0.75f)
	{
		if (point.x < mypos.x)
		{
			blob.setKeyPressed(key_left, true);
		}
		else
		{
			blob.setKeyPressed(key_right, true);
		}

		if (point.y + getMap().tilesize * 0.7f < mypos.y && target.isOnGround())  	 // dont hop with me
		{
			blob.setKeyPressed(key_up, true);
		}

		if (blob.isOnLadder() && point.y > mypos.y)
		{
			blob.setKeyPressed(key_down, true);
		}

		return true;
	}

	return false;
}

bool Runaway(CBrain@ this, CBlob@ blob, CBlob@ attacker)
{
	if (attacker is null)
		return false;

	Vec2f mypos = blob.getPosition();
	Vec2f hispos = attacker.getPosition();
	const f32 horiz_distance = Maths::Abs(hispos.x - mypos.x);

	if (hispos.x > mypos.x)
	{
		blob.setKeyPressed(key_left, true);
		blob.setAimPos(mypos + Vec2f(-10.0f, 0.0f));
	}
	else
	{
		blob.setKeyPressed(key_right, true);
		blob.setAimPos(mypos + Vec2f(10.0f, 0.0f));
	}

	if (hispos.y - getMap().tilesize > mypos.y)
	{
		blob.setKeyPressed(key_up, true);
	}

	JumpOverObstacles(blob);

	// end

	//out of sight?
	if ((mypos - hispos).getLength() > 200.0f)
	{
		return false;
	}

	return true;
}

bool isVisible(CBlob@ blob, CBlob@ target, f32 &out distance)
{
	Vec2f col;
	bool visible = !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
	visible      = !getMap().rayCastSolid(blob.getPosition() + Vec2f(0.0f, 5.0f), target.getPosition(), col);  // Get an even better view - optional
	distance = (blob.getPosition() - col).getLength();
	return visible;
}

bool isFriendAheadOfMe(CBlob @blob, CBlob @target, const f32 spread = 70.0f)
{
	// optimization
	if ((getGameTime() + blob.getNetworkID()) % 10 > 0 && blob.exists("friend ahead of me"))
	{
		return blob.get_bool("friend ahead of me");
	}

	CBlob@[] players;
	getBlobsByTag("player", @players);
	Vec2f pos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		Vec2f pos2 = potential.getPosition();
		if (potential !is blob && blob.getTeamNum() == potential.getTeamNum()
		        && (pos2 - pos).getLength() < spread
		        && (blob.isFacingLeft() && pos.x > pos2.x && pos2.x > targetPos.x) || (!blob.isFacingLeft() && pos.x < pos2.x && pos2.x < targetPos.x)
		        && !potential.hasTag("dead") && !potential.hasTag("migrant")
		   )
		{
			blob.set_bool("friend ahead of me", true);
			return true;
		}
	}
	blob.set_bool("friend ahead of me", false);
	return false;
}