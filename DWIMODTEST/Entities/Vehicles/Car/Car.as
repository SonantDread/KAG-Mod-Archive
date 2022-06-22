#include "VehicleCommon.as"
#include "KnockedCommon.as";
#include "MakeCrate.as";
#include "MiniIconsInc.as";
#include "GenericButtonCommon.as";

// Catapult logic


void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              40.0f, // move speed
	              0.41f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	this.addCommandID("carjump");



	Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling",  // movement sound
	                         1.0f, // movement sound volume modifier   0.0f = no manipulation
	                         1.0f // movement sound pitch modifier     0.0f = no manipulation
	                        );
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(-10.0f, 11.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(8.0f, 10.0f));

	this.getShape().SetOffset(Vec2f(0, 6));
}

void onTick(CBlob@ this)
{
	const int time = this.getTickSinceCreated();
	VehicleInfo@ v;
	print(this.getAngleDegrees() + "");
	if (!this.get("VehicleInfo", @v))
		return;


	if (this.hasAttached()) //driver, seat or gunner, or just created
	{
		// load new item if present in inventory
		Vehicle_StandardControls(this, v);
		AttachmentPoint@ ap = this.getAttachmentPoint(0);
		if (ap !is null){
			//print("ur in the car");
			if (ap.isKeyPressed(key_action1)){
				if (this.isOnGround()){
					this.SendCommand(this.getCommandID('carjump'));
	
				}
			}
		}
	}
	else if (time % 30 == 0){
		Vehicle_StandardControls(this, v); //just make sure it's updated
	}
}





void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("carjump"))
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		if( this.getAngleDegrees() < 30 || this.getAngleDegrees() > 330){

			this.AddForce(Vec2f(0, -600));
		}
	}

}


bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
{
	return false;
}
void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge)
{
	return;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	return;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onAttach(this, v, attached, attachedPoint);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onDetach(this, v, detached, attachedPoint);
}

// Blame Fuzzle.
bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}
