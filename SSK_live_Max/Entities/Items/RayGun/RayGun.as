// RayGun.as

#include "Hitters.as";
#include "BuilderHittable.as";
#include "ParticleSparks.as";
#include "MaterialCommon.as";
#include "FighterVarsCommon.as"

const u16 MAX_AMMO = 6;
const u16 AMMO_REGEN_TIME = 160;

const f32 PROJECTILE_SPEED = 14.0f;

const u16 COOLDOWN_TIME = 8;
const u16 CHARGE_TIME = 14;
const u16 FLASHING_TIME = 14;

namespace GunStates
{
	enum States
	{
		normal = 0,
		charging,
		firing,
		muzzle_flashing,
		cooling_down
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ muzzleFlash = this.addSpriteLayer("muzzle flash", "RayGunFlare2", 64, 64);

	if (muzzleFlash !is null)
	{
		muzzleFlash.SetRelativeZ(0.1f);
		muzzleFlash.SetOffset(Vec2f(-40,-5));
		muzzleFlash.SetVisible(false);
		muzzleFlash.setRenderStyle(RenderStyle::light);

		Animation@ anim_charging = muzzleFlash.addAnimation("charging", 0, true);
		{
			int[] frames = {0, 1, 2};
			anim_charging.AddFrames(frames);
		}

		Animation@ anim_firing = muzzleFlash.addAnimation("flashing", 0, true);
		{
			int[] frames = {3, 4, 5};
			anim_firing.AddFrames(frames);
		}
	}
}

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");

	this.Tag("usable");
	this.Tag("aimable");

	this.set_s16("shoot angle", this.getAngleDegrees());

	this.set_u16("ammo", MAX_AMMO);
	this.set_u16("ammo regen timer", 0);

	this.set_u8("state", GunStates::normal);
	this.set_u16("state timer", 0);

	this.addCommandID("pull trigger");
}

void onTick(CBlob@ this)
{
	const u32 gametime = getGameTime();
	bool inwater = this.isInWater();

	CSprite@ sprite = this.getSprite();

	u16 ammo = this.get_u16("ammo");
	u16 ammoRegenTime = this.get_u16("ammo regen timer");

	u8 gunState = this.get_u8("state");
	u16 stateTimer = this.get_u16("state timer");

	// gun logic while being held/aimed
	if (this.isAttached())
	{
		//this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null) return;

		bool canUseWeapon = true;
		SSKFighterVars@ fighterVars;
		holder.get("fighterVars", @fighterVars);
		if (fighterVars !is null)
		{
			if (fighterVars.inMoveAnimation)
			{
				canUseWeapon = false;
			}
		}

		if (gunState == GunStates::charging && !canUseWeapon)
		{
			this.set_u8("state", GunStates::normal);
			this.set_u16("state timer", 0);
		}

		f32 distance = 1.0f;

		f32 angleOffset = 0.0f;

		Vec2f aimpos = holder.getAimPos();
		Vec2f pos = holder.getPosition();
		Vec2f aim_dir = (pos - aimpos);
		aim_dir.Normalize();
		Vec2f aim_vec = aim_dir *= distance;

		// handle aiming logic
		if (gunState == GunStates::muzzle_flashing || gunState == GunStates::cooling_down)
		{	
			this.setAngleDegrees(this.get_s16("shoot angle"));

			// animate gun to push back
			AttachmentPoint@ hands = holder.getAttachments().getAttachmentPointByName("PICKUP");

			if (hands !is null)
			{
				hands.offset.x = 0 - (aim_vec.x * 2 * (holder.isFacingLeft() ? 1.0f : -1.0f)); // if blob config has offset other than 0,0 there is a desync on client, dont know why
				//hands.offset.y = -(aim_vec.y * (distance < 0 ? 1.0f : 1.0f));
			}

			// disable weapon user while gun is in shooting animation	
			if (fighterVars !is null)
			{
				fighterVars.disableItemActions = true;
			}	
		}
		else
		{
			// logic for preventing aiming backwards
			f32 mouseAngle = aim_dir.getAngleDegrees();
			f32 angle_step = 45.0f;
			//f32 pointAngle = (int(mouseAngle + (angle_step * 0.5)) / int(angle_step)) * angle_step;
			f32 pointAngle = mouseAngle % 360;

			// Clamp angles to prevent jankiness when gun is pointed straight up or down
			f32 blindSpot = 50.0f;
			if (holder.isFacingLeft()) 
			{
				if (pointAngle >= 270 && pointAngle <= 360)
					pointAngle = Maths::Max(pointAngle, 270 + blindSpot);
				else
					pointAngle = Maths::Min(pointAngle, 90 - blindSpot);
			}
			else
			{
				pointAngle = Maths::Clamp(pointAngle, 90 + blindSpot, 270 - blindSpot) + 180;
			}		

			this.setAngleDegrees((-pointAngle + angleOffset));
		}

		// gun trigger (activated by local player)
		if (holder.isMyPlayer())
		{
			if (gunState == GunStates::normal && canUseWeapon)
			{
				if (holder.isKeyJustPressed(key_action1))
				{
					CBitStream params;
					params.write_Vec2f(aim_dir);
					this.SendCommand(this.getCommandID("pull trigger"), params);
				}
			}
		}

		// fire the lasers!
		if (gunState == GunStates::firing)
		{
			const bool facingleft = this.isFacingLeft();
			Vec2f direction = Vec2f(1, 0).RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
			const f32 sign = (facingleft ? -1.0f : 1.0f);

			Vec2f shootVel = direction * PROJECTILE_SPEED;

			Vec2f muzzleOffset = (facingleft ? Vec2f(16,5) : Vec2f(16,-5));
			Vec2f muzzlePos = this.getPosition() + muzzleOffset.RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));			

			// shoot projectile
			if (getNet().isServer())
			{
				CBlob @laserBlob = server_CreateBlob("ray_gun_pulse", this.getTeamNum(), muzzlePos);
				if (laserBlob !is null)
				{
					laserBlob.setVelocity(shootVel);
				}

				ammo--;
				this.set_u16("ammo", ammo);
				this.Sync("ammo", true);
			}

			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ holder = point.getOccupied();
			if (holder !is null) 
			{
				holder.AddForce(-shootVel*12.0f);
			}

			if (getNet().isClient())
			{
				this.getSprite().PlaySound("pulseshot2.ogg", 2.0f, 1.0f);
			}

			this.set_u8("state", GunStates::muzzle_flashing);
			this.set_u16("state timer", 0);

			this.set_s16("shoot angle", this.getAngleDegrees());
		}	
	}

	// gun state continuous logic
	if (gunState == GunStates::charging)
	{
		if (stateTimer < CHARGE_TIME)
		{
			// animate gun charging
			CSpriteLayer@ muzzleFlash = sprite.getSpriteLayer("muzzle flash");
			if (muzzleFlash !is null)
			{
				muzzleFlash.SetAnimation("charging");

				f32 charge = Maths::Min(stateTimer, CHARGE_TIME);
				f32 chargePercent = charge / float(CHARGE_TIME);

				muzzleFlash.setRenderStyle(RenderStyle::light);
				this.SetLight(true);
				this.SetLightRadius(chargePercent * 24.0f);
				SColor lightColor = SColor(255, 255, Maths::Min(255, 128 + int(chargePercent * 128)), 64);
				this.SetLightColor(lightColor);
				muzzleFlash.SetVisible(true);
				muzzleFlash.animation.frame = chargePercent * 3;
			}

			stateTimer++;
			this.set_u16("state timer", stateTimer);
		}
		else
		{
			this.set_u16("state timer", 0);
			this.set_u8("state", GunStates::firing);
		}
	}
	else if (gunState == GunStates::muzzle_flashing)
	{
		if (stateTimer < FLASHING_TIME)
		{
			// animate gun muzzle flash
			CSpriteLayer@ muzzleFlash = sprite.getSpriteLayer("muzzle flash");
			if (muzzleFlash !is null)
			{
				muzzleFlash.SetAnimation("flashing");

				f32 flashingTimePercent = Maths::Min(stateTimer, FLASHING_TIME) / float(FLASHING_TIME);

				muzzleFlash.setRenderStyle(RenderStyle::light);
				this.SetLight(true);
				this.SetLightRadius(flashingTimePercent * 24.0f);
				SColor lightColor = SColor(255, 255, Maths::Min(255, 128 + int(flashingTimePercent * 128)), 64);
				this.SetLightColor(lightColor);
				muzzleFlash.SetVisible(true);
				muzzleFlash.animation.frame = flashingTimePercent * 3;
			}

			stateTimer++;
			this.set_u16("state timer", stateTimer);
		}
		else
		{
			this.set_u16("state timer", 0);
			this.set_u8("state", GunStates::cooling_down);
		}
	}
	else
	{
		CSpriteLayer@ muzzleFlash = sprite.getSpriteLayer("muzzle flash");
		if (muzzleFlash !is null)
		{
			this.SetLight(false);
			muzzleFlash.SetVisible(false);
		}		

		if (gunState == GunStates::cooling_down)
		{
			if (stateTimer < COOLDOWN_TIME)
			{
				stateTimer++;
				this.set_u16("state timer", stateTimer);
			}
			else
			{
				this.set_u16("state timer", 0);
				this.set_u8("state", GunStates::normal);
			}
		}
	}

	// ammo regen logic
	if (getNet().isServer())
	{
		if (ammo < MAX_AMMO)
		{
			if (ammoRegenTime < AMMO_REGEN_TIME)
			{
				ammoRegenTime++;
				this.set_u16("ammo regen timer", ammoRegenTime);
			}
			else
			{
				ammo++;
				this.set_u16("ammo", ammo);
				this.Sync("ammo", true);
				
				this.set_u16("ammo regen timer", 0);
			}
		}
	}

	if (getNet().isClient())
	{
		if (ammo > 0)
		{
			sprite.SetFrame(0);
		}
		else
		{
			sprite.SetFrame(1);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pull trigger"))
	{
		if (getNet().isServer())
		{
			this.Sync("state", true);
			this.Sync("state timer", true);
		}

		u8 gunState = this.get_u8("state");
		if (gunState == GunStates::normal)
		{
			u16 ammo = this.get_u16("ammo");
			if (ammo > 0) 
			{
				if (getNet().isClient())
				{
					this.getSprite().PlaySound("rayguncharge1.ogg", 1.0f, 1.5f);
				}	

				// charge up the weapon		
				this.set_u16("state timer", 0);
				this.set_u8("state", GunStates::charging);		
			}
			else
			{
				if (getNet().isClient())
				{
					this.getSprite().PlaySound("raygunempty1.ogg", 2.0f);

					Vec2f aim_dir = params.read_Vec2f();
					makeSteamParticle(this, -aim_dir);
					makeSteamParticle(this, -aim_dir);
					makeSteamParticle(this, -aim_dir);
				}	

				this.set_u16("state timer", 0);
				this.set_u8("state", GunStates::cooling_down);				
			}
		}
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void makeSteamPuff(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 10, const bool sound = true)
{
	if (sound)
	{
		this.getSprite().PlaySound("Steam.ogg");
	}

	makeSteamParticle(this, Vec2f(), "MediumSteam");
	for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32) * 0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity(-90, velocity * randomness, 360.0f);
		makeSteamParticle(this, vel);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	//this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{	
	u8 gunState = this.get_u8("state");
	if (gunState == GunStates::charging)
	{
		this.set_u8("state", GunStates::normal);
		this.set_u16("state timer", 0);
	}
}