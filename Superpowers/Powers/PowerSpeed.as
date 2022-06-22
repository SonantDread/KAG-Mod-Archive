#include "Logging.as";
#include "RunnerCommon.as";
#include "RunnerMovement.as";

// See RunnerMovement
void onInit(CBlob@ this) {
    RunnerMoveVars@ moveVars;
    if (!this.get("moveVars", @moveVars)) {
        log("onInit", "Blob has no moveVars!");
        return;
    }

    //moveVars.overallScale = 2.50f;
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}

/*void onTick(CMovement@ this)
{
	        const f32 walkBoost = hasPower(blob, Powers::SPEED) ? SPEED_BOOST : 1.0;

		if (right)
		{
			if (vel.x < -0.1f)
			{
				walkDirection.x += turnaroundspeed * walkBoost;
			}
			else if (facingleft)
			{
				walkDirection.x += backwardsspeed * walkBoost;
			}
			else
			{
				walkDirection.x += normalspeed * walkBoost;
			}
		}

		if (left)
		{
			if (vel.x > 0.1f)
			{
				walkDirection.x -= turnaroundspeed * walkBoost;
			}
			else if (!facingleft)
			{
				walkDirection.x -= backwardsspeed * walkBoost;
			}
			else
			{
				walkDirection.x -= normalspeed * walkBoost;
			}
		}
}