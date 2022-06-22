#include "SSKRunnerCommon.as"
#include "FighterVarsCommon.as"

const f32 TUMBLE_FACTOR = 1.0f;
const f32 TUMBLE_SPEED_MAX = 32.0f;

void onInit(CBlob@ this)
{
	f32 angle = 0;
	this.set_f32("angle", angle);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
}

void onTick(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars))
	{
		return;
	}

	if ( getNet().isServer() || this.isMyPlayer() )	// was getNet().isServer()
	{
		u16 hitstunTime = fighterVars.hitstunTime;
		u16 tumbleTime = fighterVars.tumbleTime;
		bool inMoveAnimation = fighterVars.inMoveAnimation;
		if (!inMoveAnimation && hitstunTime <= 0)
		{
			if (tumbleTime > 0 && !this.isOnGround())
			{
				Vec2f vel = this.getVelocity();
				f32 angle = this.get_f32("angle");

				Vec2f tumbleVec = fighterVars.tumbleVec;
				f32 tumbleVecLen = tumbleVec.getLength();
				f32 tumbleSpeed = Maths::Min(tumbleVecLen*TUMBLE_FACTOR, TUMBLE_SPEED_MAX);

				if (vel.x > 0)
					angle += tumbleSpeed;
				else if (vel.x < 0)
					angle -= tumbleSpeed;
				
				if (angle > 360.0f)
					angle -= 360.0f;
				else if (angle < -360.0f)
					angle += 360.0f;

				this.set_f32("angle", angle);
				this.setAngleDegrees(angle);
			}
			else
			{
				if (this.getAngleDegrees() != 0)
				{
					this.setAngleDegrees(0);
					this.set_f32("angle", 0);
				}
			}
		}
	}
}
