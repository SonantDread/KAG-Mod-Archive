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

/*void onTick(CBlob@ this)
{
	bool ready = this.get_bool("heal ready");
	const u32 gametime = getGameTime();
	
	if(ready)
	{
		if(this.isKeyJustPressed( key_taunts ))
		{
		bool getBlobsInRadius(Vec2f posWorldspace, float radius, CBlob@[]@ list)
		
		if 
		}
	}
}
	
void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(this.getPosition(), this.getRadius(), @blobsInRadius))
	{
		const u8 teamNum = this.getTeamNum();
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (this.getTeamNum() == teamNum && b.getHealth() < b.getInitialHealth() && b.hasTag("survivorplayer") && !b.hasTag("dead"))
			{
				b.server_Heal(1.25f);
				b.getSprite().PlaySound("/Heart.ogg");
			}
		}
	}
}*/