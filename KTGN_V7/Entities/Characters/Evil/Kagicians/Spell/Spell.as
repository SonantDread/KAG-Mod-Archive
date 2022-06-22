void onInit(CBlob@ this)
{
	//Nothing yet.
	if(getNet().isServer())
	{
		//this.server_SetTimeToDie(14.0f);
	}
	this.getShape().getConsts().bullet = true;
	CSprite@ sprite = this.getSprite();
	Animation@ anim = sprite.addAnimation("Explode", 0, false);
	anim.AddFrame(3);
}
void onTick(CBlob@ this)
{
	int charge = this.get_u16("charge");
	if(charge <= 2)
	{
		this.getSprite().Gib();
		if(getNet().isServer())
		{
			this.server_Die();
		}
	}
	if(getGameTime() % 20 == 1)
	{
		u16 newcharge = charge / 1.05f; //dividing nerfs the larger stuff
		newcharge -= 1;
		this.set_u16("charge", Maths::Max(newcharge, 1));
		float scale = float(newcharge) / float(charge);
		scale *= 1.001f;
		this.getSprite().ScaleBy(Vec2f(scale, scale)); //innacurate, just to show that it is decreasing in strength.
	}
	if(!this.isOnGround() && !this.getShape().isStatic() || this.getVelocity().x > 0.4f)
	{
		this.setAngleDegrees(this.getVelocity().Angle() * -1 + (this.isFacingLeft() ? 180 : 0));
	}
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("player") || blob.hasTag("flesh") || this.getName() == blob.getName())
	{
		return false;
	}
	else
	{
		return true;
	}
}