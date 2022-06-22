#include "godCommon.as"//

void onInit(CBlob@ this)
{
    this.set_bool("gravity",false);
    this.set_bool("noclip",true);
    this.Tag("invincible");
}

void onTick(CBlob@ this)
{

    CShape@ shape = this.getShape();
    shape.SetGravityScale(this.get_bool("gravity") ? 1 : 0);
    shape.getConsts().mapCollisions = !this.get_bool("noclip");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    this.getSprite().PlaySound("pixiehit.ogg",1,(XORRandom(15)/10.0) + 0.5);

    return 0;
}