// Script by Yeti5000707 (Blav)
// Good Bots

#include "/Entities/Common/Emotes/EmotesCommon.as"

namespace Strategy
{
	enum strategy_type
	{
		idle = 0,
		chasing,
		attacking,
		retreating,
		find_healing
	}
}

void InitBrain(CBrain@ this)
{
	CBlob @blob = this.getBlob();
	blob.set_Vec2f("last pathing pos", Vec2f_zero);
	blob.set_u8("strategy", Strategy::idle);
	this.getCurrentScript().removeIfTag = "dead";   //won't be removed if not bot cause it isnt run

	if (!blob.exists("difficulty"))
	{
		blob.set_s32("difficulty", 35); // max
	}
}

CBlob@ getNewTarget(CBrain@ this, CBlob @blob, const bool seeThroughWalls = false, const bool seeBehindBack = false)
{
	CBlob@[] possible_targets;
	getBlobsByTag("player", @possible_targets);
	
	for (int i = 0; i < possible_targets.size(); i++)
	{
		CBlob@ possible = possible_targets[i];
		Vec2f pos2 = possible.getPosition();
		const bool isBot = blob.getPlayer() !is null && blob.getPlayer().isBot();
		if (possible is blob || (blob.getTeamNum() == 0 && possible.getTeamNum() == 0) || (blob.getTeamNum() == 1 && possible.getTeamNum() == 1) || possible.hasTag("dead") || possible.hasTag("migrant"))
		{
			possible_targets.removeAt(i);
		}
	}
	
	CBlob@ target;
	@target = null;
	float smallest_dist = 99999.0f;
	for (int i = 0; i < possible_targets.size(); i++)
	{
		CBlob@ check = possible_targets[i];
		if (check !is blob && blob.getTeamNum() != check.getTeamNum())
		{
			Vec2f dist = check.getPosition() - blob.getPosition();
			if (dist.getLength() < smallest_dist)
			{
				@target = @check;
				smallest_dist = dist.getLength();
			}
		}
	}

	if (target is blob)
	{
		print("rip");
	}
	return @target;
}

void Repath(CBrain@ this)
{
	this.SetPathTo(this.getTarget().getPosition(), false);
}

bool isVisible(CBlob@blob, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
}

bool isVisible(CBlob@ blob, CBlob@ target, f32 &out distance)
{
	Vec2f col;
	bool visible = !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
	distance = (blob.getPosition() - col).getLength();
	return visible;
}

bool JustGo(CBlob@ blob, CBlob@ target)
{
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

		if (point.y + getMap().tilesize * 0.7f < mypos.y && (target.isOnGround() || target.getShape().isStatic()))  	 // dont hop with me
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

void JumpOverObstacles(CBlob@ blob)
{
	Vec2f pos = blob.getPosition();
	const f32 radius = blob.getRadius();

	if (blob.isOnWall())
	{
		blob.setKeyPressed(key_up, true);
	}
	else if (!blob.isOnLadder())
		if ((blob.isKeyPressed(key_right) && (getMap().isTileSolid(pos + Vec2f(1.3f * radius, radius) * 1.0f) || blob.getShape().vellen < 0.1f)) ||
		        (blob.isKeyPressed(key_left)  && (getMap().isTileSolid(pos + Vec2f(-1.3f * radius, radius) * 1.0f) || blob.getShape().vellen < 0.1f)))
		{
			blob.setKeyPressed(key_up, true);
		}
}

void DefaultChaseBlob(CBlob@ blob, CBlob @target)
{
	CBrain@ brain = blob.getBrain();
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	Vec2f targetVector = targetPos - myPos;
	f32 targetDistance = targetVector.Length();
	// check if we have a clear area to the target
	bool justGo = true;

	Vec2f col;

	// repath if no clear path after going at it
	if (XORRandom(40) == 0 && (blob.get_Vec2f("last pathing pos") - targetPos).getLength() > 50.0f)
	{
		Repath(brain);
		blob.set_Vec2f("last pathing pos", targetPos);
	}

	const bool stuck = brain.getState() == CBrain::stuck;

	const CBrain::BrainState state = brain.getState();
	{
		if (state == CBrain::has_path && (Maths::Abs(blob.getVelocity().x) + Maths::Abs(blob.getVelocity().y) < 0.9f || targetDistance < 95.0f))
		{
			brain.SetSuggestedKeys();  // set walk keys here
		}
		else
		{
			//if (!isFriendAheadOfMe(blob, target))
			//{
			JustGo(blob, target);
		}

		switch (state)
		{
			case CBrain::idle:
				Repath(brain);
				break;

			case CBrain::searching:
				break;

			case CBrain::stuck:
				Repath(brain);
				break;

			case CBrain::wrong_path:
				Repath(brain);
				break;
		}
	}
	
	// Aim at target, or direction of movement for more speed.
	if (targetDistance > 55.0f)
	{
		blob.setAimPos(myPos + blob.getVelocity()*2.0f);
	}
	else
	{
		blob.setAimPos(targetPos);
	}

	// jump over small blocks
	JumpOverObstacles(blob);
}

bool DefaultRetreatBlob(CBlob@ blob, CBlob@ target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f point = target.getPosition();
	if (point.x > mypos.x)
	{
		blob.setKeyPressed(key_left, true);
	}
	else
	{
		blob.setKeyPressed(key_right, true);
	}

	if (mypos.y - blob.getRadius() > point.y)
	{
		blob.setKeyPressed(key_up, true);
	}

	if (blob.isOnLadder() && point.y < mypos.y)
	{
		blob.setKeyPressed(key_down, true);
	}

	JumpOverObstacles(blob);

	return true;
}

void SearchTarget(CBrain@ this, const bool seeThroughWalls = false, const bool seeBehindBack = true)
{
	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// search target if none

	CBlob@ oldTarget = target;
	@target = getNewTarget(this, blob, seeThroughWalls, seeBehindBack);
	this.SetTarget(target);

	if (target !is oldTarget)
	{
		onChangeTarget(blob, target, oldTarget);
	}
}

void onChangeTarget(CBlob@ blob, CBlob@ target, CBlob@ oldTarget)
{
	blob.set_s16("shieldbash_confidence", 0);

	if (target !is null)
	{
		if (target.isKeyPressed(key_action1))
		{
			blob.set_s16("target_slashtime", 39);
		}
		else
		{
			blob.set_s16("target_slashtime", 0);
		}
	}
}

bool LoseTarget(CBrain@ this, CBlob@ target)
{
	if (target.hasTag("dead"))
	{
		CBlob @blob = this.getBlob();
		
		@target = null;
		this.SetTarget(target);
		blob.set_s16("target_slashtime", 0);
		blob.set_s16("shieldbash_confidence", 0);
		return true;
	}
	return false;
}

void Runaway(CBlob@ blob, CBlob@ target)
{
	blob.setKeyPressed(key_left, false);
	blob.setKeyPressed(key_right, false);

	if (target.getPosition().x > blob.getPosition().x)
	{
		blob.setKeyPressed(key_left, true);
	}
	else
	{
		blob.setKeyPressed(key_right, true);
	}
}

void Chase(CBlob@ blob, CBlob@ target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	blob.setKeyPressed(key_left, false);
	blob.setKeyPressed(key_right, false);

	if (targetPos.x < mypos.x)
	{
		blob.setKeyPressed(key_left, true);
	}
	else
	{
		blob.setKeyPressed(key_right, true);
	}

	if (targetPos.y + getMap().tilesize < mypos.y)
	{
		blob.setKeyPressed(key_up, true);
	}
}

bool isFriendAheadOfMe(CBlob @blob, CBlob @target, const f32 spread = 16.0f)
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
		        && ((blob.isFacingLeft() && pos.x > pos2.x && pos2.x > targetPos.x) || (!blob.isFacingLeft() && pos.x < pos2.x && pos2.x < targetPos.x) || XORRandom(2) == 0)
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

void FloatInWater(CBlob@ blob)
{
	if (blob.isInWater())
	{
		blob.setKeyPressed(key_up, true);
	}
}

void ShieldSlide(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();

	CMap@ map = blob.getMap();

	blob.setKeyPressed(key_action2, true);

	if (map.isTileSolid(mypos + Vec2f(0.0f, 28.0f)))
	{
		blob.setAimPos(mypos + blob.getVelocity() + Vec2f(0.0f, 128.0f));

		blob.set_s16("shieldbash_confidence", blob.get_s16("shieldbash_confidence") + 1);
	}
	else if (Maths::Abs(blob.getVelocity().y) < 2.0f)
	{
		// Glide
		blob.setAimPos(mypos + blob.getVelocity() - Vec2f(0.0f, 128.0f));
	}
	else
	{
		blob.setKeyPressed(key_action2, false);
	}

	blob.setKeyPressed(key_up, getGameTime() % 2 == 0);
}

void RandomTurn(CBlob@ blob)
{
	if (XORRandom(4) == 0)
	{
		CMap@ map = getMap();
		blob.setAimPos(Vec2f(XORRandom(int(map.tilemapwidth * map.tilesize)), XORRandom(int(map.tilemapheight * map.tilesize))));
	}
}