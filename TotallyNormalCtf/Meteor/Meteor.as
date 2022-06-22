#include "Explosion.as";
#include "BombCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "FireParticle.as"


void onInit(CBlob@ this)
{
    this.server_SetTimeToDie(800.0f/20);
    this.set_f32("explosive_radius",50.0f);
    this.set_f32("explosive_damage",5.0f);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
    this.set_f32("map_damage_radius", 50.0f);
    this.set_f32("map_damage_ratio", 0.5f);
    this.set_bool("map_damage_raycast", false);
    this.set_bool("explosive_teamkill", false);
    this.Tag("exploding");
}

void onTick( CBlob@ this )
{
    bool isServer = getNet().isServer();
    //explode on collision with map
    if (this.isOnMap()) 
    {
        this.server_Die();
    }
    Vec2f vel(6.0f, 8.5f);
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

    return 2.0f;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return false;
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
        Boom(this);
        if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
        {
            this.Tag("_hit_water");
            Vec2f pos = this.getPosition();
            blob.Tag("force_knock");
        }
    }
}

void Explode(CBlob@ this)
{
    if (this.hasTag("exploding"))
    {
        if (this.exists("explosive_radius") && this.exists("explosive_damage"))
        {
            Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
        }
        else //default "bomb" explosion
        {
            Explode(this, 64.0f, 3.0f);
        }
        this.Untag("exploding");
    }

    BombFuseOff(this);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
    if (this.getHealth() < 0.5f || this.hasTag("player"))
    {
        this.getSprite().Gib();
        this.server_Die();
    }
    else
    {
        this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_f32("explosive_damage") * 0.5f, 0);
    }
}

//sprite update
void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(2 * vel.x, Vec2f_zero);      

    if (getGameTime() % 1 + XORRandom(3) == 0)
    {
        const Vec2f pos = blob.getPosition() + getRandomVelocity(0, blob.getRadius()/4, 360);
        CParticle@ p = ParticleAnimated("BlackSmokeParticle.png", pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(10), 0.0f, false);
        if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }   

        makeSmokeParticle(blob.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
    }     
}

void onDie(CBlob@ this)
{
    Explode(this);// Numanator was here!
    this.getSprite().SetEmitSoundPaused(true);
}

void ExplodeWithFire(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null)   return;

    Explode(this, 64.0f, 0.5f);

    this.getSprite().PlaySound("Entities/Items/Explosives/KegExplosion.ogg", 3.6f);
    Boom(this);
}