// Quarters.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "StandardControlsCommon.as";
#include "GenericButtonCommon.as";
#include "MigrantCommon.as";
#include "ThrowCommon.as";

const f32 beer_amount = 1.0f;
const f32 heal_amount = 0.5f;
const u8 heal_rate = 30;

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
	this.SetEmitSoundVolume(0.1f);
}

void onInit(CBlob@ this)
{		   
	this.Tag("respawn");
	this.set_u32("Respawn in", 0); 		
	this.addCommandID("respawn");
	this.addCommandID("put migrant");
	this.addCommandID("out migrant");

	this.set_bool("BedAvailable", true);

	this.Tag("bed");

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.getCurrentScript().tickFrequency = 60;

	this.SetLight(false);
	this.SetLightRadius(64.0f);

	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		bed.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_pickup | key_inventory);
		bed.SetMouseTaken(true);
	}

	//this.getCurrentScript().runFlags |= Script::tick_hasattached;

	// ICONS
	AddIconToken("$quarters_beer$", "Quarters.png", Vec2f(24, 24), 7);
	AddIconToken("$quarters_meal$", "Quarters.png", Vec2f(48, 24), 2);
	AddIconToken("$quarters_egg$", "Quarters.png", Vec2f(24, 24), 8);
	AddIconToken("$quarters_burger$", "Quarters.png", Vec2f(24, 24), 9);

	AddIconToken("$put_migrant$", "Entities/Characters/Migrant/MigrantIcon.png", Vec2f(18, 18), 0);
	AddIconToken("$out_migrant$", "Entities/Characters/Migrant/MigrantIcon.png", Vec2f(18, 18), 0);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Beer - 1 Heart", "$quarters_beer$", "beer", Descriptions::beer, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Meal - Full Health", "$quarters_meal$", "meal", Descriptions::meal, false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Egg - 2 Hearts", "$quarters_egg$", "egg", Descriptions::egg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Burger - Full Health", "$quarters_burger$", "food", Descriptions::burger, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null)
	{
		CBlob@[] blobsInRadius;
		if (getMap().getBlobsInRadius(this.getPosition(), this.getRadius(), @blobsInRadius))
		{
			const u8 teamNum = this.getTeamNum();
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (bedAvailable(this) && b.hasTag("migrant"))
				{
					b.server_DetachFromAll();
					this.server_AttachTo(b, "BED");
					this.getSprite().PlaySound("PopIn.ogg");
				}

				if (b.getTeamNum() == teamNum && b.getHealth() < b.getInitialHealth() && bed.getOccupied() !is null && b.hasTag("flesh") && !b.hasTag("dead"))
				{
					b.server_Heal(heal_amount);
					b.getSprite().PlaySound("/Heart.ogg");
				}
			}
		}

		bool isServer = getNet().isServer();
		CBlob@ migrant = bed.getOccupied();
		if (migrant !is null)
		{
			if (migrant.getHealth() == 0)
			{
				if (isServer)
				{
					migrant.server_DetachFrom(this);
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");

	CBlob@ carried = caller.getCarriedBlob();
	CBitStream params;
	if (carried is null || !carried.hasTag("migrant"))
	{
		if(bedAvailable(this) == false){
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$out_migrant$", Vec2f(-5, 0), this, this.getCommandID("out migrant"), "Wake up", params);
		}
		else{
			CButton@ button = caller.CreateGenericButton("$out_migrant$", Vec2f(-5, 0), this, 0, "Requires Migrant");
			if (button !is null)
				button.SetEnabled(false);
		}
	}
	else if (carried !is null && carried.hasTag("migrant"))
	{
		if(bedAvailable(this) == false){
			CButton@ button = caller.CreateGenericButton("$out_migrant$", Vec2f(-5, 0), this, 0, "Room is full");
			if (button !is null)
				button.SetEnabled(false);
		}
		else{
			params.write_u16(carried.getNetworkID());
			caller.CreateGenericButton("$put_migrant$", Vec2f(-5, 0), this, this.getCommandID("put migrant"), "Tuck into bed", params);
		}
	}

	this.set_Vec2f("shop offset", Vec2f(5, 0));

	this.set_bool("shop available", true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			if (name == "beer")
			{
				// TODO: gulp gulp sound
				if (isServer)
				{
					callerBlob.server_Heal(beer_amount);
				}
			}
			else if (name == "meal")
			{
				this.getSprite().PlaySound("/Eat.ogg");
				if (isServer)
				{
					callerBlob.server_SetHealth(callerBlob.getInitialHealth());
				}
			}
		}
	}
	else if (cmd == this.getCommandID("put migrant"))
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
				if (isServer)
				{
					caller.server_DetachFromAll();
					this.server_AttachTo(caller, "BED");
					this.getSprite().PlaySound("PopIn.ogg");
				}
			}
		}
	}
	else if (cmd == this.getCommandID("out migrant"))
	{
		AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
		if (bed !is null)
		{
			CBlob@ patient = bed.getOccupied();
			if (patient !is null)
			{
				if (isServer)
				{
					patient.server_DetachFrom(this);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("respawn"))
	{
		AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
		if (bed !is null)
		{
			CBlob@ patient = bed.getOccupied();
			if (patient !is null)
			{
				if (isServer)
				{
					patient.server_Die();
					patient.server_DetachFrom(this);
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (getNet().isServer())
	{
		if(blob !is null && blob.hasTag("migrant"))
		{
			AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
			if (bed !is null && bedAvailable(this))
			{
				blob.server_DetachFromAll();
				this.server_AttachTo(blob, "BED");
				this.getSprite().PlaySound("PopIn.ogg");
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	int num = getRules().get_s32("num_migrantsinbed");
	getRules().set_s32("num_migrantsinbed", num + 1);
	this.set_bool("BedAvailable", bedAvailable(this));
	attached.getShape().getConsts().collidable = false;
	attached.SetFacingLeft(true);

	this.SetLight(true);

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
	int num = getRules().get_s32("num_migrantsinbed");
	getRules().set_s32("num_migrantsinbed", num - 1);
	this.set_bool("BedAvailable", bedAvailable(this));
	detached.getShape().getConsts().collidable = true;
	detached.AddForce(Vec2f(0, -20));

	this.SetLight(false);

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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.0f)
	{
		AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
		if (bed !is null)
		{
			CBlob@ patient = bed.getOccupied();
			if (patient !is null)
			{
				if(hitterBlob.hasTag("zombie"))
				{
					CBitStream params;
					params.write_u16(0);
					this.SendCommand(this.getCommandID("out migrant"), params);
					if (getGameTime() - this.get_u32("last_scream_time") > 60)
					{
						this.getSprite().PlaySound("/MigrantScream", 1.0f, 1.5f);
						this.set_u32("last_scream_time", getGameTime());
					}
				}
				else
					this.getSprite().PlaySound("/MigrantHmm");
			}
		}
	}
	return damage;
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