// Keg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("bomberman_style");
	this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 64.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_u8("custom_hitter", Hitters::keg);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 72.0f);
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 180.0f);  // 180.0f
	this.Tag("can grapple");
	this.Tag("medium weight");

	this.set_u16("_keg_carrier_id", 0xffff);
	this.set_bool("flipped_rotation", XORRandom(2) == 1);
	this.Sync("flipped_rotation", true);

	this.set_f32("rotation", XORRandom(15) == 0 ? 15.0f : ((XORRandom(35) + 10) * 0.1f));
	this.Sync("rotation", true);

	this.set_u32("flip_freq", XORRandom(7) == 0 ? 6000 : XORRandom(35) + 20);
	this.Sync("flip_freq", true);

	this.set_f32("speed", XORRandom(20) == 0 ? 1.0f : ((XORRandom(120) + 100) * 0.1f));
	this.Sync("speed", true);
	

	CSprite@ sprite = this.getSprite();

	sprite.SetZ(-10);

	CSpriteLayer@ fuse = this.getSprite().addSpriteLayer("fuse", "Keg.png" , 16, 16, 0, 0);

	if (fuse !is null)
	{
		fuse.addAnimation("default", 0, false);
		int[] frames = {8, 9, 10, 11, 12, 13};
		fuse.animation.AddFrames(frames);
		fuse.SetOffset(Vec2f(3, -4));
		fuse.SetRelativeZ(1);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = point.getOccupied();
	if (holder !is null)
	{
		Vec2f ray = holder.getAimPos() - this.getPosition();
		ray.Normalize();
		f32 angle = ray.Angle();
		this.setAngleDegrees(-angle + 90);
	}
	
	if (this.hasTag("exploding") && !this.isAttached())
	{
		this.getShape().SetGravityScale(0.25f);
		Vec2f force(0, -this.get_f32("speed"));
		if (force.Length() < 5.0f)
		{
			this.getShape().SetGravityScale(1.0f);
		}

		f32 angle = this.getAngleDegrees();
		force.RotateByDegrees(angle);

		if (getGameTime() % this.get_u32("flip_freq") == 0)
		{
			this.set_bool("flipped_rotation", !this.get_bool("flipped_rotation"));//XORRandom(2) == 1);
			this.Sync("flipped_rotation", true);
		}

		f32 rotation = this.get_f32("rotation");
		rotation *= this.get_f32("speed") / 15.0f;
		if (this.get_bool("flipped_rotation")) rotation *= -1.0f;

		this.setAngleDegrees(angle + (this.isFacingLeft() ? -rotation : rotation));
		this.AddForce(force);
	}
	else
	{
		this.getShape().SetGravityScale(1.0f);
	}
}
//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));

	s32 timer = blob.get_s32("explosion_timer") - getGameTime();

	if (blob.hasTag("exploding"))if(!this.isAnimation("flying"))this.SetAnimation("flying");
	
	if (timer < 0)
	{
		return;
	}

	CSpriteLayer@ fuse = this.getSpriteLayer("fuse");

	if (fuse !is null)
	{
		fuse.animation.frame = 1 + (fuse.animation.getFramesCount() - 1) * (1.0f - ((timer + 5) / f32(blob.get_f32("keg_time"))));
	}

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		this.set_u16("_keg_carrier_id", attached.getNetworkID());
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isServer() &&
	        !isExplosionHitter(customData) &&
	        (hitterBlob is null || hitterBlob.getTeamNum() != this.getTeamNum()))
	{
		u16 id = this.get_u16("_keg_carrier_id");
		if (id != 0xffff)
		{
			CBlob@ carrier = getBlobByNetworkID(id);
			if (carrier !is null)
			{
				this.server_DetachFrom(carrier);
			}
		}
	}

	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
			damage *= 0.25f; //quarter damage from these
			break;
		default:
			damage *= 0.5f; //half damage from everything else
	}

	return damage;
}
