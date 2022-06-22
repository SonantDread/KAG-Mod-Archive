// Soul script

void onInit(CBlob@ this)
{
	this.Tag("ignore_arrow");
}

void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();
	if ((XORRandom(8) == 0) && (blob.isOnMap()))
	{
		Vec2f vel(0.0f, -12.0f);
		projectile.setVelocity(vel + 1);
	}
}