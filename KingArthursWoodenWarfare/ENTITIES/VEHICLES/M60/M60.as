#include "VehicleCommon.as"
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
#include "Requirements_Tech.as";
#include "GenericButtonCommon.as";
#include "Explosion.as";
#include "Hitters.as"

#include "Recoil.as";

string[] smoke = 
{
	"Explosion.png",
	"LargeSmoke"
};

// M60 logic

const u8 cooldown_time = 1435; //120

const u8 recoil = 100;

// 0 == up, 90 == sideways
const f32 high_angle = 79.0f;
const f32 low_angle = 95.0f;

void onInit(CBlob@ this)
{
	this.Tag("vehicle");

	this.Tag("heavy weight");

	//InitRespawnCommand(this);
	InitClasses(this);

	Vehicle_Setup(this,
	              160.0f, // move speed
	              0.2f,  // turn speed
	              Vec2f(0.0f, 0.56f), // jump out velocity
	              false  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}

	v.max_charge_time = 3;
	v.max_cooldown_time = cooldown_time;

	Vehicle_SetupWeapon(this, v,
	                    cooldown_time, // fire delay (ticks)
	                    1, // fire bullets amount
	                    Vec2f(-6.0f, -8.0f), // fire position ffset //-6.0, -8.0
	                    "mat_bolts", // bullet ammo config name
	                    "ballista_bolt", // bullet config name   //ballista_bolt
	                    "TankFireHeavy", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vehicle_Fire_Style::custom
	                   );

	Vehicle_SetupGroundSound(this, v, "TankEngine",  // movement sound
	                         0.4f, // movement sound volume modifier   0.0f = no manipulation
	                         -0.3f // movement sound pitch modifier     0.0f = no manipulation
	                        );

	{ CSpriteLayer@ w = Vehicle_addPokeyWheel(this, v, 0, Vec2f(29.0f, 2.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(20.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(12.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(4.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-4.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-12.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-20.0f, 6.0f)); if (w !is null) w.SetRelativeZ(10.0f); }
	{ CSpriteLayer@ w = Vehicle_addWoodenWheel(this, v, 0, Vec2f(-29.0f, 2.0f)); if (w !is null) w.SetRelativeZ(10.0f); }

	this.getShape().SetOffset(Vec2f(0, -2)); //0,2

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

	// init arm sprites
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", sprite.getConsts().filename, 24, 80);

	if (arm !is null)
	{
		f32 angle = low_angle;

		Animation@ anim = arm.addAnimation("default", 0, false);
		anim.AddFrame(20);

		CSpriteLayer@ arm = this.getSprite().getSpriteLayer("arm");
		if (arm !is null)
		{
			arm.SetRelativeZ(0.5f);
			//arm.RotateBy(angle, Vec2f(-0.5f, 15.5f));
			arm.SetOffset(Vec2f(-90.0f, -7.0f));
		}
	}

	sprite.SetZ(-100.0f);
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 80, 80);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 1, 2 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(0.8f);
		front.SetOffset(Vec2f(0.0f, 0.0f));
	}

	// Add machine gun on top
	if (getNet().isServer())
	{
		CBlob@ bow = server_CreateBlob(XORRandom(100) <= 90 ? "gun" : "heavygun");	

		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW" );
			this.set_u16("bowid",bow.getNetworkID());
		}
	}

	this.SetFacingLeft(this.getTeamNum() == 1 ? true : false);
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
			arm.SetOffset(Vec2f(-20.0f, -27.0f));   //10.0f, -6.0f
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

		Vec2f vel = this.getVelocity();
		if (!this.isOnMap())
		{
			Vec2f vel = this.getVelocity();
			this.setVelocity(Vec2f(vel.x * 0.995, vel.y));
		}
		else if (Maths::Abs(vel.x) > 2.5f)
		{
			if (getGameTime() % 4 == 0)
			{
				if (isClient())
				{
					Vec2f pos = this.getPosition();
					CMap@ map = getMap();
					
					ParticleAnimated("LargeSmoke", this.getPosition() + Vec2f(XORRandom(18) - 9 + (this.isFacingLeft() ? 30 : -30), XORRandom(18) - 3), getRandomVelocity(0.0f, 0.5f + XORRandom(60) * 0.01f, this.isFacingLeft() ? 90 : 270) + Vec2f(0.0f, -0.1f), float(XORRandom(360)), 0.7f + XORRandom(70) * 0.01f, 3 + XORRandom(3), XORRandom(70) * -0.00005f, true);
				}
			}
		}

		if (isClient() && getGameTime() % 20 == 0)
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();
			
			ParticleAnimated("SmallSmoke1", pos + Vec2f((this.isFacingLeft() ? 1 : -1)*(28+XORRandom(15)),0.0f) + Vec2f(XORRandom(10) - 5, XORRandom(8) - 4), getRandomVelocity(0.0f, XORRandom(50) * 0.01f, 90) + Vec2f(0.0f,-0.15f), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 5 + XORRandom(8), XORRandom(70) * -0.00005f, true);
		}
	}

	// Crippled
	if (this.getHealth() <= this.getInitialHealth()*0.25f)
	{
		if (getGameTime() % 4 == 0 && XORRandom(5) == 0)
		{
			const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.4f, 360);
			CParticle@ p = ParticleAnimated("BlackParticle.png", pos, Vec2f(0,0), -0.5f, 1.0f, 5.0f, 0.0f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;

			ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);

			if (isClient() && XORRandom(2) == 0)
			{
				Vec2f pos = this.getPosition();
				CMap@ map = getMap();
				
				ParticleAnimated("LargeSmoke", pos + Vec2f(XORRandom(60) - 30, XORRandom(48) - 24), getRandomVelocity(0.0f, XORRandom(130) * 0.01f, 90), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 7 + XORRandom(8), XORRandom(70) * -0.00005f, true);
			}
		}

		if (this.isOnMap())
		{
			Vec2f vel = this.getVelocity();
			this.setVelocity(vel * 0.98);
		}
	}

	Vehicle_LevelOutInAir(this);
}

// Blow up
void onDie(CBlob@ this)
{
	Explode(this, 64.0f, 1.0f);

	this.getSprite().PlaySound("/BigDamage");

	if (this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if (bow !is null)
		{
			bow.server_Die();
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (isOverlapping(this, caller) && !caller.isAttached())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(0, -4), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);

		if (!Vehicle_AddFlipButton(this, caller) && caller.getTeamNum() == this.getTeamNum())
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
		
		// check for valid ammo
		if (blob.getName() != v.bullet_name){
			// output warning
			warn("Attempted to launch invalid object!");
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

		f32 charge = 41.5f;

		f32 angle = getAngle(this, _charge, v) + this.getAngleDegrees();
		Vec2f vel = Vec2f(0.0f, -charge).RotateBy(angle);
		bullet.setVelocity(vel);
		bullet.setPosition(bullet.getPosition() + vel + Vec2f((this.isFacingLeft() ? -1 : 1)*12.0f, 0.0f));

		this.AddForce(Vec2f(this.isFacingLeft() ? (recoil*5.0f) : (-recoil*5.0f), 0.0f));

		if (isClient())
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();
			
			for (int i = 0; i < 12; i++)
			{
				ParticleAnimated(smoke[XORRandom(smoke.length)], (bullet.getPosition() + Vec2f((this.isFacingLeft() ? -1 : 1)*12.0f, 0.0f)) + Vec2f(XORRandom(36) - 18, XORRandom(36) - 18), getRandomVelocity(0.0f, XORRandom(130) * 0.01f, this.isFacingLeft() ? 90 : 270) + Vec2f(0.0f, -0.16f), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 9 + XORRandom(5), XORRandom(70) * -0.00005f, true);
			}
		}

		makeGibParticle(
		"EmptyShell",               // file name
		this.getPosition(),                 // position
		(Vec2f(0.0f,-0.5f) + getRandomVelocity(90, 5, 360)),      // velocity
		0,                                  // column
		0,                                  // row
		Vec2f(16, 16),                      // frame size
		0.5f,                               // scale?
		0,                                  // ?
		"ShellCasing",                      // sound
		this.get_u8("team_color"));         // team number
	}	

	v.last_charge = _charge;
	v.charge = 0;
	v.cooldown_time = cooldown_time;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("vehicle") && this.getTeamNum() != blob.getTeamNum())
	{
		return true;
	}

	if (blob.hasTag("flesh") && !blob.isAttached())
	{
		if (blob.getPosition().y < this.getPosition().y)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return Vehicle_doesCollideWithBlob_ground(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	attachedPoint.offsetZ = 1.0f;
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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f) //sound
	{
		if (hitterBlob !is this && customData == Hitters::ballista)
		{
			this.getSprite().PlaySound("BigDamage", 2.5f, 0.85f + (XORRandom(50)/100));

			if (isClient())
			{
				ParticleAnimated("BoomParticle", this.getPosition(), Vec2f(0.0f, -0.9f), 0.0f, 2.0f, 3, XORRandom(70) * -0.00005f, true);
			}
		}
	}

	return damage;
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