#include "FireParticle.as"
#include "Explosion.as";
#include "BombCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";

void onInit(CBlob@ this)
{
    this.server_SetTimeToDie(2000.0f/30);
}

void onTick( CBlob@ this )
{
    //explode on collision with map
    if (getGameTime() % 4 == 0)
    {
        CBlob@ b = server_CreateBlob("inkblot");
		if (b !is null)
		{			
			b.setPosition(Vec2f((this.getPosition().x - ((XORRandom(4)-2)*8)), (this.getPosition().y - ((XORRandom(4)-2)*8))));
			b.server_SetTimeToDie((XORRandom(8)) + 1);
		}
    }
}