// Minikeg Crate by Koi_

void onInit(CBlob@ this)
{
	this.Tag("medium weight");

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-10);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.SetDamageOwnerPlayer(attached.getPlayer());
}

void Unpack(CBlob@ this)
{
	/*Vec2f velocity = this.getOldVelocity();

	if(this.isAttached())
	{
		velocity = this.getAttachmentPoint(0).getOccupied().getOldVelocity();
	}*/

	for(int i = 0; i < 8; i++)
	{
		Vec2f offset = Vec2f(0.5f, 0.5f) - Vec2f(XORRandom(100), XORRandom(100)) / 100.0f;

		CBlob@ keg = server_CreateBlob("minikeg", this.getTeamNum(), this.getPosition() + offset);
		//keg.setVelocity(velocity + offset * 4.0f);
		keg.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());

		// ignite!
		keg.SendCommand(keg.getCommandID("activate"));
		keg.set_s32("explosion_timer", getGameTime() + XORRandom(45));
	}
}

void onDie(CBlob@ this)
{
	if(getNet().isServer())
	{
		Unpack(this);
	}

	// crate gibs
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	string fname = CFileMatcher("/MKCrateGibs.png").getFirst();
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}