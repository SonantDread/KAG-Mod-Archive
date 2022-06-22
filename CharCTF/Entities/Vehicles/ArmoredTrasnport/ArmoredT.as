#include "VehicleCommon.as"

// Tank logic 

void onInit( CBlob@ this )
{		
	Vehicle_Setup( this,
				   25.0f, // move speed
				   0.50f,  // turn speed
				   Vec2f(0.0f, 0.0f), // jump out velocity
				   false  // inventory access
				 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}

	Vehicle_SetupGroundSound( this, v, "WoodenWheelsRolling", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  1.0f // movement sound pitch modifier     0.0f = no manipulation
							);
	Vehicle_addWheel( this, v, "BigWoodenWheels.png", 32, 32, 0, Vec2f(-15.0f,10.0f) );
	Vehicle_addWheel( this, v, "BigWoodenWheels.png", 32, 32, 0, Vec2f(2.5f,10.0f) );
	Vehicle_addWheel( this, v, "BigWoodenWheels.png", 32, 32, 0, Vec2f(20.0f,10.0f) );
	
	this.getSprite().SetZ(-50.0f);
	this.getShape().SetOffset(Vec2f(0,6));

	Vec2f massCenter(0, 8);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	// converting
	this.Tag("convert on sit");

	this.set_f32("map dmg modifier", 2.0f);
	
AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
	// front
	{
		Vec2f[] shape = { Vec2f( 35, -22 ),
						  Vec2f( 40, -22 ),
						  Vec2f( 60, 10 ),
						  Vec2f( 65, 10 ) };
		this.getShape().AddShape( shape );
	}
	// top
	{
		Vec2f[] shape = { Vec2f(35, -22 ),
						  Vec2f(38.5, -17 ),
						  Vec2f(-10, -22 ),
						  Vec2f(-10, -17 ) };
		this.getShape().AddShape( shape );
	}

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 96, 56);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 4, 5 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
		front.SetOffset(Vec2f(0, -18));
	}

	CSpriteLayer@ flag = sprite.addSpriteLayer("flag", sprite.getConsts().filename, 40, 56);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 5, 4, 3 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-5.0f);
		flag.SetOffset(Vec2f(50, -15));
	}
		// add back ladder
	getMap().server_AddMovingSector(Vec2f(-50.0f, 0.0f), Vec2f(-35.0f, 20.0f), "ladder", this.getNetworkID());

	//set custom minimap icon
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/MiniIcons.png", 11, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);	
	
	this.addCommandID("attach vehicle");
	if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob( "shotgun_bow" );	
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW" );
			this.set_u16("bowid",bow.getNetworkID());
		}
	}

	this.addCommandID("attach vehicle");
	if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob( "mounted_bow" );	
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW2" );
			this.set_u16("bowid",bow.getNetworkID());
		}
	}
}

void onTick( CBlob@ this )
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

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	return false;
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge ) {}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
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

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_boat( this, blob );
}

void onTick(CSprite@ this)
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth() / blob.getInitialHealth()));
}

// void onCollision( CBlob@ this, CBlob@ blob, bool solid )
// {
	// if (blob !is null) {
		// TryToAttachVehicle( this, blob );
	// }
// }

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onAttach( this, v, attached, attachedPoint );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );
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
