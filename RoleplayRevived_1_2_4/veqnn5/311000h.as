/* 311000h.as
 * author: Aphelion
 *
 * Script for handling seasonal transitioning of bushes.
 */

#include "RP_Common.as";

#include "3hh1hc4.as";

const string sprite_spring = "../Mods/" + RP_NAME + "/Entities/Natural/Bushes/Bushes-Spring.png";
const string sprite_summer = "../Mods/" + RP_NAME + "/Entities/Natural/Bushes/Bushes-Summer.png";
const string sprite_autumn = "../Mods/" + RP_NAME + "/Entities/Natural/Bushes/Bushes-Autumn.png";
const string sprite_winter = "../Mods/" + RP_NAME + "/Entities/Natural/Bushes/Bushes-Winter.png";

void onInit( CSprite@ this )
{
	Reload(this);
}

void onTick( CSprite@ this )
{
	if (ticksSinceSeasonChange(getRules()) < 300 || getGameTime() % 30 == 0)
	{
		Reload(this);
	}
}

void Reload( CSprite@ this )
{
	if (!getNet().isClient())
	{
		return;
	}
	
	string sprite_path = getSpritePath();

	if (this.getFilename() != sprite_path)
	{
		this.ReloadSprite(sprite_path);
	}
}

string getSpritePath()
{
	u8 season = getSeason(getRules());

	return season == Seasons::SPRING    ? sprite_spring :
	       season == Seasons::AUTUMN    ? sprite_autumn :
	       season == Seasons::WINTER    ? sprite_winter :
	       season == Seasons::CHRISTMAS ? sprite_winter :
	                                      sprite_summer;
}
