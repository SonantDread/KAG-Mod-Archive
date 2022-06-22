#include "Hitters.as";

void onInit(CBlob@ this)
{
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");

    if (ap !is null)
    {
        ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
    }

    this.Tag("place45");
    this.set_s8("place45 distance", 1);
	this.Tag("place45 perp");

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		u32 delay = this.get_u32("shoot delay");
		delay++;
		this.set_u32("shoot delay", delay);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

		if (!point.isKeyPressed(key_action1) || delay < 30)
		{
			return;
		}

		if (getNet().isServer())
		{
			CBlob@ rocket = server_CreateBlobNoInit("rocket");
			if (rocket !is null)
			{
				CBlob@ holder = point.getOccupied();

				Vec2f Pos = holder.getPosition() ;
				Vec2f Vel = holder.getAimPos() - Pos;
				Vel.Normalize();
				Vel*=15;

				rocket.set_u8("arrow type", 0);
				rocket.Init();
				rocket.IgnoreCollisionWhileOverlapped(this);
				rocket.SetDamageOwnerPlayer(this.getPlayer());
				rocket.server_setTeamNum(this.getTeamNum());
				rocket.setPosition(Pos);
				rocket.setVelocity(Vel);
				rocket.set_Vec2f("initvel", Vel);
			}
		}
		this.getSprite().PlaySound("catapult_destroy");
		this.set_u32("shoot delay", 0);
	}
}

void onInit(CSprite@ this)
{
	this.getBlob().getShape().SetRotationsAllowed(false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	this.SetZ(blob.isAttached() ? 10.0f: -10.0f);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}