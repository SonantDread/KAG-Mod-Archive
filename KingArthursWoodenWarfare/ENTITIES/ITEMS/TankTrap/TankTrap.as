#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.Tag("heavy weight");
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() == blob.getTeamNum();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return customData == Hitters::builder? this.getInitialHealth() / 3 : damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("vehicle") && this.getTeamNum() != blob.getTeamNum())
	{
		return true;
	}

	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getNet().isServer() && blob !is null)
	{
		if (blob.hasTag("vehicle") && this.getTeamNum() != blob.getTeamNum())
		{
			if (blob.getHealth() - 12.0f < 0.0f)
			{
				blob.server_Die();
			}
			else
			{
				blob.server_SetHealth(blob.getHealth() - 12.0f);
			}
			if (blob.isOnMap())
			{
				Vec2f vel = blob.getVelocity();
				blob.setVelocity(vel * 0.00f);
			}

			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
	}
}