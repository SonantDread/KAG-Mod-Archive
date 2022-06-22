#include "RunnerCommon.as"

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customdata)
{

	if (victim !is null)
	{

		if (killer !is null)
		{
			CBlob@ killerblob = killer.getBlob();
			CBlob@ victimblob = victim.getBlob();

			bool kill = killerblob !is null && victimblob !is null && killerblob !is victimblob;

			RunnerMoveVars@ moveVars;

			if (!killerblob.get("moveVars", @moveVars))
			{
				return;
			}

			// this.set_Vec2f("old vel", this.getVelocity());

			if (kill)
			{
				killerblob.set_u32("kill time", getGameTime());
				killerblob.Sync("kill time", true);
				printf('somebody has been killed');
			}
		}
	}
}

void onTick(CMovement@ this)
{

	CBlob@ blob = this.getBlob();

			if (blob is null)
				return;
				
			RunnerMoveVars@ moveVars;

			if (!blob.get("moveVars", @moveVars))
			{
				return;
			}

			if (getGameTime() < blob.get_u32("kill time") || !blob.exists("kill time"))
			{
				blob.set_u32("kill time", getGameTime());
				blob.set_bool("speed", true);
				blob.Sync("speed", true);
				printf('reset kill time haha');
			}
			else if (getGameTime() - blob.get_u32("kill time") < (5 * 30) && blob.get_u32("kill time") > 30)
			{
				if (blob.get_bool("speed") == false)
				{
					moveVars.walkSpeed *= 1.5f;
					moveVars.walkSpeedInAir *= 1.5f;
					moveVars.swimspeed *= 1.5f;
					printf('haha 2x move vars uwu');
				}

				blob.set_bool("speed", true);
				blob.Sync("speed", true);
			}
			else if (getGameTime() - blob.get_u32("kill time") > (5 * 30))
			{
				if (blob.get_bool("speed") == true)
				{
					moveVars.walkSpeed /= 1.5f;
					moveVars.walkSpeedInAir /= 1.5f;
					moveVars.swimspeed /= 1.5f;
					blob.set_bool("speed", false);
					blob.Sync("speed", true);
					printf('black skin');
				}
			}
}