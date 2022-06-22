#include "BrainCommon.as"
#include "Hitters.as";
#include "RunnerCommon.as";
#include "EquipmentCommon.as";

#include "TimeCommon.as";

const f32 cursor_lerp_speed = 0.50f;

void onInit(CBrain@ this)
{
	if (getNet().isServer())
	{
		InitBrain( this );
		CBlob@ blob = this.getBlob();
		
		blob.set_u32("next_repath", 0);
		blob.set_u32("next_search", 0);
		// blob.set_bool("awaiting_repath", true);
		
		// this.failtime_end = 15;
		this.plannerSearchSteps = 25;
		this.lowLevelSteps = 25;
	}
}

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) return;
	
	CBlob@ blob = this.getBlob();
	
	if(!blob.hasTag("brain_zombie"))return;
	
	if(blob.getPlayer() !is null) return;
	
	//print("hm");
	
	// SearchTarget(this, false, true);
	
	CBlob@ target = this.getTarget();
	
	int search_radius = 32.0f;
	
	const u32 next_repath = blob.get_u32("next_repath");
	const u32 next_search = blob.get_u32("next_search");
	const bool has_path = this.getHighPathSize() > 0;
	
	const bool can_repath = getGameTime() >= next_repath;
	const bool can_search = getGameTime() >= next_search && target is null;

	bool stuck = false;
	
	if (this.getState() == 4)
	{
		blob.set_bool("stuck", true);
		stuck = true;
	}
	else
	{
		stuck = blob.get_bool("stuck");
	}
	
	//print("Has Target:" + (target != null));
	//print("chaseDistance:" + chaseDistance);
	
	//print("" + stuck);
	
	// print("" + this.getCurrentScript().tickFrequency);
	
	// this.failtime_end = 15;
	// this.plannerSearchSteps = 25;
	// this.lowLevelSteps = 25;
	
	//if(target !is null)print(target.getName());
	
	// CBlob@ t = getLocalPlayerBlob();
	// CBlob@ t = getBlobByName("camp");
	// if (t !is null && getGameTime() % 30 == 0) 
	// {	
		// this.SetHighLevelPath(blob.getPosition(), t.getPosition());
		// // this.SetLowLevelPath(blob.getPosition(), t.getPosition());
		// // this.SetPathTo(t.getPosition(), false);
	// }
	
	// print("" + this.plannerSearchSteps);
	
	// print("" + next_search + "; " + getGameTime());
	
	if (target is null && getGameTime() % (XORRandom(60)+1) == 0)
	{	
		const bool raider = true;
		const Vec2f pos = blob.getPosition();
	
		if (can_search)
		{
			// print("search");
			
			CBlob@[] blobs;
			
			getBlobsByName("humanoid", @blobs);
			const u8 myTeam = blob.getTeamNum();
			
			CBlob @targ = null;
			
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				Vec2f bp = b.getPosition() - pos;
				
				
				if (b.getTeamNum() != myTeam && b.hasTag("alive") && b.hasTag("flesh") && !b.hasTag("invincible"))
				{
					if(targ is null || blob.getDistanceTo(b) < blob.getDistanceTo(targ))
					if(blob.getDistanceTo(b) < search_radius || isNight()){
						
						blob.set_u32("nextAttack", getGameTime() + blob.get_u8("reactionTime"));
						@targ = b;
					}
					
					//print("found");
				}
			}
			
			this.SetTarget(targ);
			
			blob.set_u32("next_search", getGameTime() + XORRandom(90));
		}

		
		// print(blob.getConfig() + stuck);
		
		// print("" + this.getPathSize());
		
		// print("" + this.getState());
		// print("" + this.getPathPositionAtIndex(100));
		
		// if (this.getPathPositionAtIndex(100) == this.getNextPathPosition())
		// {
			// print("reached path end");
		// }
		
		// const bool reached_path_end = this.getPathPositionAtIndex(100) == this.getNextPathPosition();
		// if (reached_path_end) print("reached path end");
		
		/*
		if (raider)
		{
			CBlob@ raid_target = getBlobByNetworkID(blob.get_u16("raid target"));
			if (raid_target !is null)
			{
				const f32 distance = (raid_target.getPosition() - blob.getPosition()).Length();
				if (distance > 16)
				{
					const bool reached_path_end = this.getPathPositionAtIndex(100) == this.getNextPathPosition();
					Vec2f dir;
					
					if (can_repath) 
					{
						this.SetPathTo(raid_target.getPosition(), false);
						blob.set_u32("next_repath", getGameTime() + 60 + XORRandom(60));
					}
					
					if (has_path && !reached_path_end)
					{
						dir = this.getNextPathPosition() - blob.getPosition();
						dir.Normalize();
						
						blob.set_Vec2f("target_dir", dir);
					}
					else
					{
						dir = blob.get_Vec2f("target_dir");
						dir.Normalize();
					}
									
					Move(this, blob, blob.getPosition() + dir * 24);
				
					if (stuck)
					{
						AttackBlob(blob, raid_target);
					}
				}
			}
			else
			{
				CBlob@[] bases;
				getBlobsByTag("bulwark", @bases);
			
				if (bases.length > 0) 
				{
					blob.set_u16("raid target", bases[XORRandom(bases.length)].getNetworkID());
				}
			}
		}*/
	}
	
	if (target !is null && target !is blob)
	{			
		// print("" + target.getConfig());
	
		
		// print("" + this.lowLevelMaxSteps);
		
		const f32 distance = (target.getPosition() - blob.getPosition()).Length();
		
		const bool visibleTarget = isVisible(blob, target);
		
		const bool target_attackable = !(target.getTeamNum() == blob.getTeamNum() || target.hasTag("material"));
		const bool chase = target_attackable && (!visibleTarget || distance > 8);
		
		if (target_attackable)
		{
			AttackBlob(blob, target);
		}
		
		if (target_attackable && chase)
		{
			if (can_repath) 
			{	
				this.SetPathTo(target.getPosition(), false);
				blob.set_u32("next_repath", getGameTime() + 60 + XORRandom(30));
			}
	
			Vec2f dir = this.getNextPathPosition() - blob.getPosition();
			dir.Normalize();
			
			if (!visibleTarget)
			{
				Move(this, blob, blob.getPosition() + dir * 24);
			}
			else 
			{
				Move(this, blob, target.getPosition());
			}
			
			// Move(this, blob, blob.getPosition() + dir * 16);
		}

		if ((!target.hasTag("alive") && !target.hasTag("animated")) || (blob.getDistanceTo(target) > search_radius*2.0f && !isNight())) 
		{
			ResetTarget(this);
			return;
		}
	}
	else
	{
		if(getGameTime() % 63 == 0){
			if(XORRandom(10) == 0) RandomTurn(blob);

			if(blob.hasTag("AI_Crouch")){
				if(XORRandom(10) == 0)blob.Untag("AI_Crouch");
			} else {
				if(XORRandom(20) == 0)blob.Tag("AI_Crouch");
			}
		}
		if(blob.hasTag("AI_Crouch") && (!blob.isInWater() || !isNight()))blob.setKeyPressed(key_down, true);
	}

	if(isNight())FloatInWater(blob); 
} 

void ResetTarget(CBrain@ this)
{
	CBlob@ blob = this.getBlob();

	this.SetTarget(null);
	blob.set_bool("stuck", false);
}

void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = 10;//blob.get_s32("difficulty");

	// aim always at enemy
	blob.setAimPos(targetPos);
	blob.SetFacingLeft(targetPos.x < blob.getPosition().x);

	const u32 gametime = getGameTime();

	bool shieldTime = gametime - blob.get_u32("shield time") < uint(8 + difficulty * 1.33f + XORRandom(20));
	bool backOffTime = gametime - blob.get_u32("backoff time") < uint(1 + XORRandom(20));

	EquipmentInfo@ equip;
	if (!blob.get("equipInfo", @equip))return;

	int equipment = equip.MainHand;
	keys key = key_action1;
	for(int i = 0;i < 2;i++){
		if(i == 1){
			equipment = equip.SubHand;
			key = key_action2;
		}
		
		if(equipment == Equipment::Sword || equipment == Equipment::GreatSword || equipment == Equipment::Bow){
			if (XORRandom(Maths::Max(3, 30 - (difficulty + 4) * 2)) == 0 && (getGameTime() - blob.get_u32("attack time")) > 10)
			{
				blob.set_u32("attack time", gametime);
			}
			if (targetDistance < 40.0f && getGameTime() - blob.get_u32("attack time") < (Maths::Min(13, difficulty + 3))) // release and attack when appropriate
			{
				blob.setKeyPressed(key, true);
			}
		}
		
		if(equipment == Equipment::Shield){
			if (target.hasTag("hostile"))   // enemy is attacking me
			{
				int r = XORRandom(35);
				if (difficulty > 2 && r < 2 && (!backOffTime || difficulty > 4))
				{
					blob.set_u32("shield time", gametime);
					shieldTime = true;
				}
				else if (difficulty > 1 && r > 32 && !shieldTime)
				{
					// raycast to check if there is a hole behind

					Vec2f raypos = mypos;
					raypos.x += targetPos.x < mypos.x ? 32.0f : -32.0f;
					Vec2f col;
					if (getMap().rayCastSolid(raypos, raypos + Vec2f(0.0f, 32.0f), col))
					{
						blob.set_u32("backoff time", gametime);								    // base on difficulty
						backOffTime = true;
					}
				}
			}
			if (shieldTime)   // hold shield for a while
			{
				blob.setKeyPressed(key, true);
			}
		}
		
		if(equipment == Equipment::Pick || equipment == Equipment::ZombieHands || equipment == Equipment::Casting){
			blob.setKeyPressed(key, true);
		}
		
		
	}
	
	if (backOffTime)   // back off for a bit
	{
		Runaway(blob, target);
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
	
	//if(this.getBrain() !is null)ResetTarget(this.getBrain());
	
	return damage;
}

void Move(CBrain@ this, CBlob@ blob, Vec2f pos)
{
	Vec2f dir = blob.getPosition() - pos;

	blob.setKeyPressed(key_left, dir.x > 0);
	blob.setKeyPressed(key_right, dir.x < 0);
	blob.setKeyPressed(key_up, dir.y > 0);
	blob.setKeyPressed(key_down, dir.y < 0 && !blob.isOnGround());
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}