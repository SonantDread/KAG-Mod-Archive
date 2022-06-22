void onInit(CBlob@ this)
{
	this.Tag("smoke");
	this.Tag("gas");
	this.Tag("invincible");
	
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 8;
	
	if (getNet().isServer()) this.server_SetTimeToDie(60 + XORRandom(120));
}

void onTick(CBlob@ this)
{
	MakeParticle(this);
}

void MakeParticle(CBlob@ this)
{
	if(!getNet().isClient()) return;
	ParticleAnimated("LargeSmoke.png", this.getPosition()+Vec2f(XORRandom(7)-3,XORRandom(7)-3), Vec2f(), float(XORRandom(360)), 0.75f + (XORRandom(50) / 100.0f), 3, 0.0f, false);
}