#include "Hitters.as"

f32 init_radius = 100.0f;

void onInit(CBlob@ this)
{
    this.getShape().SetStatic(true);
    this.server_SetTimeToDie(8.0f);
    this.set_f32("radius", init_radius);
    this.getSprite().ScaleBy(init_radius * 1.15f / 64.0f, init_radius * 1.15f / 64.0f);
    this.getSprite().SetZ(-20.0f);
}

void onTick(CSprite@ this)
{
    if (getGameTime() % 1 == 0)
    {
        for (int i = 0; i < 4; i++)
        {
            f32 radius = this.getBlob().get_f32("radius");
            Vec2f offset = Vec2f(radius, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = -offset;
            vel.Normalize();
            vel *= 3.0f;

            CParticle@ p = ParticlePixel(this.getBlob().getPosition() + offset, vel, SColor(255, 128, 0, 128), true, radius / 2);
            if (p !is null)
            {
				p.gravity = Vec2f(0,0);
                p.collides = false;
            }
        }

        /*for (int i = 0; i < 10; i++)
        {
            f32 radius = this.getBlob().get_f32("radius") / 2;
            Vec2f offset = Vec2f(radius, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = -offset;
            vel.Normalize();
            vel *= 0.5f;
            vel.RotateByDegrees(XORRandom(3600) * 0.1f);

            CParticle@ p = ParticlePixel(this.getBlob().getPosition() + offset, vel, SColor(255, 255, 0, 0), true, 10);
            if (p !is null)
            {
				p.gravity = Vec2f(0,0);
                p.collides = false;
            }
        }*/
    }
}

void onTick(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
    f32 radius = this.get_f32("radius");
    if (sprite !is null)
    {
        sprite.ScaleBy(64.0f / radius, 64.0f / radius);
        sprite.RotateByDegrees(-2.0f, Vec2f_zero);
    }

    radius += 0.5f;

    this.set_f32("radius", radius);
    CBlob@[] blobs;

    if (sprite !is null)
    {
        sprite.ScaleBy(radius / 64.0f, radius / 64.0f);
    }

    if (getMap().getBlobsInRadius(this.getPosition(), this.get_f32("radius"), blobs))
    {
        for (int i = 0; i < blobs.size(); i++)
        {
            CBlob@ blob = blobs[i];
            if (blob is null) continue;

            Vec2f distance = blob.getPosition() - this.getPosition();
            Vec2f force = distance;
            force.Normalize();

            f32 forcemod = Maths::Max(1 - (distance.Length() / this.get_f32("radius")), 0.0f);

            blob.AddForce(-force * blob.getMass() * 1.13f * forcemod);
        }
    }

    blobs.clear();

    if (getGameTime() % 30 == 0)
    {
        if (getMap().getBlobsInRadius(this.getPosition(), this.get_f32("radius") * 0.5f, blobs))
        {
            for (int i = 0; i < blobs.size(); i++)
            {
                CBlob@ blob = blobs[i];
                if (blob is null || blob.hasTag("invincible") || blob.getTeamNum() == this.getTeamNum()) continue;

                this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 0.5f, Hitters::void_keg);
            }
        }
    }
}