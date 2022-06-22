// Keg logic
#include "Hitters.as";

void onInit(CBlob@ this)
{
	// this.Tag("bomberman_style");
	this.Tag("spiky");
	this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 4.0f);
	this.set_bool("explosive_teamkill", true);
	this.set_u8("custom_hitter", Hitters::bomb_arrow);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 40.0f);
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 180.0f);  // 180.0f
	this.Tag("medium weight");

	this.set_u16("_keg_carrier_id", 0xffff);

	CSprite@ sprite = this.getSprite();

	sprite.SetZ(-10);

}

//sprite update


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(!solid || this.isAttached()) return;

	CShape@ shape = this.getShape();
	if(this.hasTag("spiky") && !shape.isStatic())
	{
		this.setPosition(normal * this.getRadius() + point1);
		shape.SetStatic(true);
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	const f32 angle = normal.Angle();
	// const f32 volume = shape.vellen / 4;

	sprite.ResetTransform();
	sprite.RotateBy(-angle + 90, Vec2f_zero);
	// collision sound managed by fabric script, Wooden.as
	// sprite.PlaySound("WoodHit.ogg", Maths::Min(volume, 1.0f));
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
