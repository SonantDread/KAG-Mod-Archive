#include "Hitters.as";

// regen hp back to
const f32 max_range = 128.00f;
const int targets_count = 2; // how many targets can be healed per tick
const string max_prop = "regen maximum";
const string rate_prop = "regen rate";

void onInit(CBlob@ this)
{
	if (!this.exists(max_prop))
		this.set_f32(max_prop, this.getInitialHealth());

	if (!this.exists(rate_prop))
		this.set_f32(rate_prop, 0.5f); //0.5 hearts per second

	this.addCommandID("heal_player");
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	if (this.hasTag("MENDING") && isServer())
	{
		CBlob@[] blobs;
		if (getPrioritisedTargets(this.getPosition(), max_range, blobs))
		{
			// print("got targets");
			for (int i = 0; i < Maths::Min(blobs.size(), targets_count); i++)
			{
				CBlob@ blob = blobs[i];
				// print("iterating over " + blob.getName());
				if (blob !is null && blob.getTeamNum() == this.getTeamNum())
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("heal_player"), params);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("heal_player"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		
		if (isClient())
		{
			MakeParticleLine(this.getPosition() + Vec2f(0, -24), blob.getPosition(), 30);
		}
		if (isServer())
		{
			blob.server_Heal(this.get_f32(rate_prop));
		}
	}
}
	
bool getPrioritisedTargets(Vec2f pos, f32 radius, CBlob@[]@ targets)
{
	CMap@ map = getMap();
	CBlob@[] temp_targets;
	getBlobsByTag("player", temp_targets);
	getBlobsByTag("esau_clone", temp_targets);
	// remove players that are too far away
	for (int i = 0; i < temp_targets.size(); i++)
	{
		CBlob@ b = temp_targets[i];
		f32 factor = b.getHealth() / b.getInitialHealth();
		if (b is null || (b.getPosition() - pos).Length() > max_range || factor >= 1)
		{
			temp_targets.removeAt(i);
			i--;
		}
	}
	// sort remaining players by their health percentage
	while (!temp_targets.isEmpty())
	{
		CBlob@ lowesthp = temp_targets[0];
		f32 minfactor = 2;
		int index = 0;
		for (int i = 0; i < temp_targets.size(); i++)
		{
			CBlob@ b = temp_targets[i];
			if (b is null) continue;

			f32 factor = b.getHealth() / b.getInitialHealth();
			if (factor < minfactor)
			{
				index = 0;
				minfactor = factor;
				@lowesthp = @b;
			}
		}
		
		temp_targets.removeAt(index);
		targets.insertLast(@lowesthp);
	}

	return targets.size() > 0;
}	

// for (int i = 0; i < temp_targets.size(); i++)
	// {
	// 	CBlob@ lowesthp = temp_targets[i];
	// 	f32 minfactor = 2;
	// 	for (int j = i; j < temp_targets.size(); j++)
	// 	{
	// 		CBlob@ b = temp_targets[j];
	// 		if (b is null) continue;

	// 		f32 factor = b.getHealth() / b.getInitialHealth();
	// 		if (factor < 1 && factor < minfactor)
	// 		{
	// 			minfactor = factor;
	// 			@lowesthp = @b;
	// 		}
	// 	}

	// 	targets.insertLast(@lowesthp);

	// }

void MakeParticleLine(Vec2f start, Vec2f end, int density)
{
	Vec2f dist = end - start;
	for (int i = 0; i < density; i++)
	{
		Vec2f pos = start + dist * (float(i) / density);
		f32 radius = 1;
        Vec2f offset = Vec2f(radius, 0);
        offset.RotateByDegrees(XORRandom(3600) * 0.1f);
        Vec2f vel = -offset;
        vel.Normalize();
        vel *= 0.5f;
        vel.RotateByDegrees(XORRandom(3600) * 0.1f);

        CParticle@ p = ParticlePixel(pos + offset, vel, SColor(255, 252, 187, 8), true, 10);
        if (p !is null)
        {
			p.gravity = Vec2f(0,0);
            p.collides = false;
        }
	}
}	
