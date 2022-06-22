#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 40 == 0)
    {
	    const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/3, 360);
		CParticle@ p = ParticleAnimated("GoldParticle.png", pos, Vec2f(0, -1.5f), 0.0f, 1.0f, 6+XORRandom(3), 0.0f, false);
		if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.05f)
	{
		this.getSprite().PlaySound("/dig_stone1", 1.7f, 1.0f);
	}

	if (customData == Hitters::sword)
	{
		damage *= 0.35f;
	}

	if (hitterBlob.getTeamNum() == this.getTeamNum())
	{
		damage *= 0.25f;
	}

	return damage;
}