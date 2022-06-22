
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";


void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	

	if (blob.hasTag("dead"))
    {
        this.SetAnimation("dead");
    }
	
	
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);

	
	const bool left = blob.isKeyPressed( key_left );
	const bool right = blob.isKeyPressed( key_right );
	const bool up = blob.isKeyPressed( key_up );
	const bool down = blob.isKeyPressed( key_down );
	const bool inair = ( !blob.isOnGround() && !blob.isOnLadder() );
	Vec2f pos = blob.getPosition();
	Vec2f vec;
	const int direction = blob.getAimDirection( vec );


	RunnerMoveVars@ moveVars;
	if (!blob.get( "moveVars", @moveVars )) {
		return;	
	}
	if (!inair && !left && !right) {
		this.SetAnimation("default");
	}
	else
	{
		this.SetAnimation("fly");
	}
}


void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Arm1     = makeGibParticle( "/Mutant2Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Body     = makeGibParticle( "/Mutant2Gibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "/Mutant2Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 2, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "/Mutant2Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 3, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "/Mutant2Gibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 4, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
}