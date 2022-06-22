#define SERVER_ONLY

#include "CharmSizeCommon.as"

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
		if (cmd == this.getCommandID("sync fclick"))
		{

			string username;
			u32 gtime;
			bool temporary;

			bool bool1 = params.saferead_string(username);
			bool bool2 = params.saferead_u32(gtime);
			bool bool3 = params.saferead_bool(temporary);

			if (!bool1 || !bool2 || !bool3)
            {
                printf("failed to parse some shit:" + username + gtime + temporary);
                
                printf("failing to print: " + bool1 + bool2 + bool3);
                return;
            }
			if (temporary == true)
			{
				this.set_bool(username + "fclick", true);
				this.Sync(username + "fclick", true);
			}
			else if (temporary == false)
			{
				this.set_bool(username + "fclick", false);
				this.Sync(username + "fclick", true);
			}
		}
}