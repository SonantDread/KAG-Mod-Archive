#include "VehicleCommon.as"

// Wheel logic (Tank)

const u8 baseline_charge = 15;
const u8 charge_contrib = 35;

void onInit(CBlob@ this)
{
	
	Vehicle_Setup(this,
	              100.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

									   
	Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling",  // movement sound
	                         2.0f, // movement sound volume modifier   0.0f = no manipulation
	                         2.0f // movement sound pitch modifier     0.0f = no manipulation
	                        );
	Vehicle_addWheel(this, v, "BigWheel.png", 32, 32, 1, Vec2f(0,0));
									   
	this.getShape().SetOffset(Vec2f(0, -5));
	
	Vec2f massCenter(0, 25);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	// converting
	this.Tag("convert on sit");

	this.set_f32("map dmg modifier", 0.5f);

	{
		Vec2f[] shape = { Vec2f( 1,  20 ),
						  Vec2f( 30, 20 ),
						  Vec2f( 27, 26 ),
						  Vec2f( 20, 30 ),
						  Vec2f( 11, 30 ),
						  Vec2f( 4,  26 ) };
		this.getShape().AddShape( shape );
	}
	
	//set custom minimap icon
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/MiniIcons.png", 11, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);

	
	
	if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob("lasergun");
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(bow, "BOW");
			this.set_u16("bowid", bow.getNetworkID());
		}
	}
}

void onTick(CBlob@ this)
{
	
	const int time = this.getTickSinceCreated();
	if (this.hasAttached() || time < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		// load new item if present in inventory
		Vehicle_StandardControls( this, v );
	}
	else if(time % 30 == 0)
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_StandardControls( this, v ); //just make sure it's updated
	}
}


bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
{
	return false;
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge ) {}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("attach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID( params.read_netid() );
		if (vehicle !is null)
		{
			vehicle.server_AttachTo( this, "VEHICLE" );
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
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
