// Quarters.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "StandardControlsCommon.as"
#include "Health.as";

const f32 beer_amount = 1.0f;
const f32 heal_amount = 0.25f;
const u8 heal_rate = 60;

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
		bed.SetOffset(Vec2f(-5, 4));
		bed.SetVisible(true);
		bed.SetRelativeZ(-150.0f);
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

	this.SetEmitSound("MigrantSleep.ogg");
	this.SetEmitSoundPaused(true);
	this.SetEmitSoundVolume(0.5f);
}

void onInit(CBlob@ this)
{

	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(+50); //foreground
	this.getShape().getConsts().mapCollisions = false;

	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		bed.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_pickup | key_inventory);
		bed.SetMouseTaken(true);
	}

	this.addCommandID("rest");
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onTick(CBlob@ this)
{
	// TODO: Add stage based sleeping, rest(2 * 30) | sleep(heal_amount * (patient.getHealth() - patient.getInitialHealth())) | awaken(1 * 30)
	// TODO: Add SetScreenFlash(rest_time, 19, 13, 29) to represent the player gradually falling asleep
	bool isServer = getNet().isServer();
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		CBlob@ patient = bed.getOccupied();
		if (patient !is null)
		{
			if (bed.isKeyJustPressed(key_up) || patient.getHealth() == 0)
			{
				if (isServer)
				{
					patient.server_DetachFrom(this);
				}
			}
			else if (getGameTime() % heal_rate == 0)
			{
				if (requiresTreatment(this, patient))
				{
					if (patient.isMyPlayer())
					{
						Sound::Play("Heart.ogg", patient.getPosition());
					}
				}
				if (isServer)
				{
					server_Heal(patient,0.25f);
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// TODO: fix GetButtonsFor Overlapping, when detached this.isOverlapping(caller) returns false until you leave collision box and re-enter
	Vec2f tl, br, c_tl, c_br;
	this.getShape().getBoundingRect(tl, br);
	caller.getShape().getBoundingRect(c_tl, c_br);
	bool isOverlapping = br.x - c_tl.x > 0.0f && br.y - c_tl.y > 0.0f && tl.x - c_br.x < 0.0f && tl.y - c_br.y < 0.0f;

	if(isOverlapping && bedAvailable(this))// || !requiresTreatment(this, caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(29, Vec2f(0, 0), this, this.getCommandID("rest"), getTranslatedString("Rest"), params);
	}
	this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("rest"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
			if (bed !is null && bedAvailable(this))
			{
				CBlob@ carried = caller.getCarriedBlob();
				if (isServer)
				{
					if (carried !is null)
					{
						if (!caller.server_PutInInventory(carried))
						{
							carried.server_DetachFrom(caller);
						}
					}
					this.server_AttachTo(caller, "BED");
				}
			}
		}
	}
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
		sprite.SetEmitSoundPaused(true);
	}
}

void updateLayer(CSprite@ sprite, string name, int index, bool visible, bool remove)
{
	if (sprite !is null)
	{
		CSpriteLayer@ layer = sprite.getSpriteLayer(name);
		if (layer !is null)
		{
			if (remove == true)
			{
				sprite.RemoveSpriteLayer(name);
				return;
			}
			else
			{
				layer.SetFrameIndex(index);
				layer.SetVisible(visible);
			}
		}
	}
}

bool bedAvailable(CBlob@ this)
{
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		CBlob@ patient = bed.getOccupied();
		if (patient !is null)
		{
			return false;
		}
	}
	return true;
}

bool requiresTreatment(CBlob@ this, CBlob@ caller)
{
	return getHealth(caller) < getHealthMax(caller) && (!caller.isAttached() || caller.isAttachedTo(this));
}
