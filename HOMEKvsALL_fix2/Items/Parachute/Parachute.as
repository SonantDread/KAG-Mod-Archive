#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.set_u8("floating",0);
}


void onTick(CBlob@ this)
{
	if(this.get_u8("floating") > 0)this.set_u8("floating",this.get_u8("floating")-1);
	if (this.isAttached())
	{
		AttachmentPoint@ att = this.getAttachmentPoint(0);
		if (att !is null)
		{
			CBlob@ b = att.getOccupied();
			if (b !is null)
			{
				Vec2f vel = b.getVelocity();
				if (vel.y > 0.0f)
				{
					Vec2f vel = b.getVelocity();
					b.setVelocity(Vec2f(vel.x,vel.y/3));
					this.set_u8("floating",5);
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isWaterHitter(customData))
	{
		this.server_DetachFromAll();
	}

	return damage;
}


//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.animation.frame = 0;
	if(blob.get_u8("floating") > 0)this.animation.frame = 1;

}
