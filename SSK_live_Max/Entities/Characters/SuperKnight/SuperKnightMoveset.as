#include "FighterMovesetCommon.as"
#include "ParticleSparks.as";

// Knight moveset data

void onInit(CRules@ this)
{
	InitializeMovesets(this);
}

// Example format for MoveFrame constructor:
// MoveFrame(u16 _spriteFrameNum, u8 _holdTime = 1, f32 _attackAngle = 0.0f, f32 _attackArc = 0.0f, f32 _attackRange = 0.0f, f32 _damage = 0.0f, bool _isGrabFrame = false)
// or
// MoveFrame(FrameLogic _frameLogic, u16 _spriteFrameNum, u8 _holdTime = 1, f32 _attackAngle = 0.0f, f32 _attackArc = 0.0f, f32 _attackRange = 0.0f, f32 _damage = 0.0f, bool _isGrabFrame = false)

// Example format for FrameLogic constructor:
// FrameLogic(FIGHTER_CALLBACK @_onBegin, FIGHTER_CALLBACK @_onExecute, FIGHTER_CALLBACK @_onEnd)
void InitializeMovesets(CRules@ this)
{
	// MOVESET
	MoveAnimation[] Moveset;

	// Shield
	MoveFrame@[] MoveFrames_Shield;
	MoveFrames_Shield.push_back(MoveFrame(41, 1));
	MoveFrames_Shield.push_back(MoveFrame(12, 1));
	MoveFrames_Shield.push_back(MoveFrame(FrameLogic(null, MovesetFuncs::Shield::shieldActivationLogic, null), 12, 4));
	MoveFrames_Shield.push_back(MoveFrame(12, 3));
	MoveFrames_Shield.push_back(MoveFrame(41, 3));
	Moveset.push_back(MoveAnimation("Shield", MoveTypes::SHIELD, MoveFrames_Shield));

	// Grab Attack
	MoveFrame@[] MoveFrames_GrabAttack;
	MoveFrames_GrabAttack.push_back(MoveFrame(64, 4));
	MoveFrames_GrabAttack.push_back(MoveFrame(66, 3));
	MoveFrames_GrabAttack.push_back(MoveFrame(FrameLogic(null, null, MovesetFuncs::Grab::playSound), 68, 3));
	MoveFrames_GrabAttack.push_back(MoveFrame(68, 2, 0.0f, 140.0f, 16.0f, 0.0f, true));
	MoveFrames_GrabAttack.push_back(MoveFrame(68, 2, 0.0f, 140.0f, 20.0f, 0.0f, true));
	MoveFrames_GrabAttack.push_back(MoveFrame(67, 4));
	MoveFrames_GrabAttack.push_back(MoveFrame(66, 3));
	MoveFrames_GrabAttack.push_back(MoveFrame(65, 3));
	MoveFrames_GrabAttack.push_back(MoveFrame(64, 3));
	Moveset.push_back(MoveAnimation("Grab Attack", MoveTypes::GRAB_ATTACK, MoveFrames_GrabAttack));

	// Grab Item
	MoveFrame@[] MoveFrames_GrabItem;
	MoveFrames_GrabItem.push_back(MoveFrame(68, 2));
	MoveFrames_GrabItem.push_back(MoveFrame(67, 2));
	MoveFrames_GrabItem.push_back(MoveFrame(66, 2));
	MoveFrames_GrabItem.push_back(MoveFrame(65, 2));
	MoveFrames_GrabItem.push_back(MoveFrame(64, 2));
	Moveset.push_back(MoveAnimation("Grab Item", MoveTypes::GRAB_ITEM, MoveFrames_GrabItem));

	// Throw
	MoveFrame@[] MoveFrames_Throw;
	MoveFrames_Throw.push_back(MoveFrame(69, 2));
	MoveFrames_Throw.push_back(MoveFrame(24, 1));
	MoveFrames_Throw.push_back(MoveFrame(70, 1));
	MoveFrames_Throw.push_back(MoveFrame(29, 2));
	MoveFrames_Throw.push_back(MoveFrame(71, 6));
	Moveset.push_back(MoveAnimation("Throw", MoveTypes::THROW, MoveFrames_Throw));

	// Sword Hop
	MoveFrame@[] MoveFrames_SwordHop;
	MoveFrames_SwordHop.push_back(MoveFrame(FrameLogic(null, DownAerial::slowDescent, null), 52, 6));
	MoveFrames_SwordHop.push_back(MoveFrame(45, 2));
	MoveFrames_SwordHop.push_back(MoveFrame(FrameLogic(null, null, DownAerial::playStabSound), 46, 2));
	MoveFrames_SwordHop.push_back(MoveFrame(FrameLogic(null, DownAerial::swordHop, null), 72, 25));
	MoveFrames_SwordHop.push_back(MoveFrame(72, 5));
	MoveFrames_SwordHop.push_back(MoveFrame(46, 5));
	MoveFrames_SwordHop.push_back(MoveFrame(45, 5));
	Moveset.push_back(MoveAnimation("Sword Hop", MoveTypes::DOWN_SPECIAL, MoveFrames_SwordHop));

	// Fire Strike
	MoveFrame@[] MoveFrames_FireStrike;
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(FireStrike::chargeSound, FireStrike::chargeUp, null), 8, 25));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(FireStrike::attackStart, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(null, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(null, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(null, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(null, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(FrameLogic(null, FireStrike::attackUpdate, null), 38, 4));
	MoveFrames_FireStrike.push_back(MoveFrame(22, 10));
	Moveset.push_back(MoveAnimation("Fire Strike", MoveTypes::UP_SPECIAL, MoveFrames_FireStrike));

	this.set("fighterMoveset"+FighterClasses::KNIGHT, Moveset);
}

// Down Aerial Attack functions
namespace DownAerial
{
	void slowDescent(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		Vec2f vel = fighterBlob.getVelocity();

		fighterVars.fallSpecial = false;

		f32 maxFallSpeed = 5.0f;
		fighterBlob.setVelocity(Vec2f(0.0f, -maxFallSpeed));
	}

	void playStabSound(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		fighterBlob.getSprite().PlaySound("heavystab1.ogg", 1.0f);

		fighterBlob.set_u16("hit cooldown", 0);
		fighterBlob.set_bool("do sword hop", false);

		fighterBlob.Sync("hit cooldown", true);
		fighterBlob.Sync("do sword hop", true);
	}

	void swordHop(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		Vec2f vel = fighterBlob.getVelocity();

		// stop fast falling
		fighterVars.fastFalling = false;

		// moving left/right while in air
		f32 MOVE_FORCE = 12.0f;
		f32 MAX_SPEED = 5.0f;
		if (fighterBlob.isKeyPressed(key_right))
		{	
			if (vel.x <= MAX_SPEED)
				fighterBlob.AddForce(Vec2f(MOVE_FORCE,0));
		}
		if (fighterBlob.isKeyPressed(key_left))
		{
			if (vel.x >= -MAX_SPEED)
				fighterBlob.AddForce(Vec2f(-MOVE_FORCE,0));
		}

		bool hitGround = false;
		Vec2f groundHitPos;
		bool hitEnemy = false;
		bool hitOther = false;

		fighterBlob.setVelocity(Vec2f(vel.x, 10.0f));

		u16 hitCooldown = fighterBlob.get_u16("hit cooldown");
		if (hitCooldown <= 0)
		{
			if (vel.y >= 0)
			{
				FighterHitData fighterHitData(8, 3.0f, 0.06f, 30);
				fighterHitData.soundEffect = "swordhit_heavy.ogg";

				Vec2f thisPos = fighterBlob.getPosition();
				Vec2f aimVec(1, 0);
				aimVec.RotateBy(90.0f);	// aim downward
				Vec2f pos = thisPos + vel;
				
				CMap@ map = fighterBlob.getMap();

				//get the actual aim angle
				f32 exact_aimangle = (fighterBlob.getAimPos() - thisPos).Angle();

				// this gathers HitInfo objects which contain blob or tile hit information
				HitInfo@[] hitInfos;
				if (map.getHitInfosFromArc(pos, 90.0f, 60.0f, 18.0f, fighterBlob, @hitInfos))
				{
					//HitInfo objects are sorted, first come closest hits
					for (uint i = 0; i < hitInfos.length; i++)
					{
						HitInfo@ hi = hitInfos[i];
						CBlob@ b = hi.blob;
						if (b !is null) // blob
						{
							if (b.hasTag("ignore sword")) continue;

							if (!canAttackHit(fighterBlob, b))
							{
								continue;
							}

							Vec2f velocity = Vec2f(0,1);
							server_fighterHit(fighterBlob, b, hi.hitpos, velocity, 16.0f, Hitters::sword, true, fighterHitData);	// server_fighterHit() is server-side only

							if (b.hasTag("player"))
							{
								hitEnemy = true;
							}
							if (b.hasTag("item"))
							{
								hitOther = true;
							}

							if (b.isCollidable() && b.getShape().isStatic())
							{
								Vec2f hitPos = hi.hitpos;

								// check if ground is directly beneath the fighter
								if (Maths::Abs(hitPos.x - thisPos.x) <= 4.0f)
								{
									hitGround = true;
									groundHitPos = hitPos;
								}
							}
						}
						else	// hitmap
						{
							bool isTileSolid = map.isTileSolid(hi.tile);
							if (isTileSolid)
							{	
								Vec2f hitPos = hi.hitpos;

								// check if ground is directly beneath the fighter
								if (Maths::Abs(hitPos.x - thisPos.x) <= 4.0f)
								{
									hitGround = true;
									groundHitPos = hitPos;
								}
							}
						}
					}
				}
			}
		}
		else
		{
			hitCooldown--;
			fighterBlob.set_u16("hit cooldown", hitCooldown);
			fighterBlob.Sync("hit cooldown", true);
		}

		// cancel animation when hitting the ground
		if (hitGround || hitEnemy)
		{
			if (!hitEnemy)
			{
				fighterVars.currMoveFrameTimer = 0;

				if (hitGround)
				{
					fighterBlob.getSprite().PlaySound("downairslam1.ogg", 0.5f);
					CParticle@ p = ParticleAnimated("impact2.png", fighterBlob.getPosition()+Vec2f(0,-4.0f), Vec2f_zero, 0.0f, 0.5f, 3, 0.0f, true);
					if (p !is null)
					{
						p.Z = 100.0f;
					}
				}
			}
			else
			{
				fighterBlob.set_u16("hit cooldown", 6);
				fighterBlob.Sync("hit cooldown", true);
			}
			
			int amountSparks = 5 + XORRandom(5);
			for (int i = 0; i < amountSparks; i++)
			{
				Vec2f sparkVel = getRandomVelocity(90.0f, 3.0f, 180.0f);
				sparkVel.y = -Maths::Abs(sparkVel.y) + Maths::Abs(sparkVel.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
				ParticlePixel(groundHitPos, sparkVel, SColor(255, 250, 250, 255), true);
			}
		}
		else if (hitOther)
		{
			fighterBlob.getSprite().PlaySound("swordcling1.ogg", 1.0f);
		}

		fighterVars.runAutoTickFunc("down aerial sword", showSwordLayer, hideSwordLayer, true);
	}

	void showSwordLayer(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		CSprite@ sprite = fighterBlob.getSprite();

		CSpriteLayer@ swordPoke = sprite.getSpriteLayer("sword poke");
		if (swordPoke != null)
		{
			swordPoke.SetVisible(true);

			if (fighterBlob.getVelocity().y >= 0)
			{
				swordPoke.SetAnimation("blink");
			}
			else
			{
				swordPoke.SetAnimation("default");
			}
		}
		else
		{
			CSpriteLayer@ swordPoke = sprite.addSpriteLayer("sword poke", "effect_swordpoke.png" , 16, 16, 0, 0);
			if (swordPoke !is null)
			{
				{
					Animation@ anim = swordPoke.addAnimation("default", 1, false);

					int[] frames = {0};
					anim.AddFrames(frames);
				}

				{
					Animation@ anim = swordPoke.addAnimation("blink", 1, true);

					int[] frames = {0, 1};
					anim.AddFrames(frames);
				}

				swordPoke.SetVisible(true);
				swordPoke.SetOffset(Vec2f(0,14));
				swordPoke.SetRelativeZ(2.0f);
			}
		}
	}

	void hideSwordLayer(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		CSprite@ sprite = fighterBlob.getSprite();

		// hide sprite layer effect
		CSpriteLayer@ swordPoke = sprite.getSpriteLayer("sword poke");
		if (swordPoke != null)
		{
			swordPoke.SetVisible(false);
		}
	}
}

// Fire Strike functions
namespace FireStrike
{
	void chargeSound(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		fighterBlob.getSprite().PlaySound("charge1.ogg", 1.5f);
		fighterVars.fallSpecial = true;
	}

	void chargeUp(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		fighterVars.gravityEnabled = false;

		f32 aimAngle = -(fighterBlob.getAimPos() - fighterBlob.getPosition()).Angle();
		fighterBlob.set_f32("fire strike angle", aimAngle);
		fighterBlob.Sync("fire strike angle", true);

		fighterBlob.setAngleDegrees(aimAngle + 90.0f);	

		fighterBlob.setVelocity( Vec2f(0, 0) );

		// effects
		if (getNet().isClient()) 
		{
			if (fighterVars.currMoveFrameTimer % 7 == 0)
			{
				CParticle@ p = ParticleAnimated( "sparkle2-small-yellow.png", fighterBlob.getPosition(), Vec2f(0,0), float(XORRandom(360)), 1.0f, 2, 0.0f, false );
				if ( p !is null)
				{
					if (XORRandom(2) == 0)
					{
						p.Z = 100.0f;
					}
					else
					{
						p.Z = -100.0f;
					}
				}				
			}
		}
	}

	void attackUpdate(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		fighterVars.gravityEnabled = false;

		f32 moveAngle = fighterBlob.get_f32("fire strike angle");

		f32 vel = 6.0f;
		Vec2f moveVec = Vec2f(1,0).RotateBy(moveAngle);
		fighterBlob.setVelocity( moveVec*vel );

		fighterBlob.setAngleDegrees(moveAngle + 90.0f);

		if (!fighterVars.hasAttackedOnCurrFrame)
		{
			FighterHitData fighterHitData(2, 2.0f, 0.06f);
			arcAttack(fighterBlob, false, 4.0f, moveAngle, 140.0f, 20.0f, Hitters::sword, fighterHitData);
		}

		// effects
		if( getNet().isClient() ) 
		{
			f32 moveAngle = fighterBlob.get_f32("fire strike angle");
			Vec2f moveVec = Vec2f(1,0).RotateBy(moveAngle);

			const f32 rad = 5.0f;
			Vec2f random1 = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
			CParticle@ rocketP = ParticleAnimated( "genericsmoke1.png", fighterBlob.getPosition() + moveVec*2.0f + random1, Vec2f(0,0), float(XORRandom(360)), 1.0f, 4 + XORRandom(3), 0.0f, false );
			if ( rocketP !is null)
			{
				rocketP.setRenderStyle(RenderStyle::additive);
				if (XORRandom(2) == 0)
				{
					rocketP.Z = 100.0f;
				}
				else
				{
					rocketP.Z = -100.0f;
				}
			}
			
			fighterVars.runAutoTickFunc("fire aura", showAuraEffect, hideAuraEffect, true);
		}
	}

	void showAuraEffect(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		CSprite@ sprite = fighterBlob.getSprite();

		const u8 animTime = 3;

		CSpriteLayer@ fireStrikeAura = sprite.getSpriteLayer("fire strike aura");
		if (fireStrikeAura != null)
		{
			fireStrikeAura.SetVisible(true);

			Animation@ anim = fireStrikeAura.animation;
			if (anim !is null)
			{
				if (fighterVars.hitstunTime > 0)
					anim.time = 0;
				else
					anim.time = animTime;
			}
		}
		else
		{
			CSpriteLayer@ fireStrikeAura = sprite.addSpriteLayer("fire strike aura", "aura5-orange.png" , 48, 48, 0, 0);
			if (fireStrikeAura !is null)
			{
				Animation@ anim = fireStrikeAura.addAnimation("default", animTime, true);

				int[] frames = {0, 1, 2, 3};
				anim.AddFrames(frames);

				fireStrikeAura.SetVisible(true);
				fireStrikeAura.SetOffset(Vec2f(0,2));
				fireStrikeAura.SetRelativeZ(2.0f);
			}
		}
	}

	void hideAuraEffect(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		CSprite@ sprite = fighterBlob.getSprite();

		// hide sprite layer effect
		CSpriteLayer@ fireStrikeAura = sprite.getSpriteLayer("fire strike aura");
		if (fireStrikeAura != null)
		{
			fireStrikeAura.SetVisible(false);
		}
	}

	void attackStart(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
	{
		if (getNet().isServer())
		{
			fighterBlob.Sync("fire strike angle", true);
		}

		if( getNet().isClient() ) 
		{
			fighterBlob.getSprite().PlaySound("specialattack1.ogg", 1.5f, 1.0f);	
		}
	}
}