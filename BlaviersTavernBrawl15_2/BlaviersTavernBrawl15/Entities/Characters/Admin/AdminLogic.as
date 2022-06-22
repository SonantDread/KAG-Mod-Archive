#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	print("> Someone is using admin class");

	this.set_f32("gib health", -1.0f);
	
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("player");
	this.Tag("invincible");
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	// Gender
	this.getSprite().SetAnimation(this.getSexNum() == 0 ? "male" : "female");

	if (!isClient())
		{ return; }
	ParticleZombieLightning(this.getPosition());
}

void onDie(CBlob@ this)
{
	print("> Someone has left admin class");

	if (!isClient())
		{ return; }
	ParticleZombieLightning(this.getPosition());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// No damage
	return 0;
}
