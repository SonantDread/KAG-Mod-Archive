// Boat logic
#include "VehicleCommon.as";
#include "Vehicle.as";
const f32 SPEED = 60.0f;

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              30.0f, // move speed
	              0.31f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	this.getShape().SetOffset(Vec2f(0, 7));
	this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 0));
	this.getShape().getConsts().transports = true;
	// override icon
	AddIconToken("$" + this.getName() + "$", "VehicleIcons.png", Vec2f(16, 16), 6);
	//this.Tag("heavy weight");
	this.Tag("no falldamage");

	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(-10.0f, 11.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(8.0f, 10.0f));


}

void onTick(CBlob@ this)
{
	// just drift in the general direction
	if (this.isInWater())
	{
		this.AddForce(Vec2f(this.isFacingLeft() ? -SPEED : SPEED, 0.0f));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (!this.isInWater() || this.isOnGround() || this.isOnWall());
}

