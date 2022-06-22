// Shield Logic!
#include "Hitters.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.Tag("medium weight");
	this.set_u16("_keg_carrier_id", 0xffff);
	CSprite@ sprite = this.getSprite();

	this.getShape().SetRotationsAllowed(false);
	//sprite.SetOffset(Vec2f(0, 0));
	sprite.SetZ(-10);
}

// Sprite
void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	// Destruction Frames
	if (blob.isAttached())
	{
		this.SetAnimation("held");
		this.animation.frame = 5;
	}
	else
	{
		this.SetAnimation("default");
		this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));
	}
}

void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	this.setVelocity(vel * 0.4);
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
				SetKnocked(carrier, 8);
			}
		}
	}

	this.getSprite().PlaySound("SwordCling");

	switch (customData)
	{
		case Hitters::sword:
			damage *= 1.5f;
			break;
		case Hitters::arrow:
			damage *= 0.5f; 
			break;
		case Hitters::keg:
			damage *= 0.75f;
			break;
		default:
			damage *= 0.5f; //half damage
	}

	return damage;
}
