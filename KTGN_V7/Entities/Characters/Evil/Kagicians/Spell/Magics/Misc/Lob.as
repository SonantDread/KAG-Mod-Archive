//Lob the player upwards.
#include "MagicalHitters.as";
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	//if(customData == MagicalHitters::Magic)
	{
		Vec2f vel = this.getOldVelocity();
		vel.Normalize();
		vel *= this.get_u16("charge");
		vel /= 60.0f;
		hitBlob.setVelocity(hitBlob.getVelocity() + vel);
	}
}