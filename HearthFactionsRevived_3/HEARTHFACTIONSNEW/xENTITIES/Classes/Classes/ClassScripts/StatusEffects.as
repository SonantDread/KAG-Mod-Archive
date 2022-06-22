#include "RunnerCommon.as"
#include "Hitters.as"
#include "Knocked.as"
#include "FireCommon.as"
void onInit(CBlob@ this)
{
	this.set_f32("dmgmult", 1.0f);
	this.set_f32("speedmult", 1.0f);
	this.set_f32("defence_multiplier", 1.0f);
	this.set_f32("rangemult", 1.0f);
}
void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	/*if(this.get("moveVars", @moveVars))
	{
		moveVars.jumpFactor = 1.0f;
	}*/
	if(this.get_u32("charge") > 0){
		
		if(this.get("moveVars", @moveVars))
		{
			//print("bah");
			moveVars.walkFactor *= 2.0f;
			moveVars.jumpFactor *= 2.0f;
		}
		this.set_u32("charge",this.get_u32("charge")-1);
	}
	/*
	CPlayer@ player = this.getPlayer();
	
	if(player !is null)
	{
		print("lvl: " + player.get_u8("nathanlvl"));
		if (player.get_u8("nathanlvl") == 0 && player.get_f32("nathanexp") > 6.0f)
		{
			client_AddToChat("Leveled up to Level 2! New Ability: CHARGE", SColor(255, 125, 0, 0));
			player.set_u8("nathanlvl", 1);
			this.set_u8("nathanlvl", 1);
			player.set_f32("nathanexp", 0.0f);
		}
		else if (player.get_u8("nathanlvl") == 1 && player.get_f32("nathanexp") > 200.0f)
		{
			client_AddToChat("Leveled up to Level 3! New Ability: Back up", SColor(255, 125, 0, 0));
			player.set_u8("nathanlvl", 2);
			this.set_u8("nathanlvl", 2);
			player.set_f32("nathanexp", -1.0f);
		}
	}*/
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	
	if(dmg <= 0)return dmg;
	f32 def = 1;
	if(this.exists("defence_multiplier"))
	{
		def = this.get_f32("defence_multiplier");
	}
	
	dmg *= def;
	
	return dmg; 
}