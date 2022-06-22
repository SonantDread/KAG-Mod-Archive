#include "RunnerCommon.as"
#include "Hitters.as"
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
	if(!this.get("moveVars", @moveVars)) return;
	int stimer = this.get_u32("srune_timer");
	int itimer = this.get_u32("irune_timer");
	if(itimer > 1)
	{
		if(this.getSprite().isVisible())
			this.getSprite().SetVisible(false);
		this.set_u32("irune_timer", itimer-1);
	}
	if(itimer == 1)
	{
		this.getSprite().PlaySound("MagicWand.ogg");
		this.getSprite().SetVisible(true);
		this.set_u32("irune_timer", itimer-1);
	}
	if(stimer > 1)
	{
		moveVars.walkFactor *= 1.4f;
		moveVars.jumpFactor *= 1.5f;
		this.set_u32("srune_timer", stimer-1);
	}
	if(stimer == 1)
	{
		this.getSprite().PlaySound("GregRoar.ogg");
		this.set_u32("srune_timer", stimer-1);
	}
}
/*
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

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(this.getName() == "knight")
	{
		if(this.get_string("weapon") == "bladeofundead")
		{
			this.set_u8("zombiespawn",this.get_u8("zombiespawn") + 1.0f);
			if(this.get_u8("zombiespawn") > 5.0f )
			{
				CBlob@ skel2 = server_CreateBlob("skeleton");
				if(skel2 !is null)
				{
					skel2.server_setTeamNum(this.getTeamNum());
					skel2.setPosition(this.getPosition() + Vec2f(0.0f, -4.0f));
					skel2.server_SetTimeToDie(40);
				}
				this.set_u8("zombiespawn",0.0f);
			}
		}
		else if(this.get_string("weapon") == "bladeoflight")
		{
			this.server_Heal(0.25f);
		}
		else if(this.get_string("weapon") == "greed" && (hitBlob.hasTag("player")))
		{
			CPlayer@ player = this.getPlayer();
			if(player !is null)
			{
				player.server_setCoins(player.getCoins() + 5);
			}
		}
		else if(this.get_string("weapon") == "hammer")
		{
			SetKnocked(hitBlob, 60);
		}
	}
	
	return;
}*/