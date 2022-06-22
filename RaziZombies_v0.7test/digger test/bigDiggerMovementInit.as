#include "CreatureCommon.as"

void onInit( CMovement@ this )
{
    CreatureMoveVars moveVars;

    //flying vars
    moveVars.flySpeed = 4.0f;
    moveVars.flyFactor = 1.0f;
    
    //stopping forces
    moveVars.stoppingForce = 3.20f; //function of mass
    moveVars.stoppingForceAir = 3.20f; //function of mass
    moveVars.stoppingFactor = 1.0f;

    this.getBlob().set( "moveVars", moveVars );
    this.getBlob().getShape().getVars().waterDragScale = 30.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
