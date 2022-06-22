const f32 probability = 0.15f; //between 0 and 1

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

void dropArm(CBlob@ this)
{
	if (!this.hasTag("dropped arm")) //double check
	{
		this.Tag("dropped arm");

		if ((XORRandom(1024) / 1024.0f) < probability)
		{
			CBlob@ zombiearm;
			if (getNet().isServer())
				@zombiearm = server_CreateBlob("zombiearm", -1, this.getPosition());

			if (zombiearm !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				zombiearm.setVelocity(vel);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		dropArm(this);
	}
	
	return damage;
}