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
	if (isIgniteHitter(customData) ||					 	   // Fire arrows
	        (this.isOverlapping(hitterBlob) &&
	         hitterBlob.isInFlames() && !this.isInFlames()))	   // Flaming enemy
	{
		server_setFireOn(this);
		if (hitterBlob.getDamageOwnerPlayer() !is null)
		{
			this.set_netid(burner_player_id, hitterBlob.getDamageOwnerPlayer().getNetworkID());
			if (this.hasTag("player"))
			{
				u16 id = hitterBlob.getNetworkID();
				if (SpreadFireToPlayer(this, id))
				{
					this.set_netid(burner_blob_id, id);
				}
			}
		}
	}

	if (isWaterHitter(customData))	  // buckets of water
	{
		if (this.hasTag(burning_tag))
		{
			this.getSprite().PlaySound("/ExtinguishFire.ogg");
		}
		server_setFireOff(this);
		this.set_netid(burner_player_id, 0);
	}

	return damage;
}

// Spread fire from player to player
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!this.hasTag("player") || blob is null || !blob.hasTag("player")) return;

	if (this.hasTag(burning_tag) && !blob.hasTag(burning_tag))
	{
		if (this.get_netid(burner_player_id) > 0) // if fire was started by a player...
		{
			u16 id = this.exists(burner_blob_id) ? this.get_netid(burner_blob_id) : 0;

			if (SpreadFireToPlayer(blob, id))
			{
				server_setFireOn(blob);
				blob.set_netid(burner_player_id, this.get_netid(burner_player_id));
				blob.set_netid(burner_blob_id, id);
			}
		}
		else // this person walked into a fire, force spread + blame them as a new source
		{
			u16 id = this.getNetworkID();
			u16 player_id = this.getPlayer() !is null? this.getPlayer().getNetworkID() : 0;

			SpreadFireToPlayer(this, id);
			this.set_netid(burner_player_id, player_id);
			this.set_netid(burner_blob_id, id);

			SpreadFireToPlayer(blob, id);
			blob.set_netid(burner_player_id, player_id);
			blob.set_netid(burner_blob_id, id);

			server_setFireOn(blob);
		}
	}
}

void BurnRandomNear(Vec2f pos)
{
	Vec2f p = pos + Vec2f((_r.NextFloat() - 0.5f) * 16.0f, (_r.NextFloat() - 0.5f) * 16.0f);
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
	if (burn_time == 0 || this.isInWater() || map.isInWater(pos))
	{
		server_setFireOff(this);
		this.set_netid(burner_player_id, 0);
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
			uint16 netid = this.get_netid(burner_player_id);
			CBlob@ blob = null;
			CPlayer@ player = null;
			if (netid != 0)
				@player = getPlayerByNetworkId(this.get_netid(burner_player_id));

			if (player !is null)
				@blob = player.getBlob();

			if (blob is null)
				@blob = this;

			blob.server_Hit(this, pos, Vec2f(0, 0), 0.25, this.get_u8(burn_hitter), true);
		}

		//burninating the burning time
		burn_time--;

		//and making sure it's set correctly!
		this.set_s16(burn_timer, burn_time);
	}

	// (flax roof cottages!)
}

// Checks if fire started by burnblob can spread to this (adds to burn history of this if so)
bool SpreadFireToPlayer(CBlob@ this, u16 burnblob_id)
{
	if (!this.exists(player_burn_array) || burnblob_id == 0) return false;

	u8 burn_i = this.get_u8(burn_array_i);
	array<u16>@ burn_history;
	this.get(player_burn_array, @burn_history);

	// Make sure this player hasn't already been burned by this fire source
	for (int i = 0; i < Maths::Min(burn_array_size, burn_i); ++i)
	{
		if (burn_history[i] == burnblob_id)
			return false;
	}

	// Record this fire source in burn history
	burn_history[burn_i % burn_array_size] = burnblob_id;
	burn_i++;
	this.set_u8(burn_array_i, burn_i);
	return true;
}
