/* 2deoto0.as
 * author: Aphelion
 * 
 * Script for disallowing access without having defeated Noom and preventing pickup.
 */

#include "si74k9.as";

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
	//return isBossDefeated(getRules()) && byBlob.getTeamNum() != 5;
	return isBossDefeated(getRules());
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob )
{
    if (getNet().isServer() && !isBossDefeated(getRules()))
	{
	    this.server_PutInInventory(blob);
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
