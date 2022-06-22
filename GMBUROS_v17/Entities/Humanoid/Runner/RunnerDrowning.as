//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"
#include "LimbsCommon.as";

//config vars

const int FREQ = 6; //must be >2 or breathing at top of water breaks
const u8 default_aircount = 180; //6s, remember to update runnerhoverhud.as

void onInit(CBlob@ this)
{
	this.set_u8("air_count", default_aircount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;

	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();
		bool inwater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f));
		if(this.get_bool("short_hitbox"))inwater = this.isInWater();

		bool needs_breathe = false;
		
		bool gassed = false;
		
		CMap@ map = this.getMap();
		CBlob@[] blobs;
		if (map is null) return;
		
		map.getBlobsInRadius(this.getPosition(), 12, @blobs);

		for (int i = 0; i < blobs.length; i++)
		{
			if (blobs[i].hasTag("gas"))
			{
				gassed = true;
				break;
			}
		}
		
		if(isLivingFlesh(limbs.Torso) && this.hasTag("alive"))needs_breathe = true;
		
		int aircount = this.get_u8("air_count");

		this.getCurrentScript().tickFrequency = FREQ;

		if ((inwater || gassed) && needs_breathe)
		{
			if (aircount >= FREQ)
			{
				aircount -= FREQ;
			}

			//drown damage
			if (aircount < FREQ)
			{
				this.server_Hit(this, pos, Vec2f(0, 0), 1.0f, Hitters::drown, true);
				Sound::Play("Gurgle", pos, 2.0f);
				aircount += FREQ*5;
			}
		}
		else
		{
			if (aircount < default_aircount/2)
			{
				Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
				aircount = default_aircount/2;
			}
			else if (aircount < default_aircount)
			{
				if (this.isOnGround() || this.isOnLadder())
				{
					aircount += FREQ/3;
				}
				else
				{
					aircount += FREQ/6;
				}
			}
			else
			{
				aircount = default_aircount;
			}
		}

		this.set_u8("air_count", aircount);
		this.Sync("air_count", true);
	}
}

// SPRITE renders in party indicator