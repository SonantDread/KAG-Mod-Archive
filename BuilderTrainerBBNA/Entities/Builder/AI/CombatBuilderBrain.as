// Combat builder brain

// Script by Blav

#define SERVER_ONLY

#include "/Entities/Common/Emotes/EmotesCommon.as"
#include "CombatBuilderCommon.as"

void onInit(CBrain@ this)
{
	CBlob @blob = this.getBlob();

	blob.set_bool("justgo", false);
	blob.set_Vec2f("target spot", Vec2f_zero);
	blob.set_u8("strategy", Strategy::idle); // spawn idle

	this.getCurrentScript().removeIfTag = "dead";   //won't be removed if not bot cause it isnt ran
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();
	
	u8 strategy = blob.get_u8("strategy");
	
	if (getAttacker(this, blob) != null)
	{
		SetStrategy(blob, Strategy::attack_blob);
	}
	else
	{
		SetStrategy(blob, Strategy::idle);
	}

	// Swim up / dont drown
	if (blob.isInWater())
	{
		blob.setKeyPressed(key_up, true);
	}

	// Idle dance
	if (strategy == Strategy::idle)
	{
		if (getGameTime() % 10 == 0)
		{
			blob.setAimPos(blob.getPosition() + Vec2f(20.0f-XORRandom(40), 20.0f-XORRandom(40)));

			blob.setKeyPressed(key_down, true);
		}
		return;
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

void AttackBlob(CBrain@ this, CBlob @target)
{
	// Attack a blob

	CBlob @blob = this.getBlob();
	Vec2f mypos = blob.getPosition();
	Vec2f targetpos = target.getPosition();
	Vec2f targetVector = targetpos - blob.getPosition();
	f32 targetDistance = targetVector.Length();

	// face the enemy
	blob.setAimPos(targetpos);

	// check if we have a clear area to the target
	bool justGo = false;

	if (targetDistance < 90.0f)
	{
		Vec2f col;
		if (!getMap().rayCastSolid(mypos, targetpos, col))
		{
			justGo = true;
		}
		

		if (getMap().rayCastSolid(mypos + Vec2f(0.0f, -3.0f), targetpos, col) || getMap().rayCastSolid(mypos + Vec2f(0.0f, 3.0f), targetpos, col))
		{
			CBlob @carried = blob.getCarriedBlob();
			if (carried !is null)
  			{
  				if (carried.getName() == "drill")
  				{
  					u8 heat = carried.get_u8("drill heat");

  					if (heat < 50)
	  				{
	  					if (getGameTime() % 8 == 0)
	  						blob.setKeyPressed(key_action1, true);
	  				}

	  				if (getGameTime() % 8 != 0)
	  				{
	  					blob.setKeyPressed(key_action2, true);

  						if (blob.isKeyPressed(key_right))
  						{
  							blob.setAimPos(mypos + Vec2f(8.0f, 4.0f - XORRandom(8)));

  							if (blob.isKeyPressed(key_up))
	  						{
	  							blob.setAimPos(mypos + Vec2f(8.0f, -8.0f));
	  						}
	  						if (blob.isKeyPressed(key_down))
	  						{
	  							blob.setAimPos(mypos + Vec2f(8.0f, 8.0f));
	  						}
  						}
  						if (blob.isKeyPressed(key_left))
  						{
  							blob.setAimPos(mypos + Vec2f(-8.0f, 4.0f - XORRandom(8)));

  							if (blob.isKeyPressed(key_up))
	  						{
	  							blob.setAimPos(mypos + Vec2f(-8.0f, -8.0f));
	  						}
	  						if (blob.isKeyPressed(key_down))
	  						{
	  							blob.setAimPos(mypos + Vec2f(-8.0f, 8.0f));
	  						}
  						}
	  				}
  				}
  			}
		}
	}

	CBlob @carried = blob.getCarriedBlob();
    if (carried !is null)
    {
    	// Drill
        if (carried.getName() == "drill") 
        {
            if (targetDistance < 26.0f)
			{
				//blob.setAimPos(targetpos);
				blob.setKeyPressed(key_action1, true);
			}

			// Reverse stepping
			if (targetDistance < 25.0f)
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
				justGo = true;
			}
        }
    }
    else
    {
    	// Pickaxe
    	if (targetDistance < 21.0f)
		{
			//blob.setAimPos(targetpos);
			blob.setKeyPressed(key_action2, true);
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
				if (XORRandom(100) == 0)
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