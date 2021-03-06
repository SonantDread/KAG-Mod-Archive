#include "VehicleCommon.as"
#include "Knocked.as";
#include "MakeCrate.as";
#include "MiniIconsInc.as";

// Catapult logic

const u8 baseline_charge = 15;

const u8 charge_time_max = 90;
const u8 charge_contrib = 35;

const u8 cooldown_time = 20;
const u8 startStone = 100;

void onInit( CBlob@ this )
{		
    Vehicle_Setup( this,
                   30.0f, // move speed
                   0.31f,  // turn speed
                   Vec2f(0.0f, 0.0f), // jump out velocity
                   false  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	this.Tag("vehicle");
    Vehicle_SetupWeapon( this, v,
                         cooldown_time, // fire delay (ticks)
                         10, // fire bullets amount
                         getMagAttachmentPoint(this).offset, // fire position offset
                         "mat_stone", // bullet ammo config name
                         "cata_rock", // bullet config name
                         "CatapultFire", // fire sound
                         "CatapultFire", // empty fire sound
                         Vehicle_Fire_Style::custom
                       );
    Vehicle_SetupGroundSound( this, v, "WoodenWheelsRolling", // movement sound
                              1.0f, // movement sound volume modifier   0.0f = no manipulation
                              1.0f // movement sound pitch modifier     0.0f = no manipulation
                            );
    Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(-10.0f,11.0f) );
    Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(8.0f,10.0f) );
    
    this.getShape().SetOffset(Vec2f(0,6));
    
	this.set_string("autograb blob", "mat_stone");

	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob( "mat_stone" );
		if (ammo !is null)	{
			ammo.server_SetQuantity(startStone);
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
		}
	}

	//fix
	v.fire_time;
	
	// converting
	this.Tag("convert on sit");
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

		if(getNet().isClient()) //only matters visually on client
		{
			//set the arm angle based on how long ago we fired
			u16 delay = float(v.fire_delay);	 
			if (delay == 0)
				return;
			f32 time_til_fire = Maths::Max(0,Maths::Min(v.fire_time - getGameTime(), delay));
			
			{
				f32 rechargeRatio = (time_til_fire / delay);
				f32 angle = 360.0f * (1.0f-rechargeRatio);
				CSpriteLayer@ arm = this.getSprite().getSpriteLayer( "arm" );

				if (arm !is null)
				{
					f32 armAngle = 20 + (angle/9) + (float(v.charge)/float(charge_time_max))*20;
					
					f32 floattime = getGameTime();
					f32 sign = this.isFacingLeft() ? -1.0f : 1.0f;
					
					Vec2f armOffset = Vec2f(-12.0f,-10.0f);
					arm.SetOffset( armOffset );
					
					arm.ResetTransform();
					arm.SetRelativeZ( -10.5f );
					arm.RotateBy( armAngle * -sign, Vec2f(0.0f,13.0f) );

					if (getMagBlob(this) is null && v.loaded_ammo > 0) {
						arm.animation.frame = 1;
					}
					else {
						arm.animation.frame = 0;
					}

					// set the bowl attachment offset
					Vec2f offset = Vec2f(4,-10);
					offset.RotateBy( -armAngle, Vec2f(0.0f, 13.0f) );
					offset += armOffset + Vec2f(28,0);
					
					this.getAttachments().getAttachmentPointByName("MAG").offset = offset;
				}
			}
		}
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

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (!Vehicle_AddFlipButton( this, caller))
    {
        Vehicle_AddLoadAmmoButton( this, caller );
    }
}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	u8 charge = v.charge;
	
	if (charge > 0 || isActionPressed)
	{	
		if (charge < charge_time_max && isActionPressed)
		{
			charge++;
			v.charge = charge;

			u8 t = Maths::Round(float(charge_time_max)*0.66f);
			if ((charge < t && charge % 10 == 0) || (charge >= t && charge % 5 == 0))
				this.getSprite().PlaySound( "/LoadingTick" );

			chargeValue = charge;
			return false;
		}
		chargeValue = charge;
		if (charge < baseline_charge)
			return false;

		return true;
	}
	
	return false;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("fire blob"))
	{
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_onFire( this, v, blob, charge );
	}
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge )
{
    f32 charge = baseline_charge + (float(_charge)/float(charge_time_max))*charge_contrib;
						
    if (bullet !is null)
    {
        f32 angle = this.getAngleDegrees();
        f32 sign = this.isFacingLeft() ? -1.0f : 1.0f;
        
        Vec2f vel = Vec2f(sign, -0.5f) * charge * 0.3f;
        vel += (Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.01f);
        
        bullet.setVelocity( vel );
        
        if (isKnockable( bullet ))
        {
			SetKnocked( bullet, 30 );
		}
    }

    // we override the default time because we want to base it on charge
    int delay = 30 + (charge / (250/30));
    v.fire_delay = delay;
    
	v.charge = 0;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return Vehicle_doesCollideWithBlob_ground( this, blob );
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}

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
