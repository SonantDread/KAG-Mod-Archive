#include "FighterMovesetCommon.as"

// Archer moveset data

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
	

	// Grab Attack
	

	// Grab Item
	
	// Throw
	

	this.set("fighterMoveset"+FighterClasses::ARCHER, Moveset);
}