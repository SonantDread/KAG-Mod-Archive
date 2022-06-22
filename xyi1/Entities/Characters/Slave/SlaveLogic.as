#include "RunnerCommon.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("remote_storage");
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("neutral");
	this.Tag("human");
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	this.set_f32("mining_multiplier", 3.0f);
	this.set_u32("build delay", 8);

	if (isServer())
	{
		CBlob@ ball = server_CreateBlobNoInit("slaveball");
		ball.setPosition(this.getPosition());
		ball.set_u16("slave_id", this.getNetworkID());
		ball.Init();
	}

	this.set_u8("mining_hardness", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 5, Vec2f(16, 16));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is this;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player=this.getPlayer();

	if (this.hasTag("invincible") || (player !is null && player.freeze))
	{
		return 0;
	}
	switch(customData)
	{
		case Hitters::nothing:
		case Hitters::suicide:
		case Hitters::fall:
			damage = 0;
			break;
	}
	return damage;
}