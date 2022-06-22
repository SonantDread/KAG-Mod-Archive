// stun
#include "/Entities/Common/Attacks/Hitters.as";
#include "KnockedCommon.as";
#include "ShieldCommon.as";
#include "KnightCommon.as";
#include "SpongeCommon.as";

void onInit(CBlob@ this)
{
	InitKnockable(this);   //already done in runnerdefault but some dont have that
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (this.getPlayer() == null) // so drills and what not dont come up with it
	{
		return;
	}

	const f32 currentHealth = this.getHealth();
	f32 temp = currentHealth - oldHealth;

	if (temp > 25)
	{
		temp = 25;
	}

	while (temp > 0) // if we've been healed, play a particle for each healed unit
	{
		const string particleName = "HealParticle"+(XORRandom(2)+1)+".png";
		const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius(), XORRandom(360));

		CParticle@ p = ParticleAnimated(particleName, pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), -0.1f, false);
		if (p !is null)
		{
			p.diesoncollide = true;
			p.fastcollision = true;
			p.lighting = true; // required unless you want it so show up under ground
		}

		temp -= 0.125f; // now go down to prevent a loop
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	KnockedCommands(this, cmd, params);
}
