// Aphelion \\

#include "CreatureCommon.as"

void onInit( CMovement@ this )
{
    CreatureMoveVars moveVars;

    //walking vars
    moveVars.walkSpeed = 2.1f;
    moveVars.walkFactor = 1.0f;
    moveVars.walkLadderSpeed.Set( 0.15f, 0.6f );

     //flying vars
    moveVars.flySpeed = 2.0f;
    moveVars.flyFactor = 1.0f;
    
    //stopping forces
    moveVars.stoppingForce = 0.80f; //function of mass
    moveVars.stoppingForceAir = 0.60f; //function of mass
    moveVars.stoppingFactor = 1.0f;

	//
    this.getBlob().set( "moveVars", moveVars );
    this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
