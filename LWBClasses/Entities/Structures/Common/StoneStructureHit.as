//added new hitters
//scale the damage:
//      knights cant damage
//      arrows cant damage

#include "Hitters.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::builder:
		case Hitters::hammer:
		case Hitters::acid:
			dmg *= 2.0f; //builder is great at smashing stuff
			break;

		case Hitters::sword:
		case Hitters::bayonet:
		case Hitters::spear:
		case Hitters::arrow:
		case Hitters::thrownspear:
		case Hitters::stab:
		case Hitters::shovel:
			dmg = 0.0f;
			break;

		case Hitters::bomb:
			dmg *= 0.5f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 2.5f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 8.0f;
			break;

		case Hitters::cata_stones:
			dmg *= 5.0f;
			break;
		case Hitters::crush:
			dmg *= 4.0f;
			break;

		case Hitters::flying: // boat ram
			dmg *= 7.0f;
			break;
			
		case Hitters::thrownrock:
			dmg *= 0.5f;
			break;

		case Hitters::bullet:
			dmg *= 1.5f;
			break;
	}

	return dmg;
}
