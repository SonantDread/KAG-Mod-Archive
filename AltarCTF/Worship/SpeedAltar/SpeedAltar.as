#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if (getGameTime() % 30 == 0)
    {
	    const Vec2f pos = this.getPosition() + getRandomVelocity(0, this.getRadius()/2, 360);
		CParticle@ p = ParticleAnimated("WindParticle.png", pos, Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
		if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
    }

	if (getGameTime() % 300 == 0)
    {
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

	        //tag the blob
	        if (!player_blob.hasTag("Speed"))
	   		{
	   			player_blob.Tag("Speed");
		        Sound::Play("SpeedBlessing.ogg", player_blob.getPosition());

		        const Vec2f pos = player_blob.getPosition() + getRandomVelocity(0, player_blob.getRadius()/1.5, 360);
				CParticle@ p = ParticleAnimated("WindParticle.png", pos, Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
				if (p !is null) { p.diesoncollide = true; p.fastcollision = true; p.lighting = true; }
	    	}
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