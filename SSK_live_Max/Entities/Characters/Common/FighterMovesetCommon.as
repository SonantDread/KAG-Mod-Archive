#include "FighterVarsCommon.as"
#include "StandardControlsCommon.as"
#include "Hitters.as"

// common attack and move animation classes and functions

namespace FighterClasses
{
	enum fighter
	{
		KNIGHT = 0,
		ARCHER,
		NUM_FIGHTERS
	}
}

shared class MoveAnimation
{
	string name;
	u8 moveType;

	int tick;
	u16 currFrameIndex;

	MoveFrame@[] moveFrames;

	FighterHitData@ fighterHitData;

	MoveAnimation() {} // required for handles to work

	MoveAnimation(string _name, u8 _moveType, MoveFrame@[] _moveFrames)
	{
		name = _name;
		moveType = _moveType;
		moveFrames = _moveFrames;

		tick = 0;
		currFrameIndex = 0;

		int tickSum = 0;
		for(int i = 0; i < moveFrames.length(); i++)
		{
			moveFrames[i].beginTick = tickSum;
			tickSum += moveFrames[i].holdTime;
			moveFrames[i].endTick = tickSum;
		}	
	}

	MoveAnimation(string _name, u8 _moveType, MoveFrame@[] _moveFrames, FighterHitData@ _fighterHitData)
	{
		name = _name;
		moveType = _moveType;
		moveFrames = _moveFrames;
		fighterHitData = _fighterHitData;

		tick = 0;
		currFrameIndex = 0;

		int tickSum = 0;
		for(int i = 0; i < moveFrames.length(); i++)
		{
			moveFrames[i].beginTick = tickSum;
			tickSum += moveFrames[i].holdTime;
			moveFrames[i].endTick = tickSum;
		}	
	}

	bool opEquals(const int &in otherMoveType)
	{
		return moveType == otherMoveType;
	}
}

shared class MoveFrame
{
	u8 frameID;
	u16 spriteFrameNum;
	u8 holdTime;

	int beginTick;
	int endTick;

	f32 attackAngle;
	f32 attackArc;
	f32 attackRange;
	f32 damage;

	bool isGrabFrame;

	FrameLogic frameLogic;

	MoveFrame() {} // required for handles to work

	MoveFrame(u16 _spriteFrameNum, u8 _holdTime = 1, f32 _attackAngle = 0.0f, f32 _attackArc = 0.0f, f32 _attackRange = 0.0f, f32 _damage = 0.0f, bool _isGrabFrame = false)
	{
		spriteFrameNum = _spriteFrameNum;

		holdTime = _holdTime;

		attackAngle = _attackAngle;
		attackArc = _attackArc;
		attackRange = _attackRange;
		damage = _damage;

		isGrabFrame = _isGrabFrame;
	}

	MoveFrame(FrameLogic _frameLogic, u16 _spriteFrameNum, u8 _holdTime = 1, f32 _attackAngle = 0.0f, f32 _attackArc = 0.0f, f32 _attackRange = 0.0f, f32 _damage = 0.0f, bool _isGrabFrame = false)
	{
		frameLogic = _frameLogic;

		spriteFrameNum = _spriteFrameNum;

		holdTime = _holdTime;

		attackAngle = _attackAngle;
		attackArc = _attackArc;
		attackRange = _attackRange;
		damage = _damage;

		isGrabFrame = _isGrabFrame;
	}
}

funcdef void FIGHTER_CALLBACK(CBlob@, SSKFighterVars@);
shared class FrameLogic
{
	FIGHTER_CALLBACK @onBegin;	// Pass this method to execute any special code only on the start of this move frame
	FIGHTER_CALLBACK @onExecute;	// Pass this method to execute any special code during each tick of this move frame
	FIGHTER_CALLBACK @onEnd;		// Pass this method to execute any special code only on the end of this move frame

	FrameLogic() {} // required for handles to work

	FrameLogic(FIGHTER_CALLBACK @_onBegin, FIGHTER_CALLBACK @_onExecute, FIGHTER_CALLBACK @_onEnd)
	{
		onBegin = _onBegin;
		onExecute = _onExecute;
		onEnd = _onEnd;
	}
}

shared class AutoTickFunc
{
	string name;

	FIGHTER_CALLBACK @whileActive;	// This method is executed for each tick runAutoTickFunc is called
	FIGHTER_CALLBACK @onDeactivate;	// This method is executed once runAutoTickFunc stops being called

	u16 ticksActive;
	bool disableOnHit;
	bool activeDuringHitstun;

	AutoTickFunc(string _name, FIGHTER_CALLBACK @_whileActive = null, FIGHTER_CALLBACK @_onDeactivate = null, bool _disableOnHit = false, bool _activeDuringHitstun = false, u16 _ticksActive = 1)
	{
		name = _name;
		whileActive = _whileActive;
		onDeactivate = _onDeactivate;
		disableOnHit = _disableOnHit;
		activeDuringHitstun = _activeDuringHitstun;
		ticksActive = _ticksActive;
	}
}

namespace MoveTypes
{
	enum type
	{
		SHIELD = 0,
		GRAB_ATTACK,
		GRAB_ITEM,
		THROW,
		STANDARD_ATTACK,
		DOWN_AERIAL,
		UP_SPECIAL,
		DOWN_SPECIAL,
		NUM_MOVE_TYPES
	}
}

int getMoveIndexByType(MoveAnimation[]@ moveset, u8 moveType)
{
	for(int i = 0; i < moveset.length(); i++)
	{
		if (moveset[i] == moveType)
		{
			return i;
		}
	}	

	return -1;
}

void handleStartMove(CBlob@ blob, MoveAnimation@ moveAnim)
{
	SSKFighterVars@ fighterVars;
	if (!blob.get("fighterVars", @fighterVars)) 
	{ 
		return; 
	}

	// make sure we are upright! (for at least the first frame of the move)
	blob.setAngleDegrees(0);
	blob.set_f32("angle", 0);

	CSprite@ sprite = blob.getSprite();

	Animation@ spriteAnim = sprite.getAnimation(moveAnim.name);
	if (spriteAnim is null)
	{
		@spriteAnim = sprite.addAnimation(moveAnim.name, 0, false);
		for(int i = 0; i < moveAnim.moveFrames.length(); i++)
		{
			spriteAnim.AddFrame(moveAnim.moveFrames[i].spriteFrameNum);
		}	
	}

	sprite.SetAnimation(moveAnim.name);

	fighterVars.currMoveFrameIndex = 0;
	fighterVars.currMoveFrameTimer = moveAnim.moveFrames[0].holdTime;

	fighterVars.inMoveAnimation = true;
	fighterVars.currMoveAnimation = moveAnim;

	// face mouse aim position before attack
 	bool faceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	fighterVars.isAttackingLeft = faceLeft;
}

void updateCommonMoves(CBlob@ blob, SSKFighterVars@ fighterVars, MoveAnimation@ moveAnim)
{
	CSprite@ sprite = blob.getSprite();
	Animation@ spriteAnim = sprite.getAnimation(moveAnim.name);
	u16 animFrame = sprite.getFrame();

	MoveFrame@ currMoveFrame = moveAnim.moveFrames[fighterVars.currMoveFrameIndex];

	if (currMoveFrame.damage > 0.0f && !fighterVars.hasAttackedOnCurrFrame)
	{
		arcAttack(blob, fighterVars.isAttackingLeft, currMoveFrame.damage, currMoveFrame.attackAngle, currMoveFrame.attackArc, currMoveFrame.attackRange, Hitters::sword, moveAnim.fighterHitData);
	}

	if (currMoveFrame.isGrabFrame)
	{
		arcGrab(blob, fighterVars.isAttackingLeft, currMoveFrame.attackAngle, currMoveFrame.attackArc, currMoveFrame.attackRange);
	}

	spriteAnim.SetFrameIndex(fighterVars.currMoveFrameIndex);

	// Perform any special logic for this tick of the animation frame
	FrameLogic@ frameLogic = currMoveFrame.frameLogic;
	if (frameLogic !is null)
	{
		if (fighterVars.currMoveFrameTimer == currMoveFrame.holdTime && frameLogic.onBegin !is null)
		{
			frameLogic.onBegin(blob, fighterVars);
		}		
		if (frameLogic.onExecute !is null)
		{
			frameLogic.onExecute(blob, fighterVars);
		}
		if (fighterVars.currMoveFrameTimer == 1 && frameLogic.onEnd !is null)
		{
			frameLogic.onEnd(blob, fighterVars);
		}	
	}

	// go to next animation frame if frame timer is up
	fighterVars.currMoveFrameTimer--;
	if (fighterVars.currMoveFrameTimer <= 0)
	{
		fighterVars.currMoveFrameIndex++;
		if (fighterVars.currMoveFrameIndex < moveAnim.moveFrames.length())
		{
			MoveFrame@ nextMoveFrame = moveAnim.moveFrames[fighterVars.currMoveFrameIndex];
			fighterVars.currMoveFrameTimer = nextMoveFrame.holdTime;
			fighterVars.hasAttackedOnCurrFrame = false;			
		}
		else
		{
			fighterVars.inMoveAnimation = false;
			return;
		}
	}
}

bool arcAttack(CBlob@ blob, bool isFacingLeft, f32 damage, f32 aimangle, f32 arcdegrees, f32 attack_distance, u8 type, FighterHitData@ fighterHitData)
{
	if (!getNet().isServer())
	{
		return false;
	}

	if (isFacingLeft)
	{
		aimangle = 180 - aimangle;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	Vec2f aimVec(1, 0);
	aimVec.RotateBy(aimangle);
	Vec2f pos = blobPos + vel + Vec2f(0, -2);
	vel.Normalize();
	
	CMap@ map = blob.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (blob.getAimPos() - blobPos).Angle();

	bool hitEnemy = false;

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, attack_distance, blob, @hitInfos))
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

				if (!canAttackHit(blob, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					server_fighterHit(blob, b, hi.hitpos, velocity, damage, type, true, fighterHitData);	// server_fighterHit() is server-side only

					SSKFighterVars@ fighterVars;
					if (blob.get("fighterVars", @fighterVars))
					{
						fighterVars.hasAttackedOnCurrFrame = true;
						hitEnemy = true;
					}

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else if (!dontHitMoreMap )	// hitmap
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

						bool canhit = true; //default true

						//dont dig through no build zones
						canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

						dontHitMoreMap = true;
						if (canhit)
						{
							map.server_DestroyTile(hi.hitpos, 0.1f, blob);
						}
					}
				}
			}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f))    // aiming down or slash
	{
		f32 tilesize = map.tilesize;
		f32 radius = blob.getRadius();
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = blob.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
		{
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile))
				{
					map.server_DestroyTile(tilepos, damage, blob);

					if (damage <= 1.0f)
					{
						break;
					}
				}
			}
		}
	}

	return hitEnemy;
}

bool canAttackHit(CBlob@ blob, CBlob@ b)
{
	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carriedBlob = b.getCarriedBlob();

		if (carriedBlob !is null)
			if (carriedBlob.hasTag("player")
			        && (blob.getTeamNum() == carriedBlob.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != blob.getTeamNum();
}

bool canGrab(CBlob@ blob, CBlob@ b)
{
	if (b.hasTag("player") && b.getTeamNum() == blob.getTeamNum())
		return false;
	else
		return true;
}

void arcGrab(CBlob@ thisBlob, bool isFacingLeft, f32 aimangle, f32 arcdegrees, f32 attack_distance)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (isFacingLeft)
	{
		aimangle = 180 - aimangle;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = thisBlob.getPosition();
	Vec2f vel = thisBlob.getVelocity();
	Vec2f aimVec(1, 0);
	aimVec.RotateBy(aimangle);
	Vec2f pos = blobPos + vel + Vec2f(0, -2);
	vel.Normalize();
	
	CMap@ map = thisBlob.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (thisBlob.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, attack_distance, thisBlob, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;

			if (b is thisBlob)
				continue;

			if (b !is null && !dontHitMore) // blob
			{
				if (!canGrab(thisBlob, b))
				{
					continue;
				}

				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - pos;
					if ((b.canBePickedUp(thisBlob) && !b.getShape().isStatic()) || b.hasTag("player"))
					{
						SyncGrabEvent(thisBlob);

						thisBlob.server_Pickup(b);
						dontHitMore = true;
					}
				}
			}
		}
	}
}

namespace MovesetFuncs
{
	// Grab moveset functions
	namespace Grab
	{
		void playSound(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
		{
			fighterBlob.getSprite().PlaySound("grab1.ogg", 3.0f, 1.0f);
		}
	}

	// Shield moveset functions
	namespace Shield
	{
		void shieldActivationLogic(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
		{
			fighterVars.runAutoTickFunc("shield", whileShielding, onShieldEnd, false);
		}

		void whileShielding(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
		{
			bool wasShielding = fighterVars.isShielding;

			// force shield to be active until last tick of frame
			fighterVars.isShielding = true;

			// shield activation logic
			bool forceShieldOn = wasShielding && fighterVars.hitstunTime > 0;	// keep shield from falling during hitstun if already on

			bool activateShield = (fighterBlob.isKeyPressed(key_action3) || forceShieldOn) && fighterVars.shieldHealth > 0;

			// continue shield activation logic on next frame when applicable
			if (activateShield)
			{
				fighterVars.currMoveFrameTimer++;
			}

			CSprite@ sprite = fighterBlob.getSprite();

			// play shield animation and sound when first activated
			if (fighterVars.isShielding && !wasShielding)
			{
				CSpriteLayer@ shieldWave = sprite.getSpriteLayer("shield wave");
				if (shieldWave !is null)
				{
					shieldWave.SetAnimation("wave out");
					Animation@ waveAnim = shieldWave.getAnimation("wave out");
					if (waveAnim !is null)
					{
						waveAnim.SetFrameIndex(0);
					}
				}

				sprite.PlaySound("shieldon.ogg", 1.0f);
			}
		}

		void onShieldEnd(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
		{
			fighterVars.isShielding = false;

			CSprite@ sprite = fighterBlob.getSprite();

			CSpriteLayer@ shieldWave = sprite.getSpriteLayer("shield wave");
			if (shieldWave !is null)
			{
				shieldWave.SetAnimation("wave in");
				Animation@ waveAnim = shieldWave.getAnimation("wave in");
				if (waveAnim !is null)
				{
					waveAnim.SetFrameIndex(0);
				}
			}

			sprite.PlaySound("shieldoff.ogg", 1.0f);
		}
	}

	// Generic moveset functions
	namespace Generic
	{
		void fullStop(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
		{
			fighterVars.fastFalling = false;
			fighterBlob.setVelocity(Vec2f(0, 0));
		}
	}
}