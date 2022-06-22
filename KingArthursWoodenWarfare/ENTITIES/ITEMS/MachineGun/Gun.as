#include "VehicleCommon.as"
#include "Recoil.as";

const Vec2f arm_offset = Vec2f(-2, 0);

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.3f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupWeapon(this, v,
	                    3, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, 2.0f), // fire position offset
	                    "mat_7mmround", // bullet ammo config name
	                    "bullet", // bullet config name
	                    "MachineGunFire", // fire sound
	                    "EmptyFire" // empty fire sound
	                   );
	//v.charge = 1;
	//v.loaded_ammo = 0;
	// init arm sprites
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", sprite.getConsts().filename, 48, 16);

	if (arm !is null)
	{
		Animation@ anim = arm.addAnimation("default", 0, false);
		anim.AddFrame(4);
		anim.AddFrame(5);
		arm.SetOffset(arm_offset);

		arm.animation.frame = 1;
	}

	this.getShape().SetRotationsAllowed(false);
	this.set_string("autograb blob", "mat_7mmround");

	sprite.SetZ(20.0f);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	// auto-load some ammo initially
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_7mmround");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.getSpriteLayer("arm");

	if (arm !is null)
	{
		arm.animation.frame = 1;
	}
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = Vehicle_getWeaponAngle(this, v);
	bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
	bool failed = true;

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = -9.0f;
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			        (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max(-80.0f , Maths::Min(angle , 80.0f));
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
	}

	return angle;
}

void onTick(CBlob@ this)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	f32 angle = getAimAngle(this, v);
	Vehicle_SetWeaponAngle(this, angle, v);
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.getSpriteLayer("arm");

	if (arm !is null)
	{
		bool facing_left = sprite.isFacingLeft();
		f32 rotation = angle * (facing_left ? -1 : 1);

		CInventory@ inventory = this.getInventory();
		if (inventory != null)
		{
			if (inventory.getItemsCount() <= 0)
			{
				arm.animation.frame = 1;
			}
			else
			{
				if (canFire(this, v))
				{
					arm.animation.frame = 0;
				}
				else
				{
					arm.animation.frame = 1;
				}
			}
		}

		arm.ResetTransform();
		arm.SetFacingLeft(facing_left);
		arm.SetRelativeZ(1.0f);
		arm.SetOffset(arm_offset);
		arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
	}

	Vehicle_StandardControls(this, v);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!Vehicle_AddFlipButton(this, caller))
	{
		Vehicle_AddLoadAmmoButton(this, caller);
	}
}

bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused)
{
	if (bullet !is null)
	{
		u16 charge = v.charge;
		f32 angle = Vehicle_getWeaponAngle(this, v);
		angle = angle * (this.isFacingLeft() ? -1 : 1);
		angle += ((XORRandom(512) - 256) / 72.0f);

		Vec2f vel = Vec2f(620.0f / 16.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		bullet.setVelocity(vel);
		Vec2f offset = arm_offset;
		offset.RotateBy(angle);
		bullet.setPosition(this.getPosition() + offset * .2f);
		
		bullet.getShape().setDrag(bullet.getShape().getDrag() * 0.5f);

		bullet.server_SetTimeToDie(-1);   // override lock
		bullet.server_SetTimeToDie(1.5f);
		bullet.Tag("bow arrow");


		if (isClient())
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();
			
			ParticleAnimated("SmallExplosion3", (this.getPosition() + offset * .2f) + vel*0.6, getRandomVelocity(0.0f, XORRandom(40) * 0.01f, this.isFacingLeft() ? 90 : 270) + Vec2f(0.0f, -0.05f), float(XORRandom(360)), 0.6f + XORRandom(50) * 0.01f, 2 + XORRandom(3), XORRandom(70) * -0.00005f, true);
		}

		makeGibParticle(
		"EmptyShellSmall",               // file name
		this.getPosition(),                 // position
		(this.isFacingLeft() ? -offset : offset),                           // velocity
		0,                                  // column
		0,                                  // row
		Vec2f(16, 16),                      // frame size
		0.2f,                               // scale?
		0,                                  // ?
		"ShellCasing",                      // sound
		this.get_u8("team_color"));         // team number
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}