#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "KnightCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

//attacks limited to the one time per-actor before reset.

void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	KnightInfo knight;

	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.shieldTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.shield_down = getGameTime();
	knight.tileDestructionLimiter = 0;

	this.set("knightInfo", @knight);

	addShieldVars(this, SHIELD_BLOCK_ANGLE, 2.0f, 5.0f);
	knight_actorlimit_setup(this);

}

void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);

	if (this.isInInventory())
		return;

	//knight logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	
	bool shieldState = isShieldState(knight.state);
	if(shieldState)this.Tag("shielding");
	else this.Untag("shielding");
	bool specialShieldState = isSpecialShieldState(knight.state);
	bool swordState = isSwordState(knight.state);
	
	int equipMain = this.get_u16("marm_equip");
	int equipSub = this.get_u16("sarm_equip");
	bool canUseMain = isLimbUsable(this,this.get_u8("marm_type"));
	bool canUseSub = isLimbUsable(this,this.get_u8("sarm_type"));
	bool pressed_a1 = false;
	bool just_pressed_a1 = false;
	bool just_release_a1 = false;
	f32 Damage = 2.0f;
	f32 slashForce = 0.8f;
	
	if(equipMain == Equipment::GreatSword){
		slashForce = 1.0f;
		if(this.get_u16("marm_equip_type") == 2){
			slashForce = 2.0f;
			this.Tag("has_shadow_sword");
		}
	}
	this.Untag("has_shadow_sword");
	
	if(canUseMain)if(equipMain == Equipment::Sword || equipMain == Equipment::GreatSword){
		if(this.isKeyPressed(key_action1))pressed_a1 = true;
		if(this.isKeyJustPressed(key_action1))just_pressed_a1 = true;
		if(this.isKeyJustReleased(key_action1))just_release_a1 = true;
		
		Damage = getEquipmentDamage(this.get_u16("marm_equip"),this.get_u16("marm_equip_type"))*getLimbStrength(this.get_u8("marm_type"));
	}
	if(canUseSub)if(equipSub == Equipment::Sword || equipSub == Equipment::GreatSword){
		if(this.isKeyPressed(key_action2))pressed_a1 = true;
		if(this.isKeyJustPressed(key_action2))just_pressed_a1 = true;
		if(this.isKeyJustReleased(key_action2))just_release_a1 = true;
		
		Damage = getEquipmentDamage(this.get_u16("sarm_equip"),this.get_u16("sarm_equip_type"))*getLimbStrength(this.get_u8("sarm_type"));
	}
	bool pressed_a2 = (equipSub == Equipment::Shield && canUseSub && this.isKeyPressed(key_action2)) || (equipMain == Equipment::Shield && canUseMain && this.isKeyPressed(key_action1));
	bool released_a2 = (equipSub == Equipment::Shield && canUseSub && this.isKeyJustReleased(key_action2)) || (equipMain == Equipment::Shield && canUseMain && this.isKeyJustReleased(key_action1));
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	if(this.getCarriedBlob() !is null){
		if(this.getCarriedBlob().hasTag("tool")){
			if(this.isKeyPressed(key_action1)){
				pressed_a1 = false;
				just_pressed_a1 = false;
				just_release_a1 = false;
				pressed_a2 = false;
				released_a2 = false;
			}
		}
	}
	
	if(swordState){
		if(knight.state == KnightStates::sword_drawn){
			if (knight.swordTimer < KnightVars::slash_charge){
				this.set_s8("sword_state",KnightStates::sword_drawn);
			} else if (knight.swordTimer < KnightVars::slash_charge_level2){
				this.set_s8("sword_state",-1);
			} else {
				this.set_s8("sword_state",-2);
			}
		} else {
			this.set_s8("sword_state",knight.state);
		}
		this.set_f32("sword_ratio",f32(knight.swordTimer)/f32(KnightVars::slash_charge));
	} else this.set_s8("sword_state",KnightStates::normal);
	
	const bool myplayer = this.isMyPlayer();

	//with the code about menus and myplayer you can slash-cancel;
	//we'll see if knights dmging stuff while in menus is a real issue and go from there
	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{
		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.shieldTimer = 0;
		knight.slideTime = 0;
		knight.doubleslash = false;

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	else if (!pressed_a1 && !swordState &&
	         (pressed_a2 || (specialShieldState)))
	{
		moveVars.jumpFactor *= 0.5f;
		moveVars.walkFactor *= 0.9f;
		knight.swordTimer = 0;

		if (!canRaiseShield(this))
		{
			if (knight.state != KnightStates::normal)
			{
				knight.shield_down = getGameTime() + 40;
			}

			knight.state = KnightStates::normal;

			if (pressed_a2 && ((knight.shield_down - getGameTime()) <= 0))
			{
				resetShieldKnockdown(this);   //re-put up the shield
			}
		}
		else
		{
			bool forcedrop = (vel.y > Maths::Max(Maths::Abs(vel.x), 2.0f) &&
			                  moveVars.fallCount > KnightVars::glide_down_time);

			if (pressed_a2 && inair && !this.isInWater())
			{
				if (direction == -1 && !forcedrop && !getMap().isInWater(pos + Vec2f(0, 16)) && !moveVars.wallsliding)
				{
					knight.state = KnightStates::shieldgliding;
					knight.shieldTimer = 1;
				}
				else if (forcedrop || direction == 1)
				{
					knight.state = KnightStates::shielddropping;
					knight.shieldTimer = 5;
					knight.slideTime = 0;
				}
				else //remove this for partial locking in mid air
				{
					knight.state = KnightStates::shielding;
				}
			}

			if (knight.state == KnightStates::shieldgliding && !this.isInWater() && !forcedrop)
			{
				moveVars.stoppingFactor *= 0.5f;

				f32 glide_amount = 1.0f - (moveVars.fallCount / f32(KnightVars::glide_down_time * 2));

				if (vel.y > 0.0f)
				{
					this.AddForce(Vec2f(0, -20.0f * glide_amount));
				}

				if (!inair || !pressed_a2)
				{
					knight.state = KnightStates::shielding;
				}
			}
			else if (knight.state == KnightStates::shielddropping)
			{
				if (this.isInWater())
				{
					if (vel.y > 1.5f && Maths::Abs(vel.x) * 3 > Maths::Abs(vel.y))
					{
						vel.y = Maths::Max(-Maths::Abs(vel.y) + 1.0f, -8.0);
						this.setVelocity(vel);
					}
					else
					{
						knight.state = KnightStates::shielding;
					}
				}

				// shield sliding and end of slide
				if ((!inair && this.getShape().vellen < 1.0f) || !pressed_a2)
				{
					knight.state = KnightStates::shielding;
				}
				else
				{
					// faster sliding
					if (!inair)
					{
						knight.slideTime++;
						if (knight.slideTime > 0)
						{
							if (knight.slideTime == 5)
							{
								this.getSprite().PlayRandomSound("/Scrape");
							}

							f32 factor = Maths::Max(1.0f, 2.2f / Maths::Sqrt(knight.slideTime));
							moveVars.walkFactor *= factor;

							//  printf("knight.slideTime = " + knight.slideTime  );
							if (knight.slideTime > 30)
							{
								moveVars.walkFactor *= 0.75f;
								if (knight.slideTime > 45)
								{
									knight.state = KnightStates::shielding;
								}
							}
							else if (XORRandom(3) == 0)
							{
								Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 70 : 110, 4.3f, 40.0f);
								velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
								ParticlePixel(pos, velr, SColor(255, 255, 255, 0), true);
							}
						}
					}
					else if (vel.y > 1.05f)
					{
						knight.slideTime = 0;
						//printf("vel.y  " + vel.y  );
					}
				}
			}
			else
			{
				knight.state = KnightStates::shielding;
				knight.shieldTimer = 2;
			}
		}
	}
	else if ((pressed_a1 || swordState) && !moveVars.wallsliding)   //no attacking during a slide
	{
		if (getNet().isClient())
		{
			if (knight.swordTimer == KnightVars::slash_charge_level2)
			{
				Sound::Play("AnimeSword.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
			else if (knight.swordTimer == KnightVars::slash_charge)
			{
				Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
			}
		}

		if (knight.swordTimer >= KnightVars::slash_charge_limit)
		{
			Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			SetKnocked(this, 15);
		}

		bool strong = (knight.swordTimer > KnightVars::slash_charge_level2);
		moveVars.jumpFactor *= (strong ? 0.6f : 0.8f);
		moveVars.walkFactor *= (strong ? 0.8f : 0.9f);
		knight.shieldTimer = 0;

		if (!inair)
		{
			this.AddForce(Vec2f(vel.x * -5.0, 0.0f));   //horizontal slowing force (prevents SANICS)
		}

		if (knight.state == KnightStates::normal ||
		        just_pressed_a1 &&
		        (!inMiddleOfAttack(knight.state) || shieldState))
		{
			knight.state = KnightStates::sword_drawn;
			knight.swordTimer = 0;
		}

		if (knight.state == KnightStates::sword_drawn && getNet().isServer())
		{
			knight_clear_actor_limits(this);
		}

		//responding to releases/noaction
		s32 delta = knight.swordTimer;
		if (knight.swordTimer < 128)
			knight.swordTimer++;

		if (knight.state == KnightStates::sword_drawn && !pressed_a1 &&
		        !just_release_a1 && delta > KnightVars::resheath_time)
		{
			knight.state = KnightStates::normal;
		}
		else if (just_release_a1 && knight.state == KnightStates::sword_drawn)
		{
			knight.swordTimer = 0;

			if (delta < KnightVars::slash_charge)
			{
				if (direction == -1)
				{
					knight.state = KnightStates::sword_cut_up;
				}
				else if (direction == 0)
				{
					if (aimpos.y < pos.y)
					{
						knight.state = KnightStates::sword_cut_mid;
					}
					else
					{
						knight.state = KnightStates::sword_cut_mid_down;
					}
				}
				else
				{
					knight.state = KnightStates::sword_cut_down;
				}
			}
			else if (delta < KnightVars::slash_charge_level2)
			{
				knight.state = KnightStates::sword_power;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else if (delta < KnightVars::slash_charge_limit)
			{
				knight.state = KnightStates::sword_power_super;
				Vec2f aiming_direction = vel;
				aiming_direction.y *= 2;
				aiming_direction.Normalize();
				knight.slash_direction = aiming_direction;
			}
			else
			{
				//knock?
			}
		}
		else if (knight.state >= KnightStates::sword_cut_mid &&
		         knight.state <= KnightStates::sword_cut_down) // cut state
		{
			this.Tag("prevent crouch");

			if (delta == DELTA_BEGIN_ATTACK)
			{
				Sound::Play("/SwordSlash", this.getPosition());
			}

			if (delta > DELTA_BEGIN_ATTACK && delta < DELTA_END_ATTACK)
			{
				f32 attackarc = 90.0f;
				f32 attackAngle = getCutAngle(this, knight.state);

				if (knight.state == KnightStates::sword_cut_down)
				{
					attackarc *= 0.9f;
				}

				DoAttack(this, Damage*0.5f, attackAngle, attackarc, DEFAULT_ATTACK_DISTANCE, Hitters::sword, delta, knight);
			}
			else if (delta >= 9)
			{
				knight.swordTimer = 0;
				knight.state = KnightStates::sword_drawn;
			}
		}
		else if (knight.state == KnightStates::sword_power ||
		         knight.state == KnightStates::sword_power_super)
		{
			this.Tag("prevent crouch");

			//setting double
			if (knight.state == KnightStates::sword_power_super &&
			        just_pressed_a1)
			{
				knight.doubleslash = true;
			}

			//attacking + noises
			if (delta == 2)
			{
				if(equipMain == Equipment::GreatSword && this.get_u16("marm_equip_type") == 2 && this.isKeyPressed(key_action2)){
					this.getSprite().PlaySound("ShadowBlade"+(XORRandom(3)+1)+".ogg", 3.0f);
				} else {
					Sound::Play("/ArgLong", this.getPosition());
					Sound::Play("/SwordSlash", this.getPosition());
				}
			}
			else if (delta > DELTA_BEGIN_ATTACK && delta < 10)
			{
				if(equipMain == Equipment::GreatSword && this.get_u16("marm_equip_type") == 2 && this.isKeyPressed(key_action2))DoAttack(this, Damage, -(vec.Angle()), 180.0f, 48.0f, Hitters::sword, delta, knight);
				else DoAttack(this, Damage, -(vec.Angle()), 120.0f, DEFAULT_ATTACK_DISTANCE, Hitters::sword, delta, knight);
			}
			else if (delta >= KnightVars::slash_time ||
			         (knight.doubleslash && delta >= KnightVars::double_slash_time))
			{
				knight.swordTimer = 0;

				if (knight.doubleslash)
				{
					knight_clear_actor_limits(this);
					knight.doubleslash = false;
					knight.state = KnightStates::sword_power;
				}
				else
				{
					knight.state = KnightStates::sword_drawn;
				}
			}
		}

		//special slash movement

		if ((knight.state == KnightStates::sword_power ||
		        knight.state == KnightStates::sword_power_super) &&
		        delta < KnightVars::slash_move_time)
		{

			Vec2f slash_vel = this.getAimPos()-this.getPosition();
			slash_vel.Normalize();
			slash_vel.y *= 0.5f;
			this.AddForce(slash_vel * this.getMass() * slashForce );
		}

		moveVars.canVault = false;

	}
	else if (released_a2 || just_release_a1 || this.get_u32("knight_timer") <= getGameTime())
	{
		knight.state = KnightStates::normal;
	}

	//setting the shield direction properly
	if (shieldState)
	{
		int horiz = this.isFacingLeft() ? -1 : 1;
		setShieldEnabled(this, true);

		setShieldAngle(this, SHIELD_BLOCK_ANGLE);

		if (specialShieldState)
		{
			if (knight.state == KnightStates::shieldgliding)
			{
				setShieldDirection(this, Vec2f(0, -1));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_GLIDING);
			}
			else //shield dropping
			{
				setShieldDirection(this, Vec2f(horiz, 2));
				setShieldAngle(this, SHIELD_BLOCK_ANGLE_SLIDING);
			}
			this.Tag("prevent crouch");
		}
		else if (walking)
		{
			if (direction == 0) //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else
			{
				setShieldDirection(this, Vec2f(horiz, -3));
			}

			this.Tag("prevent crouch");
		}
		else
		{
			if (direction == 0)   //forward
			{
				setShieldDirection(this, Vec2f(horiz, 0));
			}
			else if (direction == 1)   //down
			{
				setShieldDirection(this, Vec2f(horiz, 3));
			}
			else //up
			{
				if (vec.y < -0.97)
				{
					setShieldDirection(this, Vec2f(0, -1));
				}
				else
				{
					setShieldDirection(this, Vec2f(horiz, -3));
				}
			}
		}

		// shield up = collideable

		if ((knight.state == KnightStates::shielding && direction == -1) ||
		        knight.state == KnightStates::shieldgliding)
		{
			if (!this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Tag("shieldplatform");
			}
		}
		else
		{
			if (this.hasTag("shieldplatform"))
			{
				this.getShape().checkCollisionsAgain = true;
				this.Untag("shieldplatform");
			}
		}
	}
	else
	{
		setShieldEnabled(this, false);

		if (this.hasTag("shieldplatform"))
		{
			this.getShape().checkCollisionsAgain = true;
			this.Untag("shieldplatform");
		}
	}

	if (!swordState && getNet().isServer())
	{
		knight_clear_actor_limits(this);
	}


}

bool isJab(f32 damage)
{
	return damage < 1.5f;
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, f32 distance, u8 type, int deltaInt, KnightInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(distance + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), (MAX_ATTACK_DISTANCE-DEFAULT_ATTACK_DISTANCE+distance));

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;
	const bool jab = isJab(damage);

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				if (b.hasTag("ignore sword")) continue;

				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (knight_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				knight_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
				if (!dontHitMoreMap && (deltaInt == DELTA_BEGIN_ATTACK + 1))
				{
					bool ground = map.isTileGround(hi.tile);
					bool dirt_stone = map.isTileStone(hi.tile);
					bool gold = map.isTileGold(hi.tile);
					bool wood = map.isTileWood(hi.tile);
					if (ground || wood || dirt_stone || gold)
					{
						Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
						Vec2f offset = (tpos - blobPos);
						f32 tileangle = offset.Angle();
						f32 dif = Maths::Abs(exact_aimangle - tileangle);
						if (dif > 180)
							dif -= 360;
						if (dif < -180)
							dif += 360;

						dif = Maths::Abs(dif);
						//print("dif: "+dif);

						if (dif < 20.0f)
						{
							//detect corner

							int check_x = -(offset.x > 0 ? -1 : 1);
							int check_y = -(offset.y > 0 ? -1 : 1);
							if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
							        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
								continue;

							bool canhit = true; //default true if not jab
							if (jab) //fake damage
							{
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);
							}
							else //reset fake dmg for next time
							{
								info.tileDestructionLimiter = 0;
							}

							//dont dig through no build zones
							canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

							dontHitMoreMap = true;
							if (canhit)
							{
								map.server_DestroyTile(hi.hitpos, 0.1f, this);
								if (gold)
								{
									// Note: 0.1f damage doesn't harvest anything I guess
									// This puts it in inventory - include MaterialCommon
									//Material::fromTile(this, hi.tile, 1.f);

									CBlob@ ore = server_CreateBlobNoInit("mat_gold");
									if (ore !is null)
									{
										ore.Tag('custom quantity');
	     								ore.Init();
	     								ore.setPosition(pos);
	     								ore.server_SetQuantity(4);
	     							}
								}
							}
						}
					}
				}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) &&    // aiming down or slash
	        (deltaInt == DELTA_BEGIN_ATTACK + 1)) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, this);

					if (damage <= 1.0f)
					{
						return;
					}
				}
			}
	}
}

bool isSliding(KnightInfo@ knight)
{
	return (knight.slideTime > 0 && knight.slideTime < 45);
}

// shieldbash

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	//return if we didn't collide or if it's teamie
	if (blob is null || !solid || this.getTeamNum() == blob.getTeamNum())
	{
		return;
	}

	const bool onground = this.isOnGround();
	if (this.getShape().vellen > SHIELD_KNOCK_VELOCITY || onground)
	{
		KnightInfo@ knight;
		if (!this.get("knightInfo", @knight))
		{
			return;
		}

		//printf("knight.stat " + knight.state );
		if (knight.state == KnightStates::shielddropping &&
		        (!onground || isSliding(knight)) &&
		        (blob.getShape() !is null && !blob.getShape().isStatic()) &&
		        getKnocked(blob) == 0)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getOldVelocity();
			vel.Normalize();

			//printf("nor " + vel * normal );
			if (vel * normal < 0.0f && knight_hit_actor_count(this) == 0) //only bash one thing per tick
			{
				ShieldVars@ shieldVars = getShieldVars(this);
				//printf("shi " + shieldVars.direction * normal );
				if (shieldVars.direction * normal < 0.0f)
				{
					knight_add_actor_limit(this, blob);
					this.server_Hit(blob, pos, vel, 0.0f, Hitters::shield);

					Vec2f force = Vec2f(shieldVars.direction.x * this.getMass(), -this.getMass()) * 3.0f;

					blob.AddForce(force);
					this.AddForce(Vec2f(-force.x, force.y));
				}
			}
		}
	}
}


//a little push forward

void pushForward(CBlob@ this, f32 normalForce, f32 pushingForce, f32 verticalForce)
{
	f32 facing_sign = this.isFacingLeft() ? -1.0f : 1.0f ;
	bool pushing_in_facing_direction =
	    (facing_sign < 0.0f && this.isKeyPressed(key_left)) ||
	    (facing_sign > 0.0f && this.isKeyPressed(key_right));
	f32 force = normalForce;

	if (pushing_in_facing_direction)
	{
		force = pushingForce;
	}

	this.AddForce(Vec2f(force * facing_sign , verticalForce));
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	KnightInfo@ knight;
	if (!this.get("knightInfo", @knight))
	{
		return;
	}

	if (customData == Hitters::sword &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            knight.state == KnightStates::sword_cut_mid ||
	            knight.state == KnightStates::sword_cut_mid_down ||
	            knight.state == KnightStates::sword_cut_up ||
	            knight.state == KnightStates::sword_cut_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 20);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	if (!ap.socket) {
		KnightInfo@ knight;
		if (!this.get("knightInfo", @knight))
		{
			return;
		}

		knight.state = KnightStates::normal; //cancel any attacks or shielding
		knight.swordTimer = 0;
		knight.doubleslash = false;
	}
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
