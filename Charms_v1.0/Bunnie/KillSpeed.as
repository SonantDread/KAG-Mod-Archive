#include "RunnerCommon.as"

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customdata)
{
		if (victim !is null)
		{
			if (killer !is null)
			{
				if(this.get_bool("speedonkillcharm_" + killer.getUsername()) && victim.getTeamNum() != killer.getTeamNum())
				{		
					CBlob@ killerblob = killer.getBlob();
					CBlob@ victimblob = victim.getBlob();

					bool kill = killerblob !is null && victimblob !is null && killerblob !is victimblob;
					
					if (kill)
					{
						getRules().set_u32("killtime_" + killer.getUsername(), getGameTime());
						getRules().Sync("killtime_" + killer.getUsername(), true);
					}
				}
			}
		}

}