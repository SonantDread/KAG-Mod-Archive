#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 510 == 0)
    {
    	{
    		const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/4, 360);
			CParticle@ p = ParticleAnimated("CoinParticle.png", pos, Vec2f((XORRandom(5)-2)/2, -3.2f), 0.0f, 1.0f, 2+XORRandom(6), 0.15f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
    	}
    	{
    		const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/4, 360);
			CParticle@ p = ParticleAnimated("CoinParticle.png", pos, Vec2f((XORRandom(5)-2)/2, -2.0f), 0.0f, 1.0f, 2+XORRandom(6), 0.15f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
    	}
    	{
    		const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/4, 360);
			CParticle@ p = ParticleAnimated("CoinParticle.png", pos, Vec2f((XORRandom(5)-2)/2, -1.8f), 0.0f, 1.0f, 2+XORRandom(6), 0.15f, false);
			if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
    	}

		CRules@ rules = getRules();                        

	    array<CBlob@> possibleTargets(getPlayerCount());

	    for (uint16 i = 0; i < getPlayerCount(); i++)
	    {
	        CPlayer@ player = getPlayer(i);
	        if (player == null)
	            continue;//stop
	        CBlob@ player_blob = player.getBlob();
	        if (player_blob == null)
	            continue;//stop
	        if (player_blob.getTeamNum() != this.getTeamNum())
	            continue;//stop

			player.server_setCoins(player.getCoins() + 10);
	    }
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