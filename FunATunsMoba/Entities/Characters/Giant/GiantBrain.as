// Knight brain

#define SERVER_ONLY

#include "BrainCommon.as"


void onInit(CBrain@ this)
{
	InitBrain(this);
	CBlob @blob = this.getBlob();
	if(!blob.exists("stuckTime")){
		blob.set_u16("stuckTime", 0);
	}
	if(!blob.exists("lastXPos")){
		blob.set_f32("lastXPos", this.getBlob().getPosition().y);
	}
	
}
void isStuck( CBlob@ this ){

	u16 stuckTime = this.get_u16("stuckTime");
	f32 lastXPos = this.get_f32("lastXPos");
	Vec2f pos = this.getPosition();

	/*CBlob@[] nands;
	this.getMap().getBlobsInRadius(pos, t(3), @nands);
	for(uint i = 0; i < nands.length; i++){
		if(nands[i].hasTag("human")){
			print(formatInt(this.get_u8("direction"), ""));
			break;
		}
	}*/
	if(this.hasTag("retinue")){
		return;
	}
	if(Maths::Abs(pos.x - lastXPos) < t(0.5) && !this.isOnLadder()){
		stuckTime++;
		this.set_u16("stuckTime", stuckTime);
	}
	else{
		this.set_f32("lastXPos", pos.x);
		this.set_u16("stuckTime", 0);
		this.Untag("stuck");
	}

	if(stuckTime > getTicksASecond() * 2.25){
		this.Tag("stuck");
		Vec2f pos = this.getPosition();
		Vec2f atkpos = this.getTeamNum() == 0 ? pos + Vec2f(9.0f,2.0f) : pos + Vec2f(-9.0f,2.0f);
		
	this.setAimPos(atkpos);
			this.setKeyPressed( key_action1, true );
			this.setKeyPressed( key_up, false );
		
		if(stuckTime % 28 == 0){
			this.setKeyPressed( key_action1, false );
		}
	
	}
}

void onTick(CBrain@ this)
{
	SearchTarget(this, false, true);

	CBlob @blob = this.getBlob();
	isStuck(blob );
	CBlob @target = this.getTarget();
	//if (sv_test)
	//	return;
	//	 blob.setKeyPressed( key_action2, true );
	//	return;
	// logic for target

	this.getCurrentScript().tickFrequency = 1;
	if (true)
	{
		if(blob.getTeamNum() == 0)
			goRight(blob);
		else 
			goLeft(blob);
		
	}
	FloatInWater(blob);
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
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
}


void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	if (targetDistance > blob.getRadius() + 15.0f)
	{
		
			Chase(blob, target);
		
	}

	JumpOverObstacles(blob);

	// aim always at enemy
	blob.setAimPos(targetPos);

	const u32 gametime = getGameTime();

	bool shieldTime = gametime - blob.get_u32("shield time") < uint(8 + difficulty * 1.33f + XORRandom(20));
	bool backOffTime = false;

	if (target.isKeyPressed(key_action1))   // enemy is attacking me
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
			raypos += targetPos.x < mypos.x ? 32.0f : -32.0f;
			Vec2f col;
			/*
			if (getMap().rayCastSolid(raypos, raypos + Vec2f(0.0f, 32.0f), col))
			{
				blob.set_u32("backoff time", gametime);								    // base on difficulty
				backOffTime = true;
			}
			*/
		}
	}
	else
	{
		// start attack
		if (XORRandom(Maths::Max(3, 30 - (difficulty + 4) * 2)) == 0 && (getGameTime() - blob.get_u32("attack time")) > 10)
		{

			// base on difficulty
			blob.set_u32("attack time", gametime);
		}
	}

	if (shieldTime)   // hold shield for a while
	{
		blob.setKeyPressed(key_action2, true);
		blob.setKeyPressed(key_up, true);
	}
	
	else if (targetDistance < 40.0f && getGameTime() - blob.get_u32("attack time") < (Maths::Min(13, difficulty + 3))) // release and attack when appropriate
	{
		if (!target.isKeyPressed(key_action1))
		{
			blob.setKeyPressed(key_action2, false);
		}

		blob.setKeyPressed(key_action1, true);
	}
}

