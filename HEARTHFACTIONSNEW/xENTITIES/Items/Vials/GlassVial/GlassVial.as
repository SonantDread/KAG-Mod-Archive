#include "Hitters.as";

void onTick( CBlob@ this )
{
	CMap@ map = getMap();
	f32 x = this.getVelocity().x;
	f32 y = this.getVelocity().y;
    //explode on collision with map
    if (this.isOnMap() && (Maths::Abs(x) + Maths::Abs(y) > 2.0f))
    {
        this.server_Die();
        //SPAWN ITEM(s)

        this.getSprite().PlaySound("Glass-breaking-sound.ogg", 5.2f);
    }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    //special logic colliding with players
    if (blob.hasTag("player"))
    {
        const u8 hitter = this.get_u8("custom_hitter");

        //all water bombs collide with enemies
        if (hitter == Hitters::water)
            return blob.getTeamNum() != this.getTeamNum();

        //collide with shielded enemies
        return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
    }

    string name = blob.getName();

    if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
    {
        return false;
    }

    return true;
}

//sprite update
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(9 * vel.x, Vec2f_zero);	 		  
}

void onDie(CBlob@ this)
{
    this.getSprite().SetEmitSoundPaused(true);
}
