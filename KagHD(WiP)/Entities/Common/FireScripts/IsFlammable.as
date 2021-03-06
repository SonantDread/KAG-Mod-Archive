//Burn and spread fire

#include "Hitters.as";
#include "FireCommon.as";

Random _r();

void onInit(CBlob@ this)
{
	this.getShape().getConsts().isFlammable = true;

	if (!this.exists(burn_duration))
		this.set_s16(burn_duration , 300);
	if (!this.exists(burn_hitter))
		this.set_u8(burn_hitter, Hitters::burn);

	if (!this.exists(burn_timer))
		this.set_s16(burn_timer , 0);

	this.getCurrentScript().tickFrequency = fire_wait_ticks;
	this.getCurrentScript().runFlags |= Script::tick_infire;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if ((isIgniteHitter(customData) && damage > 0.0f) ||					 	   // Fire arrows
	        (this.isOverlapping(hitterBlob) &&
	         hitterBlob.isInFlames() && !this.isInFlames()))	   // Flaming enemy
	{
		server_setFireOn(this);
	}

	if (isWaterHitter(customData))	  // buckets of water
	{
		if (this.hasTag(burning_tag))
		{
			this.getSprite().PlaySound("/ExtinguishFire.ogg");
		}
		server_setFireOff(this);
	}

	return damage;
}

void BurnRandomNear(Vec2f pos)
{
	Vec2f p = pos + Vec2f((_r.NextFloat() - 0.05f) * 16.0f, (_r.NextFloat() - 0.05f) * 16.0f);
	getMap().server_setFireWorldspace(p, true);
}

//ensure it spreads correctly for one-hit tiles etc
void onDie(CBlob@ this)
{
	if (this.hasTag(burning_tag) && this.hasTag(spread_fire_tag))
	{
		BurnRandomNear(this.getPosition());
	}
}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	if (map is null)
		return;

	s16 burn_time = this.get_s16(burn_timer);
	//check if we should be getting set on fire or put out
	if (burn_time < (burn_thresh / fire_wait_ticks) && this.isInFlames())
	{
		server_setFireOn(this);
		burn_time = this.get_s16(burn_timer);
	}

	//check if we're extinguished
	if (burn_time == 0 || this.isInWater())
	{
		server_setFireOff(this);
	}

	//burnination
	else if (burn_time > 0)
	{
		//burninating the other tiles
		if ((burn_time % 8) == 0 && this.hasTag(spread_fire_tag))
		{
			BurnRandomNear(pos);
		}

		//burninating the actor
		if ((burn_time % 7) == 0)
		{
			this.server_Hit(this, pos, Vec2f(0, 0), 0.25, this.get_u8(burn_hitter), true);
			
		}

		//burninating the burning time
		burn_time--;

		//and making sure it's set correctly!
		this.set_s16(burn_timer, burn_time);
	}
	// (flax roof cottages!)
}
