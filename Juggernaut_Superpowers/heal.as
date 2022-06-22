#include "Logging.as";

const int HEALER_RADIUS = 20.0 * 8; //20 blocks
const int HEAL_FREQUENCY = 15 * 30; //15 sec
const float HEALER_HEALTH = 1 * 2; //2 hp

void onInit( CBlob@ this )
{
    this.set_u32("last heal", 0 );
}

void onTick(CBlob@ this) //code from HOMEKvsALL_fix2
{
    const u32 gametime = getGameTime();
    u32 lastHeal = this.get_u32("last heal");
    if ((gametime - lastHeal) < HEAL_FREQUENCY)
    {
        return;
    }

    if(this.isKeyJustPressed( key_taunts ))
    {
	CBlob@[] blobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), HEALER_RADIUS, @blobs))
	{
	    for (int i = 0; i < blobs.length; i++)
	    {
		CBlob@ blob = blobs[i];
		if (blob !is null && blob.getTeamNum() == this.getTeamNum())
		{
		    blob.server_Heal(HEALER_HEALTH);
		}
	    }
	    this.set_u32("last heal", gametime);
	}
    }
}
