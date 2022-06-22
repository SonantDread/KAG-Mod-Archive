void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 13, 17);
	if (back !is null)
	{
		back.SetRelativeZ(-1.0f);
		back.SetOffset(Vec2f(0, 0));
		back.SetFrameIndex(1);
	}

	this.Tag("furniture");
	this.Tag("usable by anyone");
	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_up);
	}
}

void onTick(CSprite@ this)
{
	this.SetZ(0.0f);
	
	CSpriteLayer@ back = this.getSpriteLayer("back");
	if (back !is null)
	{	
		back.SetRelativeZ(-20);
	}
}	

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		if (ap.isKeyJustPressed(key_up))
		{
			if (isServer())
			{
				CBlob@ pilot = ap.getOccupied();
				if (pilot !is null)  pilot.server_DetachFrom(this);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic() || blob.hasTag("furniture");
}
