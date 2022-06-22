// Runner Movement Walking

#include "SSKRunnerCommon.as"
#include "FighterVarsCommon.as"
#include "MakeDustParticle.as"
#include "FallDamageCommon.as"
#include "SSKExplosion.as"

const f32 GRAVITY = 0.5f;
const f32 TERMINAL_VEL = 5.0f;

const f32 FRICTION_FACTOR_TUMBLING = 0.98f;
const f32 GRAVITY_TUMBLING = 0.2f;
const u32 MIN_TUMBLE_TIME_BEFORE_RECOVER = 40;

const f32 FAST_FALL_SPEED = 7.0f;

void onInit(CMovement@ this)
{
	CBlob@ blob = this.getBlob();

	// explosion variables for when hitting walls
	blob.set_f32("map_damage_radius", 12.0f);
	blob.set_f32("map_damage_ratio", 1.0f);
	blob.set_string("custom_explosion_sound", "flame2.ogg");

	this.getCurrentScript().removeIfTag = "dead";

	// add tumble jet sprite layer
	CSprite@ sprite = blob.getSprite();
	sprite.RemoveSpriteLayer("tumblejet");
	CSpriteLayer@ jet = sprite.addSpriteLayer("tumblejet", "fireball1.png", 32, 32);
	if (jet !is null)
	{
		Animation@ anim = jet.addAnimation("default", 2, true);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		jet.SetVisible(false);
		jet.SetRelativeZ(1000.0f);
	}
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CSprite@ sprite = blob.getSprite();

	SSKFighterVars@ fighterVars;
	if (!blob.get("fighterVars", @fighterVars))
	{
		return;
	}

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;
	const bool onground = blob.isOnGround() || blob.isOnLadder();
	const bool inwater = blob.isInWater();

	//hitstun
	u16 hitstunTime = fighterVars.hitstunTime;
	if (hitstunTime > 0)
	{
		blob.setVelocity(Vec2f_zero);

		if (hitstunTime == 1)
		{
			// allow player to have directional influence over tumble trajectory on last frame of hitstun
			if (right || left || up || down)
			{
				const f32 MAX_DI_ANGLE = 14.0f;

				Vec2f inputDir = Vec2f_zero;
				if (right)
					inputDir.x = 1.0f;
				else if (left)
					inputDir.x = -1.0f;
				if (up)
					inputDir.y = -1.0f;
				else if (down)
					inputDir.y = 1.0f;

				f32 inputAngle = inputDir.getAngleDegrees();
				f32 angleDiff = inputAngle - fighterVars.tumbleVec.getAngleDegrees();

				f32 absAngleDiff = Maths::Abs(angleDiff);
				if (absAngleDiff < 180.0f)
				{
					if (absAngleDiff < MAX_DI_ANGLE)
						fighterVars.tumbleVec.RotateBy(-angleDiff);
					else
					{
						if (angleDiff > 0.0f)
							fighterVars.tumbleVec.RotateBy(-MAX_DI_ANGLE);
						else
							fighterVars.tumbleVec.RotateBy(MAX_DI_ANGLE);
					}
				}
			}
		}

		return;
	}
	else if (fighterVars.applyOldVel)
	{
		blob.setVelocity(fighterVars.oldVel);
		fighterVars.applyOldVel = false;
	}

	bool inMoveAnimation = fighterVars.inMoveAnimation;

	f32 newVelY = vel.y;
	f32 newVelX = vel.x;

	u16 tumbleTime = fighterVars.tumbleTime;

	// tumbling physics
	Vec2f tumbleVec = fighterVars.tumbleVec;
	f32 tumbleVecLen = tumbleVec.getLength();
	Vec2f tumbleNorm = tumbleVec;
	tumbleNorm.Normalize();
	bool tumblingFast = tumbleTime > 0 && tumbleVecLen >= 8.0f;
	bool showTumbleJet = tumbleTime > 0 && tumbleVecLen >= 12.0f;

	if (fighterVars.tumbleTime > 0)
	{
		newVelX = tumbleVec.x;
		newVelY = tumbleVec.y;

		// dimensions for checking solid tiles
		const f32 ts = map.tilesize;
		const f32 y_ts = ts * 0.2f;
		const f32 x_ts = ts * 1.4f;

		bool bounce = false;
		f32 effectAngle = 0;

		// if player touching a suface, then bounce him
		if (tumbleVec.y > 1.0f)
		{
			bool surface_below = map.isTileSolid(pos + Vec2f(y_ts, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, x_ts));
			bool surface_below_diagonal = map.isTileSolid(pos + Vec2f(y_ts*4.0f, x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts*4.0f, x_ts));
			if (surface_below || surface_below_diagonal)
			{
				//print("surface_below");
				bounce = true;

				tumbleVec.y = -Maths::Abs(tumbleVec.y)*0.8f;
				newVelY = tumbleVec.y;

				// impact effect variables
				effectAngle = 0;
			}
		}
		if (tumbleVec.y < -1.0f)
		{
			bool surface_above = map.isTileSolid(pos + Vec2f(y_ts, -x_ts)) || map.isTileSolid(pos + Vec2f(-y_ts, -x_ts));
			if (surface_above)
			{
				//print("surface_above");
				bounce = true;

				tumbleVec.y = Maths::Abs(tumbleVec.y)*0.8f;
				newVelY = tumbleVec.y;

				// impact effect variables
				effectAngle = 180;				
			}
		}
		if (tumbleVec.x < -1.0f)
		{
			bool surface_left = map.isTileSolid(pos + Vec2f(-x_ts, y_ts - map.tilesize)) || map.isTileSolid(pos + Vec2f(-x_ts, y_ts));
			if (surface_left)
			{
				//print("surface_left");
				bounce = true;

				tumbleVec.x = Maths::Abs(tumbleVec.x)*0.8f;
				newVelX = tumbleVec.x;

				// impact effect variables
				effectAngle = 90;
			}
		}
		if (tumbleVec.x > 1.0f)
		{
			bool surface_right = map.isTileSolid(pos + Vec2f(x_ts, y_ts - map.tilesize)) || map.isTileSolid(pos + Vec2f(x_ts, y_ts));
			if (surface_right)
			{
				//print("surface_right");
				bounce = true;

				tumbleVec.x = -Maths::Abs(tumbleVec.x)*0.8f;
				newVelX = tumbleVec.x;

				// impact effect variables
				effectAngle = 270;
			}
		}

		if (bounce)
		{
			fighterVars.hitstunTime = 4;
			if (getNet().isServer())
			{
				fighterVars.tumbleVec = tumbleVec;
				
				CBitStream bt;
				bt.write_u8( fighterVars.hitstunTime );
				bt.write_Vec2f( fighterVars.tumbleVec );	
				bt.write_f32( effectAngle );

				blob.SendCommand(blob.getCommandID("sync bounce"), bt);
			}

			newVelX = 0;
			newVelY = 0;
		}

		tumbleVec.y += GRAVITY_TUMBLING;

		tumbleVec *= FRICTION_FACTOR_TUMBLING;

		/*
		// after a certain period, let the player regain control if reached an apex
		if ( fighterVars.dazeTime <= 0 && Maths::Abs(tumbleVec.y) <= GRAVITY_TUMBLING )
		{
			fighterVars.tumbleTime = 0;

			if (getNet().isServer())
				SyncTumbling(blob);
		}
		*/

		// tumble smoke effects
		if (!tumblingFast && getGameTime() % 3 == 0)
		{
			CParticle@ tumbleP = ParticleAnimated("tumblesmoke3.png", pos, Vec2f(0, 0), XORRandom(360), 1.0f, 4, 0.0f, true);
			if ( tumbleP !is null)
			{
				tumbleP.setRenderStyle(RenderStyle::additive);
			}
			
		}
		else if (tumblingFast && getGameTime() % 2 == 0)
		{
			CParticle@ tumbleP = ParticleAnimated("tumblesmoke5.png", pos, Vec2f(0, 0), XORRandom(360), 1.0f, 4, 0.0f, true);
			if ( tumbleP !is null)
			{
				tumbleP.setRenderStyle(RenderStyle::additive);
			}
		}

		fighterVars.tumbleVec = tumbleVec;
	}

	// render tumbling jet sprite if tumbling
	CSpriteLayer@ jet = sprite.getSpriteLayer("tumblejet");
	if (jet !is null)
	{
		jet.SetVisible(showTumbleJet);
		if (showTumbleJet)
		{
			jet.ResetTransform();
			f32 jetRot = -tumbleVec.getAngleDegrees() - blob.getAngleDegrees();
			f32 rotOffset = sprite.isFacingLeft() ? 180.0f : 0.0f;
			jet.RotateBy(jetRot + rotOffset, Vec2f());
			// jet.SetOffset(Vec2f(-16.0f, 0).RotateBy(jetRot));
		}
	}

	// regular gravity
	shape.SetGravityScale(0.0f);
	
	bool fastFalling = fighterVars.fastFalling;
	
	// gravity logic for player while NOT tumbling
	if (tumbleTime == 0 )
	{
		// fastfalling conditional logic
		bool canFastFall = (newVelY > 0) && !onground && !inwater && !inMoveAnimation && fighterVars.dazeTime == 0;
		if (fastFalling == false && down && canFastFall) 
		{
			fighterVars.fastFalling = true;

			ParticleAnimated("sparkle1.png", pos + Vec2f(0, 4.0f), Vec2f(newVelX, newVelY), 0, 0.5f, 2, 0.0f, true);
			sprite.PlaySound("crouch1.ogg", 2.0f);
		}

		if (fastFalling)
		{
			newVelY = FAST_FALL_SPEED;
		}
		else
		{
			f32 gravity = GRAVITY;
			newVelY = Maths::Min(newVelY + GRAVITY, TERMINAL_VEL);
		}
	}

	// stop fast falling if runner has landed
	if ( onground || inwater )
	{
		if (fastFalling)
			fighterVars.fastFalling = false;

		if (!inMoveAnimation)
			fighterVars.fallSpecial = false;
	}

	// set final move vector
	if (fighterVars.gravityEnabled)
	{
		blob.setVelocity( Vec2f(newVelX, newVelY) );
	}
	else
	{
		// do nothing, but enable gravity for the next frame automatically
		fighterVars.gravityEnabled = true;
	}
}