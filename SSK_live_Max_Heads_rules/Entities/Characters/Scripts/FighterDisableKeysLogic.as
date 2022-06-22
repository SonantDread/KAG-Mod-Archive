#include "FighterVarsCommon.as"

// Disable keys logic

void onTick(CBlob@ this) 
{
	SSKFighterVars@ fighterVars;
	if (this.get("fighterVars", @fighterVars))
	{
		u16 hitstunTime = fighterVars.hitstunTime;
		u16 tumbleTime = fighterVars.tumbleTime;
		u16 dazeTime = fighterVars.dazeTime;
		bool disableItemActions = fighterVars.disableItemActions;
		bool inMoveAnimation = fighterVars.inMoveAnimation;

		if (hitstunTime > 0 || tumbleTime > 0 || dazeTime > 0)
		{
			u16 takekeys = key_action1 | key_action2 | key_action3; // key_left | key_right | key_up | key_down | 

			this.DisableKeys(takekeys);
			this.DisableMouse(true);
		}
		else if (disableItemActions)
		{
			u16 takekeys = key_pickup | key_action1 | key_action2 | key_action3;

			this.DisableKeys(takekeys);
			this.DisableMouse(true);
			fighterVars.disableItemActions = false;
		}
		else
		{
			this.DisableKeys(0);
			this.DisableMouse(false);
		}
	}
	else
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
	}
}
