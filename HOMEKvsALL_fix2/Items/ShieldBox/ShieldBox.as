#include "Hitters.as";
#include "GenericButtonCommon.as";

const u32 duration = 300;
const f32 radius = 72.0f;

void onInit(CBlob@ this)
{
    this.Tag("medium weight");

    this.addCommandID("activate");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;
    if (caller.getTeamNum() != this.getTeamNum()) return;
    if (this.hasTag("activated")) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("activate"), "Activate", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("activate"))
    {
        this.Tag("activated");
        this.set_s32("timer", duration);
    }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return (blob.getShape().isStatic() || (this.getTeamNum() != blob.getTeamNum()));
}

void onTick(CBlob@ this)
{
    if (this.hasTag("activated"))
    {
        CBlob@[] blobs;

        if (getMap().getBlobsInRadius(this.getPosition(), radius, @blobs))
        {
            for (int i = 0; i < blobs.size(); i++)
            {
                CBlob@ blob = blobs[i];
                if (blob is null) continue;
                if (blob.getTeamNum() == this.getTeamNum()) continue;
                if (blob.getPlayer() !is null) continue;

                Vec2f distance = blob.getPosition() - this.getPosition();
                Vec2f force = distance;
                force.Normalize();

                f32 forcemod = 1.0f;
                force = force * blob.getMass() * 1.13f * forcemod;

                if (force.Length() < 1.5f)
                {
                    force.Normalize();
                    force *= 1.5f;
                }

                blob.AddForce(force);
            }
        }

        this.add_s32("timer", -1);
        if (this.get_s32("timer") < 0)
        {
            this.server_Hit(this, Vec2f_zero, Vec2f_zero, 1000.0f, Hitters::crush);
        }
    }
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.getTeamNum() == byBlob.getTeamNum() || (!this.hasTag("activated") && this.getTeamNum() != byBlob.getTeamNum()));
}

void onDie(CBlob@ this)
{
    print("dieded");
    CParticle@[] particles;
    this.get("particles", particles);

    while (!particles.isEmpty())
    {
        CParticle@ p = particles[particles.size() - 1];
        if (p !is null)
        {
            p.timeout = 1;
        }
        particles.removeAt(particles.size() - 1);
    }

    for (int i = 0; i < 150; i++)
        {
            Vec2f offset = Vec2f(radius, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = -offset;
            vel.Normalize();
            vel *= 0.1f + XORRandom(40) * 0.1f;
            vel.RotateByDegrees(XORRandom(3600) * 0.1f);

            CParticle@ p = ParticlePixel(this.getPosition(), vel, SColor(255, XORRandom(50),XORRandom(50), XORRandom(55) + 200), true, 20 + XORRandom(45));
            if (p !is null)
            {
				p.gravity = Vec2f(0,0);
                p.collides = false;
            }
        }
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob.hasTag("activated"))
    {
        Animation@ anim = this.getAnimation("active");
        this.SetAnimation(anim);
        s32 timer = blob.get_s32("timer");
        

        if (timer > duration * 0.75) anim.SetFrameIndex(0);
        else if (timer > duration * 0.50) anim.SetFrameIndex(1);
        else if (timer > duration * 0.25) anim.SetFrameIndex(2);
        else anim.SetFrameIndex(3);
        
        CParticle@[] particles;
        blob.get("particles", particles);

        for (int i = 0; i < 10; i++)
        {
            Vec2f offset = Vec2f(radius, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = -offset;
            vel.Normalize();
            vel *= 0.5f;
            vel.RotateByDegrees(XORRandom(3600) * 0.1f);

            CParticle@ p = ParticlePixel(this.getBlob().getPosition() + offset, vel, SColor(255, 50, 50, 255), true, 10);
            if (p !is null)
            {
				p.gravity = Vec2f(0,0);
                p.collides = false;
                particles.insertLast(p);
            }
        }

        for (int i = 0; i < 4; i++)
        {
            Vec2f offset = Vec2f(radius, 0);
            offset.RotateByDegrees(XORRandom(3600) * 0.1f);

            Vec2f vel = offset;
            vel.Normalize();
            vel *= 3.0f;

            CParticle@ p = ParticlePixel(this.getBlob().getPosition(), vel, SColor(255, 50, 50, 255), true, radius / 3);
            if (p !is null)
            {
				p.gravity = Vec2f(0,0);
                p.collides = false;
                particles.insertLast(p);
            }
        }
    }
}