// Runner Movement Walking

#include "RunnerCommon.as"
#include "MakeDustParticle.as";
#include "FallDamageCommon.as";
#include "Knocked.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	const bool isknocked = isKnocked(blob);

	const bool is_client = getNet().isClient();

	CMap@ map = blob.getMap();
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	CShape@ shape = blob.getShape();

	const f32 vellen = shape.vellen;

	shape.SetGravityScale(0.0f);
	Vec2f ladderforce;

	if (up)
	{
		ladderforce.y -= 0.8f;
	}

	if (down)
	{
		ladderforce.y += 0.8f;
	}

	if (left)
	{
		ladderforce.x -= 0.8f;
	}

	if (right)
	{
		ladderforce.x += 0.8f;
	}

	blob.AddForce(ladderforce * moveVars.overallScale * 100.0f);
	//damp vel2
	//Vec2f vel2 = blob.getVelocity();
	//vel2 *= 0.05f;
	//blob.setVelocity(vel2);

	moveVars.jumpCount = -1;
	moveVars.fallCount = -1;

	CleanUp(this, blob, moveVars);
	
	return;
}

//some specific helpers

const f32 offsetheight = -1.2f;

//cleanup all vars here - reset clean slate for next frame

void CleanUp(CMovement@ this, CBlob@ blob, RunnerMoveVars@ moveVars)
{
	//reset all the vars here
	moveVars.jumpFactor = 0.8f;
	moveVars.walkFactor = 0.8f;
	moveVars.stoppingFactor = 0.8f;
	moveVars.wallsliding = false;
	moveVars.canVault = true;
}

//TODO: fix flags sync and hitting so we dont need this
bool checkForSolidMapBlob(CMap@ map, Vec2f pos)
{
	return false;
	
	CBlob@ _tempBlob; CShape@ _tempShape;
	@_tempBlob = map.getBlobAtPosition(pos);
	if (_tempBlob !is null && _tempBlob.isCollidable())
	{
		@_tempShape = _tempBlob.getShape();
		if (_tempShape.isStatic())
		{
			if (_tempBlob.getName() == "wooden_platform")
			{
				f32 angle = _tempBlob.getAngleDegrees();
				if (angle > 180)
					angle -= 360;
				angle = Maths::Abs(angle);
				if (angle < 30 || angle > 150)
				{
					return false;
				}
			}

			return true;
		}
	}

	return false;
}
