// Flesh hit

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.Damage(damage, hitterBlob);
	// Gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		
		this.server_Die();
	}

	return 0.0f;
}

void onTick(CBlob@ this)
{
	// Bleeding Effect
	if (getNet().isClient() && !this.hasTag("dead"))
	{
		if (this.getHealth() <= this.getInitialHealth() / 3.0f)
		{
			if (getGameTime() % 15 == 0 && XORRandom(2) == 0)
			{
				ParticleBloodSplat(this.getPosition() + Vec2f(XORRandom(12) - 6,XORRandom(8) - 4),false);
			}
		}
	}
}