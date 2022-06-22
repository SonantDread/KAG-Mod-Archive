// Gunner logic

#include "GunnerCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";

void onInit(CBlob@ this)
{
	AddIconToken("$SnipeShoot$", "GunnerIcons.png", Vec2f(16, 32), 0);
	AddIconToken("$DoubleShoot$", "GunnerIcons.png", Vec2f(16, 32), 1);
	GunnerInfo gunner;
	this.set("gunnerInfo", @gunner);

	this.set_s8("charge_time", 0);
	this.set_u8("charge_state", GunnerParams::not_aiming);
	this.set_bool("has_bullet", false);
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on bullets
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetEmitSound("Entities/Characters/Archer/BowPull.ogg");
	this.addCommandID("shoot bullet");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(grapple_sync_cmd);

	AddIconToken("$Help_Bullet$", "LWBHelpIcons.png", Vec2f(8, 16), 23);

	SetHelp(this, "help self hide", "gunner", getTranslatedString("Hide    $KEY_S$"), "", 1);
	SetHelp(this, "help self action2", "gunner", getTranslatedString("$Grapple$ Grappling hook    $RMB$"), "", 3);

	AddIconToken("$Help_Gunner1$", "LWBHelpIcons.png", Vec2f(8, 16), 26);
	AddIconToken("$Help_Gunner2$", "LWBHelpIcons.png", Vec2f(8, 16), 27);
	SetHelp(this, "help inventory", "gunner", "$Help_Gunner1$$Swap$$Help_Gunner2$$KEY_TAP$$KEY_F$Change Full charge shoot", "", 2);


	//add a command ID for each arrow type
	for (uint i = 0; i < shootNames.length; i++)
	{
		this.addCommandID(shootNames[i]);
	}

	//add a command ID for each bullet type

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("LWBScoreboardIcons.png", 11, Vec2f(16, 16));
	}
}

void ManageGrapple(CBlob@ this, GunnerInfo@ gunner)
{
	CSprite@ sprite = this.getSprite();
	u8 charge_state = gunner.charge_state;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);

	if (right_click)
	{
		// cancel charging
		if (charge_state != GunnerParams::not_aiming &&
		    charge_state != GunnerParams::fired) // allow grapple right after firing
		{
			charge_state = GunnerParams::not_aiming;
			gunner.charge_time = 0;
			sprite.SetEmitSoundPaused(true);
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this)) //otherwise grapple
		{
			gunner.grappling = true;
			gunner.grapple_id = 0xffff;
			gunner.grapple_pos = pos;

			gunner.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				gunner.grapple_vel = direction * gunner_grapple_throw_speed;
			}
			else
			{
				gunner.grapple_vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}

		gunner.charge_state = charge_state;
	}

	if (gunner.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				gunner.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 gunner_grapple_range = gunner_grapple_length * gunner.grapple_ratio;
			const f32 gunner_grapple_force_limit = this.getMass() * gunner_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (gunner.grapple_ratio > 0.2f)
				gunner.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = gunner.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - gunner_grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * gunner_grapple_stiffness);
					force *= Maths::Min(gunner_grapple_force_limit, Maths::Max(0.0f, offdist + gunner_grapple_slack) * gunner_grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? too long? close grapple
			if (gunner.grapple_pos.x < 0 ||
			        gunner.grapple_pos.x > (map.tilemapwidth)*map.tilesize ||
			        dist > gunner_grapple_length * 3.0f)
			{
				if (canSend(this))
				{
					gunner.grappling = false;
					SyncGrapple(this);
				}
			}
			else if (gunner.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(gunner.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				gunner.grapple_vel = (gunner.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = gunner.grapple_pos + gunner.grapple_vel;
				next -= offset;

				Vec2f dir = next - gunner.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						gunner.grapple_pos += dir * step;
					}
					else
					{
						gunner.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, gunner, map, dist);
				}

			}
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if (this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - gunner.grapple_pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (gunner.grapple_id != 0)
				{
					@b = getBlobByNetworkID(gunner.grapple_id);
					if (b is null)
					{
						gunner.grapple_id = 0;
					}
				}

				if (b !is null)
				{
					gunner.grapple_pos = b.getPosition();
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							gunner.grappling = false;
							SyncGrapple(this);
						}
					}
				}
				else if (shouldReleaseGrapple(this, gunner, map))
				{
					if (canSend(this))
					{
						gunner.grappling = false;
						SyncGrapple(this);
					}
				}

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target) &&
					(this.getVelocity().Length() > 2 || !this.isOnMap()))
				{
					this.setPosition(target);
				}

				if (b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}

}

void ManageBow(CBlob@ this, GunnerInfo@ gunner, RunnerMoveVars@ moveVars)
{
	//are we responsible for this actor?
	bool ismyplayer = this.isMyPlayer();
	bool responsible = ismyplayer;
	if (isServer() && !ismyplayer)
	{
		CPlayer@ p = this.getPlayer();
		if (p !is null)
		{
			responsible = p.isBot();
		}
	}
	//
	CSprite@ sprite = this.getSprite();
	bool hasbullet = gunner.has_bullet;
	s16 charge_time = gunner.charge_time;
	u8 charge_state = gunner.charge_state;
	u8 shoot_type = gunner.shoot_type;
	u8 legolas_bullets_count = shoot_type == ShootType::doubleshoot ? 2 : 1;
	const bool pressed_action2 = this.isKeyPressed(key_action2);
	Vec2f pos = this.getPosition();

	if (responsible)
	{
		if ((getGameTime() + this.getNetworkID()) % 10 == 0)
		{
			hasbullet = hasBullets(this);
		}

		if (hasbullet != this.get_bool("has_bullet"))
		{
			this.set_bool("has_bullet", hasbullet);
			this.Sync("has_bullet", isServer());
		}

	}

	if (charge_state == GunnerParams::legolas_charging) // fast bullets
	{
		if (!hasbullet)
		{
			charge_state = GunnerParams::not_aiming;
			charge_time = 0;
		}
		else
		{
			charge_state = GunnerParams::legolas_ready;
		}
	}
	//charged - no else (we want to check the very same tick)
	if (charge_state == GunnerParams::legolas_ready) // fast bullets
	{
		moveVars.walkFactor *= 0.50f;

		gunner.legolas_time--;
		if (!hasbullet || gunner.legolas_time == 0)
		{
			bool pressed = this.isKeyPressed(key_action1);
			charge_state = pressed ? GunnerParams::readying : GunnerParams::not_aiming;
			charge_time = 0;
			//didn't fire
			if (gunner.legolas_bullets == legolas_bullets_count)
			{
				Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
				setKnocked(this, 15);
			}
			else if (pressed)
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}
		else if (this.isKeyJustPressed(key_action1) ||
		         (gunner.legolas_bullets == legolas_bullets_count &&
		          !this.isKeyPressed(key_action1) &&
		          this.wasKeyPressed(key_action1)))
		{
			ClientFire(this, hasbullet, shoot_type == ShootType::snipe);
			charge_state = GunnerParams::legolas_charging;
			charge_time = GunnerParams::shoot_period - GunnerParams::legolas_charge_time;
			Sound::Play("FastBowPull.ogg", pos);
			gunner.legolas_bullets--;

			if (gunner.legolas_bullets == 0)
			{
				charge_state = GunnerParams::readying;// it's readying, not not_aiming. old archer, too.
				charge_time = 5;

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);
			}
		}

	}
	else if (this.isKeyPressed(key_action1))
	{
		moveVars.walkFactor *= 0.60f;
		moveVars.canVault = false;

		const bool just_action1 = this.isKeyJustPressed(key_action1);

		//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
		        (charge_state == GunnerParams::not_aiming || charge_state == GunnerParams::fired))
		{
			charge_state = GunnerParams::readying;
			hasbullet = hasBullets(this);

			if (responsible)
			{
				this.set_bool("has_bullet", hasbullet);
				this.Sync("has_bullet", isServer());
			}

			charge_time = 0;

			if (!hasbullet)
			{
				charge_state = GunnerParams::no_bullets;

				if (ismyplayer && !this.wasKeyPressed(key_action1))   // playing annoying no ammo sound
				{
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}

			}
			else
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused(false);

				if (!ismyplayer)   // lower the volume of other players charging  - ooo good idea
				{
					sprite.SetEmitSoundVolume(0.5f);
				}
			}
		}
		else if (charge_state == GunnerParams::readying)
		{
			if(!hasbullet)
			{
				charge_state = GunnerParams::no_bullets;
				charge_time = 0;
				
				if (ismyplayer)   // playing annoying no ammo sound
				{
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}
			}
			charge_time++;

			if (charge_time > GunnerParams::shoot_period + 7)
			{
				charge_state = GunnerParams::charging;
			}
		}
		else if (charge_state == GunnerParams::charging)
		{
			if(!hasbullet)
			{
				charge_state = GunnerParams::no_bullets;
				charge_time = 0;
				
				if (ismyplayer)   // playing annoying no ammo sound
				{
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}
			}
			else
			{
				charge_time++;
			}

			if (charge_time >= (shoot_type == ShootType::snipe ? GunnerParams::snipe_period : GunnerParams::legolas_period) + 7)
			{
				// Legolas state

				Sound::Play("AnimeSword.ogg", pos, ismyplayer ? 1.3f : 0.7f);
				Sound::Play("FastBowPull.ogg", pos);
				charge_state = GunnerParams::legolas_charging;
				charge_time = GunnerParams::shoot_period - GunnerParams::legolas_charge_time;

				gunner.legolas_bullets = legolas_bullets_count;
				gunner.legolas_time = GunnerParams::legolas_time;
			}

			if (charge_time >= GunnerParams::shoot_period)
			{
				sprite.SetEmitSoundPaused(true);
			}
		}
		else if (charge_state == GunnerParams::no_bullets)
		{
			if (charge_time < 7)
			{
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > GunnerParams::readying)
		{
			if (charge_state < GunnerParams::fired)
			{
				ClientFire(this, hasbullet, false);

				charge_time = GunnerParams::fired_time;
				charge_state = GunnerParams::fired;
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0)
				{
					charge_state = GunnerParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else
		{
			charge_state = GunnerParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused(true);
	}

	// my player!

	if (responsible)
	{
		// set cursor

		if (ismyplayer && !getHUD().hasButtons())
		{
			int frame = 0;
			//	print("gunner.charge_time " + gunner.charge_time + " / " + GunnerParams::shoot_period );
			if (gunner.charge_state == GunnerParams::readying)
			{
				//readying shot
				frame = 2 + int((float(Maths::Max(0, gunner.charge_time - 7)) / float(GunnerParams::shoot_period + 7)) * 8) * 2;
			}
			else if (gunner.charge_state == GunnerParams::charging)
			{  
				//charging legolas
				frame = 1 + int((float(gunner.charge_time - GunnerParams::shoot_period - 7) / ((shoot_type == ShootType::snipe ? GunnerParams::snipe_period : GunnerParams::legolas_period) - GunnerParams::shoot_period)) * 9) * 2;
			}
			else if (gunner.charge_state == GunnerParams::legolas_ready)
			{
				//legolas ready
				frame = 19;
			}
			else if (gunner.charge_state == GunnerParams::legolas_charging)
			{
				//in between shooting multiple legolas shots
				frame = 1;
			}
			getHUD().SetCursorFrame(frame);
		}

		// activate/throw

		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	gunner.charge_time = charge_time;
	gunner.charge_state = charge_state;
	gunner.has_bullet = hasbullet;


}

void onTick(CBlob@ this)
{
	GunnerInfo@ gunner;
	if (!this.get("gunnerInfo", @gunner))
	{
		return;
	}

	if (isKnocked(this) || this.isInInventory())
	{
		gunner.charge_state = 0;
		gunner.charge_time = 0;
		this.getSprite().SetEmitSoundPaused(true);
		getHUD().SetCursorFrame(0);
		return;
	}

	ManageGrapple(this, gunner);

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	ManageBow(this, gunner, moveVars);
}

bool checkGrappleStep(CBlob@ this, GunnerInfo@ gunner, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(gunner.grapple_pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			gunner.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(gunner, map, dist))
	{
		gunner.grapple_id = 0;

		gunner.grapple_ratio = Maths::Max(0.2, Maths::Min(gunner.grapple_ratio, dist / gunner_grapple_length));

		gunner.grapple_pos.y = Maths::Max(0.0, gunner.grapple_pos.y);

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(gunner.grapple_pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (gunner.grapple_ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					gunner.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic() && !b.hasTag("ignore_bullet"))
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				gunner.grapple_ratio = Maths::Max(0.2, Maths::Min(gunner.grapple_ratio, b.getDistanceTo(this) / gunner_grapple_length));

				gunner.grapple_id = b.getNetworkID();
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(GunnerInfo@ gunner, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(gunner.grapple_pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(gunner.grapple_pos + Vec2f(3, 0)) ||
	        map.isTileSolid(gunner.grapple_pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(gunner.grapple_pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(gunner.grapple_pos, "tree") !is null);   //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, GunnerInfo@ gunner, CMap@ map)
{
	return !grappleHitMap(gunner, map) || this.isKeyPressed(key_use);
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const bool hasbullet, const bool snipe = false)
{
	//time to fire!
	if (hasbullet && canSend(this))  // client-logic
	{
		Vec2f offset(this.isFacingLeft() ? 2 : -2, -2);
		ShootBullet(this, this.getPosition() + offset, this.getAimPos(), GunnerParams::shoot_max_vel, snipe);
	}
}

void ShootBullet(CBlob @this, Vec2f bulletPos, Vec2f aimpos, f32 bulletspeed, const bool snipe)
{
	if (canSend(this))
	{
		// player or bot
		f32 randomInn = 0.0f;
		if(!snipe)
		{
			randomInn = -8.0f + (( f32(XORRandom(2048)) / 2048.0f) * 16.0f);
		}

		Vec2f bulletVel = (aimpos - bulletPos).RotateBy(randomInn,Vec2f(0,0));
		bulletVel.Normalize();
		bulletVel *= bulletspeed;
		//print("bulletspeed " + bulletspeed);
		CBitStream params;
		params.write_Vec2f(bulletPos);
		params.write_Vec2f(bulletVel);

		this.SendCommand(this.getCommandID("shoot bullet"), params);
	}
}

CBlob@ CreateBullet(CBlob@ this, Vec2f bulletPos, Vec2f bulletVel)
{
	CBlob@ bullet = server_CreateBlobNoInit("bullet");
	if (bullet !is null)
	{
		bullet.SetDamageOwnerPlayer(this.getPlayer());
		bullet.Init();

		bullet.IgnoreCollisionWhileOverlapped(this);
		bullet.server_setTeamNum(this.getTeamNum());
		Vec2f bulletOffset = bulletVel;
		bulletOffset.Normalize();
		bullet.setPosition(bulletPos + bulletOffset * 4);
		bullet.setVelocity(bulletVel);
	}
	return bullet;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shoot bullet"))
	{
		Vec2f bulletPos;
		if (!params.saferead_Vec2f(bulletPos)) return;
		Vec2f bulletVel;
		if (!params.saferead_Vec2f(bulletVel)) return;
		
		// return to normal bullet - server didnt have this synced
		if (!hasBullets(this))
		{
			return;
		}

		if (getNet().isServer())
		{
			CreateBullet(this, bulletPos, bulletVel);
		}

		this.getSprite().PlaySound("M16Fire.ogg");
		this.TakeBlob("mat_bullets", 1);
	}
	else if (cmd == this.getCommandID(grapple_sync_cmd))
	{
		HandleGrapple(this, params, !canSend(this));
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		GunnerInfo@ gunner;
		if (!this.get("gunnerInfo", @gunner))
		{
			return;
		}
		if(gunner.charge_state != GunnerParams::not_aiming) return;
		u8 type = gunner.shoot_type;

		type++;
		if (type >= shootNames.length)
		{
			type = 0;
		}

		gunner.shoot_type = type;
		if (this.isMyPlayer())
		{
			Sound::Play("/CycleInventory.ogg");
		}
	}
	else
	{
		GunnerInfo@ gunner;
		if (!this.get("gunnerInfo", @gunner))
		{
			return;
		}
		if(gunner.charge_state != GunnerParams::not_aiming) return;
		for (uint i = 0; i < shootNames.length; i++)
		{
			if (cmd == this.getCommandID(shootNames[i]))
			{
				gunner.shoot_type = i;
				break;
			}
		}
	}
}

// bullet pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if (shootNames.length == 0)
	{
		return;
	}

	this.ClearGridMenusExceptInventory();
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 2 * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(shootNames.length, 2), getTranslatedString("Shoot type"));

	GunnerInfo@ gunner;
	if (!this.get("gunnerInfo", @gunner))
	{
		return;
	}
	const u8 actionSel = gunner.shoot_type;

	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		for (uint i = 0; i < shootNames.length; i++)
		{
			string shootName = shootNames[i];
			CGridButton @button = menu.AddButton(shootIcons[i], shootNames[i], this.getCommandID(shootName));

			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;

				//if (enabled && i == Shoot::fire && !hasReqs(this, i))
				//{
				//	button.hoverText = "Requires a fire source $lantern$";
				//	//button.SetEnabled( false );
				//}

				if (actionSel == i)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	GunnerInfo@ gunner;
	if (!this.get("gunnerInfo", @gunner))
	{
		return;
	}

	if (this.isAttached() && canSend(this))
	{
		gunner.grappling = false;
		SyncGrapple(this);
	}
}

// help
void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		if (itemname == "mat_bullets")
		{
			SetHelp(this, "help self action", "gunner", getTranslatedString("$Help_Bullet$Fire bullet   $KEY_HOLD$$LMB$"), "", 3);
		}
	}
}
