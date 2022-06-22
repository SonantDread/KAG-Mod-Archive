#include "Hitters.as"
#include "FighterMovesetCommon.as"

#include "FireCommon.as"

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);

	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = true;

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 89, false);
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

	this.set_bool("check for player", false);

	this.getCurrentScript().tickFrequency = 0;
}

void onTick(CBlob@ this)
{
	bool checkPlayerCollisions = this.get_bool("check for player");

	if (checkPlayerCollisions)
	{
		bool touchingPlayer = false;

		int touchingCount = this.getTouchingCount();
		if (touchingCount > 0)
		{
			for (uint i = 0; i < touchingCount; i++)
			{
				CBlob@ touchingBlob = this.getTouchingByIndex(i);
				if (touchingBlob !is null)
				{
					if (touchingBlob.hasTag("player"))
					{
						if (canFallThrough(touchingBlob))
						{
							this.getShape().checkCollisionsAgain = true;
						}

						touchingPlayer = true;
					}
				}
			}
		}

		if (!touchingPlayer)
		{
			this.set_bool("check for player", false);
			this.getCurrentScript().tickFrequency = 0;
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (canFallThrough(blob))
	{
		return false;
	}

	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null)
		return;

	if (blob.hasTag("player"))
	{
		this.set_bool("check for player", true);
		this.getCurrentScript().tickFrequency = 1;
	}
}

bool canFallThrough(CBlob@ blob)
{
	bool inMoveAnimation = false;

	SSKFighterVars@ fighterVars;
	if (blob.get("fighterVars", @fighterVars))
	{
		inMoveAnimation = fighterVars.inMoveAnimation;
	}

	return !inMoveAnimation && blob.isKeyPressed(key_down) && !blob.isKeyPressed(key_left) && !blob.isKeyPressed(key_right);
}