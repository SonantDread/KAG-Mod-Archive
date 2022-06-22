
#include "Hitters.as"
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::sword:
			damage *= 1.0f;
			break;
		case Hitters::bomb:
			damage *= 0.25f;
			break;
		case Hitters::explosion:
			damage *= 0.5f;
			break;
		case Hitters::bomb_arrow:
			damage *= 0.25f;
			break;

	}
	return damage;
}

