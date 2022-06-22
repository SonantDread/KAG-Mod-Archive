// Archer brain

#define SERVER_ONLY

#include "BrainBotCommon.as";
#include "ArcherCommon.as";

void onInit(CBrain@ this)
{
	InitBrain(this);
	this.getBlob().set_s32("difficulty", 15);
	GiveAmmo(this.getBlob());
	this.server_SetActive(true);
}

void GiveAmmo(CBlob@ blob)
{
	if (getNet().isServer())
	{
		if (blob.getName() == "archerbot")
		{
			for (int i = 1; i < 8; i++)
			{
				CBlob@ mat = server_CreateBlob("mat_arrows");
				if (mat !is null)
					blob.server_PutInInventory(mat);
			}
		}
	}
}

void onTick(CBrain@ this)
{
	SearchTarget(this, false, true);

    CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target

	if(!hasArrows(blob))
	{
		GiveAmmo(blob);
	}

	this.getCurrentScript().tickFrequency = 20;
    if (target !is null)
    {			
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");
		bool standground = blob.get_bool("standground");
		const bool gotarrows = hasArrows(blob);

		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (visibleTarget) 
		{
			if (!standground && (!blob.isKeyPressed(key_action1) && distance < 60.0f + 3.0f) || !gotarrows)						 
			{
				strategy = Strategy::retreating; 
			}
			else if (gotarrows)
			{
				strategy = Strategy::attacking; 
			}
		}
		
		UpdateBlob(blob, target, strategy); 

		if (LoseTarget(this, target))
		{
			strategy = Strategy::idle;
		}

		blob.set_u8("strategy", strategy);
    }
	else
	{
		RandomTurn(blob);
	}
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::chasing)
	{
		DefaultChaseBlob(blob, target);		
	}
	else if (strategy == Strategy::retreating)
	{	
		AttackBlob(blob, target);	
		DefaultRetreatBlob(blob, target);		
	}
	else if (strategy == Strategy::attacking)
	{		
		AttackBlob(blob, target);
	}
}

	 
void AttackBlob(CBlob@ blob, CBlob @target)
{
    Vec2f mypos = blob.getPosition();
    Vec2f targetPos = target.getPosition();
    Vec2f targetVector = targetPos - mypos;
    f32 targetDistance = targetVector.Length();

	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();		 
		   
	// fire

	if (targetDistance > 50.0f)
	{
		u32 fTime = blob.get_u32("fire time"); // first shot
		bool fireTime = gametime < fTime;

		if (!fireTime && (fTime == 0 || XORRandom(130 - 5.0f * 15) == 0))
		{
			const f32 vert_dist = Maths::Abs(targetPos.y - mypos.y);
			const u32 shootTime = Maths::Max(ArcherParams::ready_time, Maths::Min(uint(targetDistance * (0.3f * Maths::Max(130.0f, vert_dist) / 100.0f) + XORRandom(20)), ArcherParams::shoot_period));
			blob.set_u32("fire time", gametime + shootTime);
		}

		if (fireTime)
		{				
			bool worthShooting;
			f32 aimFactor = 10 + XORRandom(10);
			bool hardShot = targetDistance > 30.0f * 8.0f || target.getShape().vellen > 5.0f;

			blob.setAimPos(blob.getBrain().getShootAimPosition(targetPos, hardShot, worthShooting, aimFactor));
			if (worthShooting)
			{
				blob.setKeyPressed(key_action1, true);
			}
		}
	}
	else
	{
		blob.setAimPos(targetPos);
	}
}