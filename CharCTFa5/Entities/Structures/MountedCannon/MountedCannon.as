#include "VehicleCommon.as"

//todo: move to include


// Ballista logic

const u8 cooldown_time = 15;

//naming here is kinda counter intuitive, but 0 == up, 90 == sideways
const f32 high_angle = 0.0f;
const f32 low_angle = 180.0f;

void onInit(CBlob@ this)
{
	this.Tag("short raid time"); // captures quicker
	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.31f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	v.max_charge_time = 30;
	v.max_cooldown_time = cooldown_time;

	//tech - bomb bolts

	Vehicle_SetupWeapon(this, v,
	                    cooldown_time, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(30.0, 8.0), // fire position ffset
	                    "mat_shells", // bullet ammo config name
	                    "bomb", // bullet config name
	                    "BombFire", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vehicle_Fire_Style::custom
	                   );

	
	this.getShape().SetRotationsAllowed(false);
	this.getShape().SetOffset(Vec2f(0, 8));

	Vehicle_SetWeaponAngle(this, low_angle, v);
	this.set_string("autograb blob", "mat_shells");

	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_shells");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}

	
	// init arm sprites
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", sprite.getConsts().filename, 24, 40);

	if (arm !is null)
	{
		f32 angle = low_angle;

		Animation@ anim = arm.addAnimation("default", 0, false);
		anim.AddFrame(10);

		CSpriteLayer@ arm = this.getSprite().getSpriteLayer("arm");
		if (arm !is null)
		{
			arm.SetRelativeZ(0.5f);
			arm.RotateBy(angle, Vec2f(-0.5f, 15.5f));
			arm.SetOffset(Vec2f(0.0f, -6.0f));
		}
	}

	sprite.SetZ(-25.0f);
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 40, 40);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 1, 2 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(0.8f);
		arm.SetOffset(Vec2f(0.0f, -6.0f));
	}
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


void onTick(CBlob@ this)
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
			arm.SetOffset(Vec2f(0.0f, -6.0f));

			/*if (this.get_u8("loaded ammo") > 0) {
				arm.animation.frame = 1;
			}
			else {
				arm.animation.frame = 0;
			}*/
		}

	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!Vehicle_AddFlipButton(this, caller))
	{
		Vehicle_AddLoadAmmoButton(this, caller);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

 if (cmd == this.getCommandID("fire blob"))
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

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue)
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
			bullet.getShape().setDrag(bullet.getShape().getDrag() * 2.0f);
			bullet.server_SetTimeToDie(-1);   // override lock
			bullet.server_SetTimeToDie(1.0f);
			
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}
bool canBePickedUp(CBlob@ this, CBlob@ Blob)
{
	return this.getTeamNum() == Blob.getTeamNum();
}
