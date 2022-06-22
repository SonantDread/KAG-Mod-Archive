#include "VehicleCommon.as"
#include "GenericButtonCommon.as";
#include "Explosion.as";

// Cruiser logic

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              3000.0f, // move speed
	              0.5f,  // turn speed
	              Vec2f(0.0f, -3.0f), // jump out velocity
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
	this.set_f32("map dmg modifier", 100.0f);

	//block knight sword
	this.Tag("blocks sword");

	this.getShape().SetOffset(Vec2f(-6, 16));
	this.getShape().getConsts().bullet = false;
	this.getShape().getConsts().transports = true;
	this.getShape().SetRotationsAllowed(false);

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}

	//set custom minimap icon
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 8));
	this.SetMinimapRenderAlways(true);

	// ship gun
	if (getNet().isServer())
	{
		CBlob@ bow = server_CreateBlob("shipgun");
		if (bow !is null)
		{
			bow.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(bow, "BOW");
			this.set_u16("bowid", bow.getNetworkID());
		}
		CBlob@ bow2 = server_CreateBlob("shipgun");
		if (bow2 !is null)
		{
			bow2.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(bow2, "BOW2");
			this.set_u16("bowid2", bow2.getNetworkID());
		}
		CBlob@ bow3 = server_CreateBlob("shipgun");
		if (bow3 !is null)
		{
			bow3.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(bow3, "BOW3");
			this.set_u16("bowid3", bow3.getNetworkID());
		}
	}

	// Give random loot items this is horrible way to do it
	if (isServer())
	{
		for (uint i = 0; i < 4; i++)
		{
			CBlob@ b = server_CreateBlob("mat_7mmround", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		for (uint i = 0; i < 4; i++)
		{
			CBlob@ b = server_CreateBlob("mat_14mmround", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		{
			CBlob@ b = server_CreateBlob("steak", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		{
			CBlob@ b = server_CreateBlob("steak", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		{
			CBlob@ b = server_CreateBlob("mat_heatwarhead", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.getMap().isInWater(this.getPosition() + Vec2f(0.0f, 17.0f)))
	{
		this.AddForce(Vec2f(0, -4000.0f));
	}
	else
	{
		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.9);

		if (this.isOnGround())
		{
			this.setVelocity(vel * 0.2);
		}
	}

	if (this.getHealth() <= this.getInitialHealth()*0.3f)
	{
		if (getGameTime() % 4 == 0 && XORRandom(5) == 0)
		{
			const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()*0.4f, 360);
			CParticle@ p = ParticleAnimated("BlackParticle.png", pos, Vec2f(0,0), -0.5f, 1.0f, 5.0f, 0.0f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = false; }

			Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
			velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;

			ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);
		}

		Vec2f vel = this.getVelocity();
		this.setVelocity(vel * 0.975);
	}
	
	if (this.hasAttached())
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v))
		{
			return;
		}
		Vehicle_BoatControls(this, v);
	}
}

void Vehicle_BoatControls(CBlob@ this, VehicleInfo@ v)
{
	v.move_direction = 0;
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();

			if (blob !is null && ap.socket)
			{
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					return;
				}
				
				if (ap.name == "SAILER")
				{
					const f32 moveForce = v.move_speed;
					const f32 turnSpeed = v.turn_speed;
					Vec2f force;
					bool moving = false;
					const bool left = ap.isKeyPressed(key_left);
					const bool right = ap.isKeyPressed(key_right);
					const Vec2f vel = this.getVelocity();

					bool backwards = false;

					// row left/right

					if (left)
					{
						force.x -= moveForce;

						if (vel.x < -turnSpeed)
						{
							this.SetFacingLeft(true);
						}
						else
						{
							backwards = true;
						}

						moving = true;
					}

					if (right)
					{
						force.x += moveForce;

						if (vel.x > turnSpeed)
						{
							this.SetFacingLeft(false);
						}
						else
						{
							backwards = true;
						}

						moving = true;
					}

					if (moving)
					{
						this.AddForce(force);
					}
				}
			}
		}
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.getShape().getConsts().platform)
		return false;
	return Vehicle_doesCollideWithBlob_boat(this, blob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CSprite@ this)
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth() / blob.getInitialHealth()));
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
	Explode(this, 128.0f, 1.5f);

	if (this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if (bow !is null) { bow.server_Die(); }
	}
	if (this.exists("bowid2"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid2"));
		if (bow !is null) { bow.server_Die(); }
	}
	if (this.exists("bowid3"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid3"));
		if (bow !is null) { bow.server_Die(); }
	}
	if (this.exists("bowid4"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid4"));
		if (bow !is null) { bow.server_Die(); }
	}
}