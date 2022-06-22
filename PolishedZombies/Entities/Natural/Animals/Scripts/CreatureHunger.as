#include "Hitters.as";

void onInit(CBlob@ this)
{
	if (!this.exists("hunger level"))
		this.set_f32("hunger level", 100.0f);

	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	f32 hunger = this.get_f32("hunger level");

	if(hunger > 0)
		hunger--;

	if (hunger <= 15)
	{
		this.Tag("starving");
	}

	if (hunger == 0)
	{
		this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::bite, true);
	}
	this.set_f32("hunger level", hunger);
}