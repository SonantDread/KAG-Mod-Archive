#include "Hitters.as"

const bool dangerous_logs = false;

void onInit(CSprite@ this)
{
	this.getBlob().server_setTeamNum(-1);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.getBlob().server_SetTimeToDie(60 * 5); // timeout
}
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}

// void onInit( CBlob@ this ){
// this.Tag("tree");
// }

//collide with vehicles and structures	- hit stuff if thrown

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool thrown = false;
	CPlayer @p = this.getDamageOwnerPlayer();
	CPlayer @bp = blob.getPlayer();
	if (p !is null && bp !is null && p.getTeamNum() != bp.getTeamNum())
	{
		thrown = true;
	}
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle")) ||
	        (dangerous_logs && this.hasTag("thrown") && blob.hasTag("flesh") && thrown)); // boat
}



void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (dangerous_logs)
	{
		this.Tag("thrown");
		this.SetDamageOwnerPlayer(detached.getPlayer());
		//	printf("thrown");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (dangerous_logs && this.hasTag("thrown"))
	{
		if (blob is null || !blob.hasTag("flesh"))
		{
			return;

		}

		CPlayer@ player = this.getDamageOwnerPlayer();
		if (player !is null && player.getTeamNum() != blob.getTeamNum())
		{
			const f32 dmg = this.getShape().vellen * 0.25f;
			if (dmg > 1.5f)
			{
				//	printf("un thrown " + dmg);
				this.server_Hit(blob, this.getPosition(), this.getVelocity(), dmg, Hitters::flying, false);  // server_Hit() is server-side only
			}
			this.Untag("thrown");
		}
	}
}
