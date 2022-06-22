#include "VehicleCommon.as"
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
#include "Requirements_Tech.as";

//todo: move to include
bool hasTech(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "tech", "bomb ammo", "Bomb Ammo");

	int thisteam = this.getTeamNum();

	CPlayer@ player;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		@player = getPlayer(i);
		if (player.getTeamNum() == thisteam && player.getBlob() !is null)
			break;
	}

	if (player !is null && player.getBlob() !is null)
	{
		return hasRequirements_Tech(player.getBlob().getInventory(), reqs, missing);
	}
	return false;
}

// Ballista logic

const u8 cooldown_time = 90;

//naming here is kinda counter intuitive, but 0 == up, 90 == sideways
const f32 high_angle = 20.0f;
const f32 low_angle = 60.0f;

void onInit(CBlob@ this)
{
	this.Tag("respawn");

	InitRespawnCommand(this);
	InitClasses(this);
	this.Tag("change class drop inventory");
	
	Vehicle_Setup( this,
				   15.0f, // move speed
				   0.31f,  // turn speed
				   Vec2f(0.0f, 0.0f), // jump out velocity
				   false  // inventory access
				 );
VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	v.max_charge_time = 80;
	v.max_cooldown_time = cooldown_time;

	//tech - bomb bolts
	bool hasBomb = hasTech(this, "bomb ammo");
	this.set_bool("bomb ammo", hasBomb);

	Vehicle_SetupWeapon(this, v,
	                    cooldown_time, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, -8.0f), // fire position ffset
	                    "mat_bolts", // bullet ammo config name
	                    "ballista_bolt", // bullet config name
	                    "CatapultFire", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vehicle_Fire_Style::custom
	                   );

	v.fire_cost_per_amount = hasBomb ? 2 : 1;
	
	Vehicle_SetupGroundSound( this, v, "WoodenWheelsRolling", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  1.0f // movement sound pitch modifier     0.0f = no manipulation
							);
							
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(33.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(22.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(11.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-1.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-11.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-22.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-33.0f, 18.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	
	this.getShape().SetOffset(Vec2f(0,8));

		Vehicle_SetWeaponAngle(this, low_angle, v);
	this.set_string("autograb blob", "mat_bolts");

		// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_bolts");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
	
	Vec2f pos_off(0, 0);
	this.set_f32("map dmg modifier", 0.0f);

	this.getShape().SetOffset(Vec2f(-4, 10));
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().transports = true;

	// additional shapes


	//front bits

	{
		Vec2f[] shape = { Vec2f(35.0f,  46.0f) - pos_off,
		                  Vec2f(40.0f,  34.0f) - pos_off,
		                  Vec2f(58.0f,  34.0f) - pos_off,
		                  Vec2f(65.0f,  46.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}

			// add back ladder
	//getMap().server_AddMovingSector(Vec2f(-50.0f, 0.0f), Vec2f(-35.0f, 20.0f), "ladder", this.getNetworkID());
	
	//set custom minimap icon
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("MegaTankIcon.png", 11, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);	
	
	this.addCommandID("attach vehicle");
	if (getNet().isServer())// && hasTech( this, "mounted bow"))
	{
		CBlob@ bow = server_CreateBlob( "mounted_gun" );	
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW" );
			this.set_u16("bowid",bow.getNetworkID());
		}
	}
	// init arm sprites
	// CSprite@ sprite = this.getSprite();
	// CSpriteLayer@ arm = sprite.addSpriteLayer("arm", sprite.getConsts().filename, 24, 40);

	// if (arm !is null)
	// {
		// f32 angle = low_angle;

		// Animation@ anim = arm.addAnimation("default", 0, false);
		// anim.AddFrame(8);

		// CSpriteLayer@ arm = this.getSprite().getSpriteLayer("arm");
		// if (arm !is null)
		// {
			// arm.SetRelativeZ(0.5f);
			// arm.RotateBy(angle, Vec2f(-0.5f, 15.5f));
			// arm.SetOffset(Vec2f(10.0f, -6.0f));
		// }
	// }
 }
f32 getAngle(CBlob@ this, const u8 charge, VehicleInfo@ v)
{
	f32 angle = 180.0f; //we'll know if this goes wrong :)
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");

	bool not_found = true;

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if ((!facing_left && aim_vec.x < 0) ||
		        (facing_left && aim_vec.x > 0))
		{
			if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }
			aim_vec.RotateBy((facing_left ? 1 : -1) * this.getAngleDegrees());

			angle = (-(aim_vec).getAngle() + 270.0f);
			angle = Maths::Max(high_angle , Maths::Min(angle , low_angle));
			//printf("angle " + angle );
			not_found = false;
		}
	}

	if (not_found)
	{
		angle = Maths::Abs(Vehicle_getWeaponAngle(this, v));
		return (facing_left ? -angle : angle);
	}

	if (facing_left) { angle *= -1; }

	return angle;
}

void onTick( CBlob@ this )

{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_StandardControls(this, v);

		if (v.cooldown_time > 0)
		{
			v.cooldown_time--;
		}

		f32 angle = getAngle(this, v.charge, v);
		Vehicle_SetWeaponAngle(this, angle, v);

		CSprite@ sprite = this.getSprite();

		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			arm.ResetTransform();
			f32 floattime = getGameTime();
			arm.RotateBy(angle, Vec2f(-0.5f, 15.5f));
			arm.SetOffset(Vec2f(32.0f, -14.5f));

			/*if (this.get_u8("loaded ammo") > 0) {
				arm.animation.frame = 1;
			}
			else {
				arm.animation.frame = 0;
			}*/
		}

		if (getNet().isClient())
		{
			CPlayer@ p = getLocalPlayer();
			if (p !is null)
			{
				CBlob@ local = p.getBlob();
				if (local !is null)
				{
					CSpriteLayer@ front = sprite.getSpriteLayer("front layer");
					if (front !is null)
					{
						front.SetVisible(!local.isAttachedTo(this));
					}
				}
			}
		}
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum() && isOverlapping(this, caller) && !caller.isAttached())
	{
		if (!isAnotherRespawnClose(this) && !isFlipped(this))
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(0, -4), this, SpawnCmd::buildMenu, "Change class", params);
		}

		if (!Vehicle_AddFlipButton(this, caller))
		{
			Vehicle_AddLoadAmmoButton(this, caller);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == SpawnCmd::buildMenu || cmd == SpawnCmd::changeClass)
	{
		onRespawnCommand(this, cmd, params);
	}
	else if (cmd == this.getCommandID("fire blob"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_onFire(this, v, blob, charge);
	}
}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
v.firing = v.firing || isActionPressed;

	bool hasammo = v.loaded_ammo > 0;

	u8 charge = v.charge;
	if ((charge > 0 || isActionPressed) && hasammo)
	{
		if (charge < v.max_charge_time && isActionPressed)
		{
			charge++;
			v.charge = charge;

			u8 t = Maths::Round(float(v.max_charge_time) * 0.66f);
			if ((charge < t && charge % 10 == 0) || (charge >= t && charge % 5 == 0))
				this.getSprite().PlaySound("/LoadingTick");

			chargeValue = charge;
			return false;
		}
		chargeValue = charge;
		return true;
	}

	return false;
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge)
{
	if (bullet !is null)
	{
		u8 charge_prop = _charge;

		f32 charge = 5.0f + 15.0f * (float(charge_prop) / float(v.max_charge_time));

		f32 angle = getAngle(this, _charge, v) + this.getAngleDegrees();
		Vec2f vel = Vec2f(0.0f, -charge).RotateBy(angle);
		bullet.setVelocity(vel);
		bullet.setPosition(bullet.getPosition() + vel);

		if (this.get_bool("bomb ammo"))
		{
			bullet.Tag("bomb ammo");
			bullet.Sync("bomb ammo", true);
		}
	}

	v.last_charge = _charge;
	v.charge = 0;
	v.cooldown_time = cooldown_time;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_boat( this, blob );
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	const f32 threshold = this.getInitialHealth() * 0.25f;	
	
	if (this.getHealth() < threshold && oldHealth >= threshold)
	{	
		CSpriteLayer@ wheel = this.getSprite().getSpriteLayer("!w 2");
		if (wheel !is null)
			wheel.SetVisible( false );

		makeGibParticle( "Entities/Vehicles/Common/WoodenWheels.png", 
			this.getPosition()+wheel.getOffset(), this.getVelocity() + getRandomVelocity( 90, 5, 80 ), 
			0, 0, Vec2f (16,16), 2.0f, 20, "/material_drop", 0 );

	}
}

//void onCollision( CBlob@ this, CBlob@ blob, bool solid )
//{
//	if (blob !is null) {
//		TryToAttachVehicle( this, blob );
//	}
//}

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

bool isAnotherRespawnClose(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b !is this && b.hasTag("respawn") && b.getNetworkID() < this.getNetworkID())
			{
				return true;
			}
		}
	}
	return false;
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
