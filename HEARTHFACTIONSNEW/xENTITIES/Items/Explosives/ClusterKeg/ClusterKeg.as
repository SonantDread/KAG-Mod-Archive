// ClusterKeg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("bomberman_style");
	this.set_f32("map_bomberman_width", 100.0f);
	this.set_f32("explosive_radius", 200.0f);
	this.set_f32("explosive_damage", 20.0f);
	this.set_u8("custom_hitter", Hitters::keg);
	this.set_string("custom_explosion_sound", "ClusterKegExplode.ogg");
	this.set_f32("map_damage_radius", 300.0f);
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", false);
	this.set_f32("keg_time", 360.0f);
	this.Tag("heavy weight");

	this.set_u16("_keg_carrier_id", 0xffff);

	CSprite@ sprite = this.getSprite();

	sprite.SetZ(-10);

	CSpriteLayer@ fuse = this.getSprite().addSpriteLayer("fuse", "ClusterKeg.png" , 24, 24, 0, 0);

	if (fuse !is null)
	{
		fuse.addAnimation("default", 0, false);
		int[] frames = {8, 9, 10, 11, 12, 13};
		fuse.animation.AddFrames(frames);
		fuse.SetOffset(Vec2f(3, -4));
		fuse.SetRelativeZ(1);
	}
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));

	s32 timer = blob.get_s32("explosion_timer") - getGameTime();

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

void onDie(CBlob@ this)
{
	for (int i = 0; i < 8; i++)
	{
		CBlob@ drop = server_CreateBlob("minicluster",-1,this.getPosition() + Vec2f(70 - XORRandom(140), 70 - XORRandom(140)));
		if (drop !is null)
		{
			drop.set_f32("keg_time", XORRandom(200) + 70.0f);
			drop.SendCommand(drop.getCommandID("activate"));

			Vec2f vel(8 - XORRandom(16), -XORRandom(10));
			drop.setVelocity(vel * 1.7);
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.isInFlames() && !this.hasTag("exploding"))
	{
		this.SendCommand(this.getCommandID("activate"));
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	s32 timer = this.get_s32("explosion_timer") - getGameTime();
	if (timer > 60 || timer < 0 || this.getDamageOwnerPlayer() is null) // don't change keg ownership for final 2 seconds of fuse
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}
	
	if (isServer())
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
		case Hitters::water:
			if (hitterBlob.getName() == "bucket" && this.hasTag("exploding"))
			{
				this.SendCommand(this.getCommandID("deactivate"));
			}
			break;
		case Hitters::keg:
			if (!this.hasTag("exploding"))
			{
				this.SendCommand(this.getCommandID("activate"));
			}
			//set fuse to shortest fuse time - either current time or new random time
			//so it doesn't explode at the exact same time as hitter keg
			this.set_s32("explosion_timer", Maths::Min(this.get_s32("explosion_timer"), getGameTime() + XORRandom(this.get_f32("keg_time")) / 3));

			damage *= 0.0f; //invincible to allow keg chain reaction
			break;
		default:
			damage *= 0.5f; //half damage from everything else
	}

	return damage;
}
