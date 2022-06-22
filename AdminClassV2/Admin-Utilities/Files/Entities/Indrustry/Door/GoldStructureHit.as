//scale the damage:
//      knights cant damage
//      arrows cant damage

#include "Hitters.as";
#include "Hitters2.as";
#include "FUNHitters.as";
#include "GunHitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
   
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::builder:
			dmg *= 1.0f; //builder is great at smashing stuff
			break;

		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg = 0.0f;
			break;

		case Hitters::bomb:
			dmg *= 0.2f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 1.5f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 4.0f;
			break;

		case Hitters::cata_stones:
			dmg *= 2.0f;
			break;
		case Hitters::crush:
			dmg *= 4.0f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 3.0f;
			break;
			
			// ZOMBIE 
			
			case Hitters2::bite:
			dmg *= 1.0f;
			break;
			
			case FUNHitters::zombie: 
			dmg *= 1.0f;
			break;
			
			case FUNHitters::skeleton: 
			dmg *= 1.0f;
			break;
			
			// GUN
			
			case GunHitters::bullet: // boat ram
			dmg *= 0.2f;
			break;
	}

    return dmg;
}
