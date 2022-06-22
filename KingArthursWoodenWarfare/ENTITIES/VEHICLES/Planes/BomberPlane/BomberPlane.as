#include "VehicleCommon.as"
#include "Hitters.as"
#include "Explosion.as";

const string bomb_timer = "bomb timer";

// Bomber Plane logic

void onInit(CBlob@ this )
{
	this.getShape().getConsts().net_threshold_multiplier = 0.1f; //exp
	
	Vehicle_Setup( this,
                   65.0f, // move speed
                   0.7f,  // turn speed 0.8
                   Vec2f(0.0f, -15.0f), // jump out velocity
                   true  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_SetupPlane( this, v, -360.0f );

	this.getSprite().SetEmitSound("PlaneEngine.ogg");
	this.getSprite().SetEmitSoundPaused(true);

	{ CSpriteLayer@ w = Vehicle_addRubberWheel(this, v, 0, Vec2f(-15.0f, 9.0f)); if (w !is null) w.SetRelativeZ(-0.5f); }
	{ CSpriteLayer@ w = Vehicle_addTinyRubberWheel(this, v, 0, Vec2f(40.0f, 3.0f)); if (w !is null) w.SetRelativeZ(-0.5f); }

	// wing
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ wing = sprite.addSpriteLayer("wing layer", sprite.getConsts().filename, 100, 32);
	if (wing !is null)
	{
		wing.addAnimation("default", 0, false);
		int[] frames = { 1, 3, 5 };
		wing.animation.AddFrames(frames);
		wing.SetRelativeZ(1.8f);
		wing.SetOffset(Vec2f(12.0f, -3.0f));
	}


	// propel
	CSpriteLayer@ propel = sprite.addSpriteLayer("propel layer", sprite.getConsts().filename, 25, 32);
	if (propel !is null)
	{
		propel.addAnimation("default", 1, true);
		int[] frames = { 28, 29, 30, 31 };
		propel.animation.AddFrames(frames);
		propel.SetRelativeZ(-1.5f);
		propel.SetOffset(Vec2f(-24.0f, -6.0f));
	}


	// Add machine gun on top
	if (getNet().isServer())
	{
		CBlob@ bow = server_CreateBlob("gun");	

		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow, "BOW" );
			this.set_u16("bowid",bow.getNetworkID());
		}

		CBlob@ bow2 = server_CreateBlob("gun");	

		if (bow2 !is null)
		{
			bow2.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo( bow2, "BOW2" );
			this.set_u16("bowid2",bow2.getNetworkID());
		}
	}

	this.set_string("autograb blob", "mat_bombs");

	// auto-load some ammo initially
	if (getNet().isServer())
	{
		for (uint i = 0; i < 4; i++)
		{
			CBlob@ ammo = server_CreateBlob("mat_bombs");
			if (ammo !is null)
			{
				if (!this.server_PutInInventory(ammo))
					ammo.server_Die();
			}
		}
		for (uint i = 0; i < 2; i++)
		{
			CBlob@ ammo = server_CreateBlob("mat_7mmround");
			if (ammo !is null)
			{
				if (!this.server_PutInInventory(ammo))
					ammo.server_Die();
			}
		}
	}

	this.set_u16(bomb_timer, 20);
}

void onTick( CBlob@ this )
{
	bool isClient = getNet().isClient();
	const f32 vellen = this.getShape().vellen;
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v ))
		{
			return;
		}

		Vehicle_StandardControls( this, v );


		AttachmentPoint@ ap_ = this.getAttachments().getAttachmentPointByName("FLYER");
		if (ap_ !is null)
		{
			CBlob@ pilot = ap_.getOccupied();
			
			if (pilot !is null)
			{
				if (ap_.isKeyPressed(key_action1))
				{
					if (this.hasBlob("mat_7mmround", 1) && !getMap().rayCastSolid(this.getPosition(), this.getPosition() + Vec2f(0.0f, 55.0f)))
					{
						shootGun(this);
					}
				}
			}
		}

		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ blob = ap.getOccupied();

				if (blob !is null && ap.socket)
				{
					if (ap.isKeyPressed(key_action2) && this.get_u16(bomb_timer) <= 0)
					{
						if (this.hasBlob("mat_bombs", 1) && !getMap().rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(0.0f, 55.0f)))
						{
							this.TakeBlob("mat_bombs", 1);
							DropBomb(this, blob);
						}
					}
				}
			}
		}
	}
	else
	{
		this.setVelocity(this.getVelocity() + Vec2f(0.0f, 2.0f));
	}

	CShape@ shape = this.getShape();
	Vec2f pos = this.getPosition();

	if (pos.y < 100.0f)
	{
		this.setVelocity(this.getVelocity() + Vec2f(0.0f, 0.1f));
	}


	if (Maths::Abs(this.getVelocity().x) > 0.25f)
	{
		this.getSprite().SetEmitSoundPaused(false);
		this.getSprite().SetEmitSoundVolume(vellen/12.0f);
		this.getSprite().SetEmitSoundSpeed(0.8f + vellen/30.0f);
	}
	else
	{
		this.getSprite().SetEmitSoundPaused(true);
	}

	// Crippled
	if (this.getHealth() <= this.getInitialHealth()*0.25f)
	{
		if (getGameTime() % 5 == 0 && XORRandom(5) == 0)
		{
			const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.4f, 360);
			CParticle@ p = ParticleAnimated("BlackParticle.png", pos, Vec2f(0,0), -0.5f, 1.0f, 5.0f, 0.0f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;

			ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);

			if (XORRandom(5) == 0)
			{
				Vec2f pos = this.getPosition();
				CMap@ map = getMap();
				
				ParticleAnimated("LargeSmoke", pos + Vec2f(XORRandom(60) - 30, XORRandom(48) - 24), getRandomVelocity(0.0f, XORRandom(130) * 0.01f, 90), float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 7 + XORRandom(8), XORRandom(70) * -0.00005f, true);
			}
		}

		Vec2f vel = this.getVelocity();
		if (this.isOnMap())
		{
			this.setVelocity(vel * 0.98);
		}
		else
		{
			this.setVelocity(vel * 0.992);
		}
	}

	if (getGameTime() % 10 == 0)
	{
		RemoveWheelsOnFlight(this);
	}

	if (this.get_u16(bomb_timer) > 0)
	{
		this.set_u16(bomb_timer, this.get_u16(bomb_timer) - 1);
	}
}

void shootGun(CBlob@ this)
{
	if (getGameTime() < this.get_u32("shootDelay")) return;	
	
	if (isClient())
	{
		this.getSprite().PlaySound("MachineGunShoot", 1.3f, 0.7f);

		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();
			
			ParticleAnimated("SmallExplosion3", this.getPosition(), getRandomVelocity(0.0f, XORRandom(40) * 0.01f, this.isFacingLeft() ? 90 : 270) + Vec2f(0.0f, -0.05f), float(XORRandom(360)), 0.6f + XORRandom(50) * 0.01f, 2 + XORRandom(3), XORRandom(70) * -0.00005f, true);
		}

		if (XORRandom(3) == 0)
		{
			makeGibParticle(
			"EmptyShellSmall",               // file name
			this.getPosition(),                 // position
			this.getVelocity(),                           // velocity
			0,                                  // column
			0,                                  // row
			Vec2f(16, 16),                      // frame size
			0.2f,                               // scale?
			0,                                  // ?
			"ShellCasing",                      // sound
			this.get_u8("team_color"));         // team number
		}
	}

	if (isServer())
	{
		this.TakeBlob("mat_7mmround", 1);

		CBlob@ arrow = server_CreateBlobNoInit("bullet");
		if (arrow !is null)
		{
			arrow.SetDamageOwnerPlayer(this.getPlayer());
			arrow.Init();

			arrow.IgnoreCollisionWhileOverlapped(this);
			arrow.server_setTeamNum(this.getTeamNum());
			arrow.setPosition(this.getPosition() + Vec2f(0.0f, -2.0f));
			arrow.setVelocity(Vec2f(this.isFacingLeft() ? -28 : 28, (this.getVelocity().y*2.2) + (4 + XORRandom(5))));
			//arrow.setVelocity(Vec2f(this.isFacingLeft() ? -30 * Maths::Sin(this.getAngleDegrees()) : 30 * Maths::Cos(this.getAngleDegrees()), this.isFacingLeft() ? -30 * Maths::Cos(this.getAngleDegrees()) : 30 * Maths::Sin(this.getAngleDegrees())));
			arrow.getShape().setDrag(arrow.getShape().getDrag() * 0.3f);
			arrow.server_SetTimeToDie(-1);   // override lock
			arrow.server_SetTimeToDie(1.7f);
		}
	}
	
	this.set_u32("shootDelay", getGameTime() + 4);
}

void DropBomb(CBlob@ this, CBlob@ blob)
{
	CBlob@ bomb = server_CreateBlobNoInit("ballista_bolt");
	if (bomb !is null)
	{
		bomb.setPosition(Vec2f(this.getPosition().x + (this.isFacingLeft() ? 16.0f : -16.0f), this.getPosition().y + 16.0f));
		bomb.setVelocity(Vec2f(this.getVelocity().x, Maths::Clamp(this.getVelocity().y, 0.0f, 0.0f)));
		bomb.server_setTeamNum(blob.getTeamNum());
		bomb.SetDamageOwnerPlayer(blob.getPlayer());
		bomb.Init();
		bomb.SetDamageOwnerPlayer(blob.getPlayer());

		this.set_u16(bomb_timer, 7);

		Sound::Play("PlaneDropBomb.ogg", blob.getPosition());
	}
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
}		 

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

void onTick( CSprite@ this )
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth()/blob.getInitialHealth()));		// OPT: in warboat too

	CSpriteLayer@ propel = this.getSpriteLayer("propel layer");
	if (propel !is null)
	{
		if (Maths::Abs(blob.getVelocity().x) > 0.5f)
			propel.animation.time = 1;
		else if (Maths::Abs(blob.getVelocity().x) > 0.02f)
			propel.animation.time = 3;
		else
			propel.animation.time = 0;
	}

	AttachmentPoint@[] aps;
	if (blob.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob2 = ap.getOccupied();

			if (blob2 !is null && ap.socket)
			{
				if (ap.name == "FLYER")
				{
					CSpriteLayer@ wing = this.getSpriteLayer("wing layer");
					if (wing !is null)
					{
						wing.SetFrameIndex(0);

						if (ap.isKeyPressed(key_up))
							wing.SetFrameIndex(1);
						else if (ap.isKeyPressed(key_down))
							wing.SetFrameIndex(2);
					}
				}
			}
		}
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

	if (attached.hasTag("player"))
		this.getSprite().PlaySound("PlaneDoor.ogg");
}

// Blow up
void onDie(CBlob@ this)
{
	Explode(this, 64.0f, 2.0f);

	this.getSprite().PlaySound("/BigDamage");

	if (this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if (bow !is null)
		{
			bow.server_Die();
		}
	}
	if (this.exists("bowid2"))
	{
		CBlob@ bow2 = getBlobByNetworkID(this.get_u16("bowid2"));
		if (bow2 !is null)
		{
			bow2.server_Die();
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;

	CBlob@ blob = this.getBlob();

	AttachmentPoint@ flyer = blob.getAttachments().getAttachmentPointByName("FLYER");
	if (flyer !is null	&& flyer.getOccupied() !is null && flyer.getOccupied().isMyPlayer())
	{
		f32 diff = 360 - blob.getAngleDegrees();
		diff = (diff + 180) % 360 - 180;

		Vec2f pos = blob.getScreenPos();
			
		GUI::SetFont("menu");

		if (Maths::Abs(blob.getVelocity().x) < 1.0f && (blob.isOnGround() || blob.wasOnGround()))
		{
			GUI::DrawTextCentered("Press C to exit.", Vec2f(pos.x, pos.y + 110), SColor(185, 255, 255, 255));
		}

		if (Maths::Abs(blob.getVelocity().x) >= 1.0f && blob.getVelocity().y > 0.2 && Maths::Abs(blob.getVelocity().y) < 3.0f && getMap().rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(0.0f, 55.0f)) && !blob.isOnGround() && !blob.wasOnGround())
		{
			GUI::DrawTextCentered("[Landing]", Vec2f(pos.x, pos.y + 110), SColor(185, 130, 255, 130));
		}

		if (Maths::Abs(blob.getVelocity().x) < 4.5f && ((Maths::Abs(diff) > 14) || Maths::Abs(blob.getVelocity().x) < 0.8f) && blob.getVelocity().y > -0.5f && !getMap().rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(0.0f, 55.0f)))
		{
			GUI::DrawTextCentered("Plane is stalling!", Vec2f(pos.x, pos.y + 110), SColor(255, 255, 50, 50));
		}
		else if (!getMap().rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(0.0f, 55.0f)))
		{
			u8 critical = (Maths::Abs(blob.getVelocity().x) > 7.0f ? 255 : Maths::Abs(blob.getVelocity().x) > 5.0f ? 125 : 50);

			GUI::DrawTextCentered("Speed: [" + Maths::Round(Maths::Abs(blob.getVelocity().x)) + "]", Vec2f(pos.x, pos.y + 125), SColor(185, 255, critical, critical));
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid) return;

	if (!getNet().isServer()) return;

	f32 vellen = this.getShape().vellen;

	const f32 base = 1.5f;
	const f32 ramp = 1.2f;


	f32 diff = 360 - this.getAngleDegrees();
	diff = (diff + 180) % 360 - 180;


	if (getNet().isServer() && vellen > base)
	{
		if (vellen > base * ramp * Maths::Abs(this.getVelocity().y))
		{
			f32 damage = 1.0f;

			if (this.getVelocity().y == 0) return;

			if (vellen < base * Maths::Pow(ramp, 1) / Maths::Abs(this.getVelocity().y))
				damage = 1.5f;
			else if (vellen < base * Maths::Pow(ramp, 2) / Maths::Abs(this.getVelocity().y))
				damage = 2.0f;
			else if (vellen < base * Maths::Pow(ramp, 3) / Maths::Abs(this.getVelocity().y))
				damage = 2.5f;
			else if (vellen < base * Maths::Pow(ramp, 3) / Maths::Abs(this.getVelocity().y))
				damage = 3.5f;
			else //very dead
				damage = 18.0f;

			const f32 angle = this.getAngleDegrees();

			if (Maths::Abs(diff) < 16)
			{
				damage *= 0.02;

				if (Maths::Abs(this.getVelocity().x) < 1.5f)
					damage *= 0.01;
			}

			this.server_Hit(this, point1, normal, damage, Hitters::fall);
		}
	}
}