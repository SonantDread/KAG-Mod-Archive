// Flesh hit

#include "Hitters.as";
#include "HittersTC.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
}

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
	f32 dmg = damage;

	switch (customData)
	{
		case Hitters::builder:
			dmg *= 1.75f;
			break;

		case Hitters::spikes:
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 1.25f;
			break;

		case Hitters::drill:
			dmg *= 1.50f;
			break;
			
		case Hitters::bomb_arrow:
		case Hitters::bomb:
			dmg *= 1.50f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 2.00f;
			break;

		case Hitters::fire:
			dmg *= 4.00f;
			break;
		
		case Hitters::burn:
			dmg *= 2.50f;
			break;
			
		case Hitters::cata_stones:
			dmg *= 4.00f;
			break;
		case Hitters::crush:
			dmg *= 2.00f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 4.00f;
			break;
		
		// TC		
		case HittersTC::bullet_low_cal:
			dmg *= 1.00f;
			break;
			
		case HittersTC::bullet_high_cal:
			dmg *= 1.00f;
			break;
			
		case HittersTC::shotgun:
			dmg *= 1.00f;
			break;
			
		case HittersTC::radiation:
			// dmg = Maths::Max((dmg * 2.00f) * (this.get_u8("radpilled") * 0.10f), 0);
			dmg *= 2.00f / (1.00f + this.get_u8("radpilled") * 10.00f);
			break;
	}

	// switch (customData)
	// {
		// case Hitters::fire:
			// damage *= 1.5f;
			// break;
		
		// case Hitters::burn:
			// damage *= 1.25f;
			// break;
	
		// case Hitters::suddengib:
			// damage /= (1.00f + this.get_u8("radpilled") * 4.00f);
			// break;
	
		// default:
			// break;
	// }

	if (getNet().isServer())
	{
		if (customData == HittersTC::radiation)
		{
			if (this.hasTag("human") && !this.hasTag("transformed") && this.getHealth() <= 0.125f && XORRandom(3) == 0)
			{
				CBlob@ man = server_CreateBlob("mithrilman", this.getTeamNum(), this.getPosition());
				if (this.getPlayer() !is null) man.server_SetPlayer(this.getPlayer());
				this.Tag("transformed");
				this.server_Die();
			}
		}
	}
	
	if (this.hasTag("equipment support"))
	{
		if ((this.get_string("equipment_torso") == "bulletproofvest") && (customData == HittersTC::bullet_low_cal || customData == HittersTC::bullet_high_cal || customData == HittersTC::shotgun))
		{
			f32 vestMaxHealth = 25.0f;
			f32 vestHealth = vestMaxHealth - this.get_f32("bpv_health");
			f32 ratio = vestHealth / vestMaxHealth;

			switch (customData)
			{
				case HittersTC::bullet_low_cal:
					ratio = ratio * 0.80f;
					break;
			
				case HittersTC::bullet_high_cal:
					ratio = ratio * 0.70f;
					break;
					
				case HittersTC::shotgun:
					ratio = ratio * 0.85f;
					break;
					
				default:
					ratio = ratio * 0.90f;
			}
			
			f32 vestDamage = ratio * dmg;
			f32 curVestHp = this.get_f32("bpv_health");
			
			this.set_f32("bpv_health", curVestHp + vestDamage);
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			
			dmg = playerDamage;
		}
		
		if ((this.get_string("equipment_head") == "militaryhelmet") && (customData == HittersTC::bullet_low_cal || customData == HittersTC::bullet_high_cal || customData == HittersTC::shotgun))
		{
			f32 mhelmetMaxHealth = 20.0f;
			f32 mhelmetHealth = mhelmetMaxHealth - this.get_f32("mh_health");
			f32 ratio = mhelmetHealth / mhelmetMaxHealth;

			switch (customData)
			{
				case HittersTC::bullet_low_cal:
					ratio = ratio * 0.80f;
					break;
			
				case HittersTC::bullet_high_cal:
					ratio = ratio * 0.70f;
					break;
					
				case HittersTC::shotgun:
					ratio = ratio * 0.85f;
					break;
					
				default:
					ratio = ratio * 0.60f;
			}
			
			f32 mhelmetDamage = ratio * dmg;
			f32 curmhelmetHp = this.get_f32("mh_health");
			
			this.set_f32("mh_health", curmhelmetHp + mhelmetDamage);
			
			// f32 playerDamage = Maths::Clamp(mhelmetDamage - dmg, 0, dmg);
			f32 playerDamage = Maths::Clamp((1.00f - ratio) * dmg, 0, dmg);
			
			// print("" + playerDamage);
			
			dmg = playerDamage;
		}
	}
	
	this.Damage(dmg, hitterBlob);

	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}
