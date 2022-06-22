#include "/Entities/Common/Attacks/Hitters.as";
#include "Knocked.as"

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (!solid)
	{
		return;
	}

	//dead bodies dont stomp
	if (this.hasTag("dead"))
	{
		return;
	}

	// server only
	if (!getNet().isServer() || !blob.hasTag("player")) {return;}

	if (this.getPosition().y < blob.getPosition().y - 2)
	{
		float enemydam = 0.0f;
		f32 vely = this.getOldVelocity().y;

		if (vely > 10.0f)
		{
			enemydam = 2.0f;
		}
		else if (vely > 9.0f)
		{
			enemydam = 1.75f;
		}
		else if (vely > 8.0f)
		{
			enemydam = 1.5f;
		}
		else if (vely > 7.0f)
		{
			enemydam = 1.25f;
		}
		else if (vely > 5.5f)
		{
			enemydam = 1.0f;
		}
		else if (vely > 4.0f)
		{
			enemydam = 0.5f;
		}

		if (enemydam > 0)
		{
			this.server_Hit(blob, this.getPosition(), Vec2f(0, 1) , enemydam, Hitters::stomp);
		}
	}
}

// effects

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::stomp && damage > 0.0f && velocity.y > 0.0f && worldPoint.y < this.getPosition().y)
	{
		this.getSprite().PlaySound("Entities/Characters/Sounds/Stomp.ogg");
		// stun based on damage
		if (damage >= 1.5f)
		{
			SetKnocked(this, 15);
		}
		else if (damage >= 1.0f)
		{
			SetKnocked(this, 8);
		}
		else
		{
			SetKnocked(this, 4);
		}
	}

	return damage;
}
