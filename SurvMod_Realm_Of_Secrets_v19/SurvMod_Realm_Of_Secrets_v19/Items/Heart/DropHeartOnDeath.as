
//random heart on death (default is 100% of the time for consistency + to reward murder)

#include "LimbsCommon.as";

#define SERVER_ONLY

void dropHeart(CBlob@ this)
{
	if (this.get_u8("heart") != HeartType::Missing) //double check
	{
		this.set_u8("heart",HeartType::Missing);

		CBlob@ heart = server_CreateBlob("heart", -1, this.getPosition());

		if (heart !is null)
		{
			Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
			heart.setVelocity(vel);
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("switch class") || this.get_u8("heart") == HeartType::Missing) { return; }    //don't make a heart on change class, or if this has already run before or if had bread

	dropHeart(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
