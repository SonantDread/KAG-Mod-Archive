#include "MagicCommon.as";
void onInit(CBlob@ this)
{
	if(getNet().isServer())
	{
		this.server_SetTimeToDie(60.0f);
	}
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetGravityScale(0.0f);
}
void onTick(CBlob@ this)
{
	this.setVelocity(Vec2f(0, Maths::Sin( (this.getTickSinceCreated() + 20.0f) / 10.0f ) / 2.0f ) );
	if(this.getTickSinceCreated() % 2 == 0)
	{
		this.set_u16("charge", Maths::Min(1400, this.get_u16("charge") + 1)); //increment charge
	}
	if(canCast(this))
	{
		doSpellStuff(this, this.get_Vec2f("aimpos"));
	}
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}