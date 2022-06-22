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
        if(isServer())
		{
	        CBlob@ spawn = server_CreateBlob("chicken",-1,this.getPosition());

	        this.getSprite().PlaySound("Glass-breaking-sound.ogg", 5.2f);
	        //fixed 11/27/18
	        if(spawn !is null)
			{
				Vec2f vel(x, 2.0f);
				spawn.setVelocity(vel * 1.2);
				spawn.server_SetTimeToDie(500.0f/30);
			}
		}
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if (this is hitterBlob)
    {
        this.set_s32("bomb_timer", 0);
    }

    if (isExplosionHitter(customData))
    {
        return damage; //chain explosion
    }

    return 0.0f;
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

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    if (!solid)
    {
        return;
    }

    const f32 vellen = this.getOldVelocity().Length();
    const u8 hitter = this.get_u8("custom_hitter");
    if (vellen > 1.7f)
    {
        Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
                    "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
    }

    if (!isExplosionHitter(hitter) && !this.isAttached())
    {
        if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
        {
            this.Tag("_hit_water");
            Vec2f pos = this.getPosition();
            blob.Tag("force_knock");
        }
    }
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
