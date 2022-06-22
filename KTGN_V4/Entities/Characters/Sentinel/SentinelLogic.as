// Kagician logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("player");

	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = false;
	shape.SetGravityScale(0.0f);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}



void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	CBlob@ owner = getBlobByNetworkID(this.get_u16("owner"));
	if(owner is null || owner.hasTag("dead"))
	{
		this.server_Die();
		return;
	}
	
	Vec2f aimdir = owner.getPosition() - pos;
	aimdir /= 10.0f;
	aimdir *= aimdir.Length();
	this.AddForce(aimdir);
	
	
	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	// activate/throw
	if(ismyplayer && vel.Length() < 10)
	{
		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	CSprite@ sprite = this.getSprite();
	bool action2 = this.isKeyPressed(key_action2);
	if(this.isKeyPressed(key_action1))
	{
		Vec2f aimvel =  this.getAimPos() - pos;
		aimvel.Normalize();
		aimvel /= 2;
		this.setVelocity(this.getVelocity() + aimvel);
	}
}