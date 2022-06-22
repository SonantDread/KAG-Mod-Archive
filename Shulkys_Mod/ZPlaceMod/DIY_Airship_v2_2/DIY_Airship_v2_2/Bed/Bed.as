void onInit(CBlob@ this)
{
	this.Tag("furniture");
	this.Tag("usable by anyone");
	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority
	
	this.SetZ(-50); //background
	this.SetFrame(0);
	
	void onInit(CSprite@ this)
{
	CSpriteLayer@ bed = this.addSpriteLayer("bed", "Quarters.png", 32, 16);
	if (bed !is null)
	{
		{
			bed.addAnimation("default", 0, false);
			int[] frames = {14, 15};
			bed.animation.AddFrames(frames);
		}
		bed.SetOffset(Vec2f(1, 4));
		bed.SetVisible(true);
	}

	CSpriteLayer@ zzz = this.addSpriteLayer("zzz", "Quarters.png", 8, 8);
	if (zzz !is null)
	{
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {96, 97, 98, 98, 99};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(-3, -6));
		zzz.SetLighting(false);
		zzz.SetVisible(false);
	}

	CSpriteLayer@ backpack = this.addSpriteLayer("backpack", "Quarters.png", 16, 16);
	if (backpack !is null)
	{
		{
			backpack.addAnimation("default", 0, false);
			int[] frames = {26};
			backpack.animation.AddFrames(frames);
		}
		backpack.SetOffset(Vec2f(-14, 7));
		backpack.SetVisible(false);
	}

	this.SetEmitSound("MigrantSleep.ogg");
	this.SetEmitSoundPaused(true);
	this.SetEmitSoundVolume(0.5f);
	
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

// Commented out just in case someone would want to have a jewish wedding in TC
// bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
// {
	// return !this.hasAttached();
// }

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("furniture");
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.getShape().getConsts().collidable = false;
	attached.SetFacingLeft(true);
	attached.AddScript("WakeOnHit.as");

	if (not getNet().isClient()) return;

	CSprite@ sprite = this.getSprite();

	if (sprite is null) return;

	updateLayer(sprite, "bed", 1, true, false);
	updateLayer(sprite, "zzz", 0, true, false);
	updateLayer(sprite, "backpack", 0, true, false);

	sprite.SetEmitSoundPaused(false);
	sprite.RewindEmitSound();

	CSprite@ attached_sprite = attached.getSprite();

	if (attached_sprite is null) return;

	attached_sprite.SetVisible(false);
	attached_sprite.PlaySound("GetInVehicle.ogg");

	CSpriteLayer@ head = attached_sprite.getSpriteLayer("head");

	if (head is null) return;

	Animation@ head_animation = head.getAnimation("default");

	if (head_animation is null) return;

	CSpriteLayer@ bed_head = sprite.addSpriteLayer("bed head", head.getFilename(),
		16, 16, attached.getTeamNum(), attached.getSkinNum());

	if (bed_head is null) return;

	Animation@ bed_head_animation = bed_head.addAnimation("default", 0, false);

	if (bed_head_animation is null) return;

	bed_head_animation.AddFrame(head_animation.getFrame(2));

	bed_head.SetAnimation(bed_head_animation);
	bed_head.RotateBy(80, Vec2f_zero);
	bed_head.SetOffset(Vec2f(1, 2));
	bed_head.SetFacingLeft(true);
	bed_head.SetVisible(true);
	bed_head.SetRelativeZ(2);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.getShape().getConsts().collidable = true;
	detached.AddForce(Vec2f(0, -20));
	detached.RemoveScript("WakeOnHit.as");

	CSprite@ detached_sprite = detached.getSprite();
	if (detached_sprite !is null)
	{
		detached_sprite.SetVisible(true);
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		updateLayer(sprite, "bed", 0, true, false);
		updateLayer(sprite, "zzz", 0, false, false);
		updateLayer(sprite, "bed head", 0, false, true);
		updateLayer(sprite, "backpack", 0, false, false);

		sprite.SetEmitSoundPaused(true);
	}
}