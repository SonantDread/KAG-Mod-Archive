// Runner Movement

#include "RunnerCommon.as"

void onInit( CMovement@ this )
{
    RunnerMoveVars moveVars;
    //walking vars
    moveVars.walkSpeed = 2.3f;
    moveVars.walkSpeedInAir = 2.1f;
    moveVars.walkFactor = 1.0f;
    moveVars.walkLadderSpeed.Set( 0.15f, 0.6f );
    //jumping vars
    moveVars.jumpMaxVel = 3.3f;
    moveVars.jumpStart = 1.3f;
    moveVars.jumpMid = 1.0f;
    moveVars.jumpEnd = 0.7f;
    moveVars.jumpFactor = 1.0f;
    moveVars.jumpCount = 0;
    moveVars.canVault = true;
    //swimming
    moveVars.swimspeed = 1.3;
    moveVars.swimforce = 30;
    moveVars.swimEdgeScale = 2.0f;
    //the overall scale of movement
    moveVars.overallScale = 1.0f;
    //stopping forces
    moveVars.stoppingForce = 0.80f; //function of mass
    moveVars.stoppingForceAir = 0.60f; //function of mass
    moveVars.stoppingFactor = 1.0f;
	//
	moveVars.walljumped = false;
	moveVars.walljumped_side = Walljump::NONE;
	moveVars.wallrun_length = 3;
	moveVars.wallrun_start = -1.0f;
	moveVars.wallrun_current = -1.0f;
	moveVars.wallclimbing = false;
	moveVars.wallsliding = false;
	//
    this.getBlob().set( "moveVars", moveVars );
    this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
