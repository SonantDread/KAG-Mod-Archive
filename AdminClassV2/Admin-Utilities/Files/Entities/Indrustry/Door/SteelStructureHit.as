#include "Hitters.as";
#include "Hitters2.as";
#include "FUNHitters.as";
#include "GunHitters.as";
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.Tag("metal");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool heavy = this.hasTag("heavy weight");
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::builder:
			dmg *= 1.25f;
			if (hitterBlob.hasTag("primary")) DoMetalHitFX(this);
			break;

		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg = 0.0f;
			break;

		case Hitters::bomb:
			dmg *= 0.05f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.01f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 0.01f;
			break;

		case Hitters::cata_stones:
			dmg *= 0.0f;
			break;
		case Hitters::crush:
			dmg *= 4.0f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 0.2f;
			break;
			
			// ZOMBIE 
			
			case Hitters2::bite:
			dmg *= 0.1f;
			break;
			
			case FUNHitters::zombie: 
			dmg *= 0.1f;
			break;
			
			case FUNHitters::skeleton: 
			dmg *= 0.1f;
			break;
			
			// GUN
			
			case GunHitters::bullet: // boat ram
			dmg *= 0.1f;
			break;
	}

    return dmg;
}

void DoMetalHitFX(CBlob@ this)
{
	this.getSprite().PlaySound("dig_stone.ogg", 1.0f, 0.8f + (XORRandom(100) / 1000.0f));
	// sparks(this.getPosition(), 1, 1);
}