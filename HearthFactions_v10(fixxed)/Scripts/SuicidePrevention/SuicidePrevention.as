#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    //print("" + customData);

    CPlayer@ player=this.getPlayer();

    if (this.hasTag("invincible") || (player !is null && player.freeze))
    {
        return 0;
    }

    switch(customData)
    {
        case Hitters::nothing:
        case Hitters::suicide:
        case Hitters::fall:
            damage = 0;
            break;
    }

    return damage;
}