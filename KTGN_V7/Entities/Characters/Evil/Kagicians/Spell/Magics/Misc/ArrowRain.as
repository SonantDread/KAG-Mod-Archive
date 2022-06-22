//Lob the player upwards.
#include "MagicalHitters.as";
void onDie(CBlob@ this) //Rain arrows from sky on death.
{
	Vec2f pos = Vec2f(this.getPosition().x, 0);
	for(int i = 0; i < this.get_u16("charge") / 40; i++)
	{
		Vec2f newpos = pos;
		pos.x += XORRandom(60) - 31;
		pos.y = XORRandom(50);
		CBlob@ arrow = server_CreateBlob("arrow", this.getTeamNum(), pos);
		arrow.setVelocity(Vec2f(0, -1));
	}
}