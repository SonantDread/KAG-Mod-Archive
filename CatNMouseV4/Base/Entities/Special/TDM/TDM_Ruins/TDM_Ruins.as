// TDM Ruins logic

#include "StandardRespawnCommand.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}