#include "VehicleCommon.as"

// Boat logic

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              250.0f, // move speed
	              0.31f,  // turn speed
	              Vec2f(0.0f, -2.5f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupWaterSound(this, v, "BoatRowing",  // movement sound
	                        0.0f, // movement sound volume modifier   0.0f = no manipulation
	                        0.0f // movement sound pitch modifier     0.0f = no manipulation
	                       );
	Vec2f pos_off(0, 0);
	this.getShape().SetOffset(Vec2f(0, 9));
	this.getShape().SetCenterOfMassOffset(Vec2f(-1.5f, 4.5f));
	this.getShape().getConsts().transports = true;
	this.Tag("medium weight");
		this.Tag("short raid time"); // captures quicker
		//front bits
	{
		Vec2f[] shape = { Vec2f(16.0f,  -8.0f) - pos_off,
		                  Vec2f(42.0f,  -4.0f) - pos_off,
		                  Vec2f(46.0f,  6.0f) - pos_off,
		                  Vec2f(30.0f,  -2.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
		if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob("mounted_bow");
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(bow, "BOW");
			this.set_u16("bowid", bow.getNetworkID());
		}
	}
}


bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasAttached() &&
	       (!this.isInWater() || this.isOnMap()) &&
	       this.getOldVelocity().LengthSquared() < 4.0f;
}

void onTick(CBlob@ this)
{
	const int time = this.getTickSinceCreated();
	if (this.hasAttached() || time < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_StandardControls(this, v);
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_boat(this, blob);
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

void onDie(CBlob@ this)
{
	if (this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if (bow !is null)
		{
			bow.server_Die();
		}
	}
}