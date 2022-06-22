// Shadowman logic

#include "Hitters.as";
#include "Knocked.as";
#include "ShadowmanCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "SwapClass.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);

	this.Tag("player");
	this.Tag("evil");
	this.Tag("cant_capture");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_u16("transform_timestamp",getGameTime());
	
	this.getShape().getConsts().mapCollisions = false;
	
	this.set_u16("CooldownTwo",getGameTime()+20);
	this.Tag("DisableOne");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIconsMod.png", 10, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if(getGameTime() > this.get_u16("transform_timestamp")+20)
	if(this.isKeyJustPressed(key_action2) || this.isInWater())if (getNet().isServer()){
		CBlob @me = swapClass(this, "shadowman");
		me.setVelocity(this.getVelocity());
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getName() == "smite");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if(Hitters::suddengib != customData)return 0;
	
	if(Hitters::suddengib == customData){
		if (getNet().isServer()){
			CBlob @me = swapClass(this, "shadowman");
			me.setVelocity(this.getVelocity());
		}
		return 0;
	
	}

	return damage; //no block, damage goes through
}