// MiniCluster logic
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
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		this.set_u16("_keg_carrier_id", attached.getNetworkID());
	}
	for (int i = 0; i < 15; i++)
	{
		CBlob@ drop = server_CreateBlob("keg",-1,this.getPosition() + Vec2f(80 - XORRandom(160), 80 - XORRandom(160)));
		if (drop !is null)
		{
			drop.SendCommand(drop.getCommandID("activate"));

			Vec2f vel(10 - XORRandom(20), -XORRandom(20));
			drop.setVelocity(vel * 1.5);
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