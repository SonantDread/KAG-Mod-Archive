#include "Logging.as";
  
const int HEALER_RADIUS = 15.0 * 8; //15 blocks
const int HEAL_FREQUENCY = 20 * 30; //15 sec, changed to 20
const float HEALER_HEALTH = 1 * 2; //2 hp

void onInit( CBlob@ this )
{
    this.set_u32("last heal", 0 );
}

void onTick(CBlob@ this) //code from HOMEKvsALL_fix2
{
	CControls@ controls = getControls();
    const u32 gametime = getGameTime();
    u32 lastHeal = this.get_u32("last heal");
    if ((gametime - lastHeal) < HEAL_FREQUENCY)
    {
        return;
    }


    if (controls.isKeyJustPressed(KEY_KEY_B))
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
					for( int n = 0; n < 10; n++ ) //loop 10 times
					{
					const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/2, 360);
					CParticle@ p = ParticleAnimated("HealParticle1.png", pos, Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
					}
                }
            }
            this.set_u32("last heal", gametime);
        }
    }
}