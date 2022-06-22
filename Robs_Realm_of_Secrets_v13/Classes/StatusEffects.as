
#include "Health.as";

void onInit(CBlob@ this)
{

	this.set_s16("nature_regen",0);
	
	this.set_s16("golden_shield",0);
	
	this.set_s16("water_bubble",0);
	
	this.set_s16("poison",0);
	
	this.set_s16("invisible",0);
	
	this.set_s16("effecttimer",0);
}


void onTick(CBlob@ this)
{
	
	if(this.get_s16("golden_shield") > 0){
		this.set_s16("golden_shield",this.get_s16("golden_shield")-1);
	}
	
	if(this.get_s16("water_bubble") > 0){
		this.set_s16("water_bubble",this.get_s16("water_bubble")-1);
	}
	
	if(this.get_s16("invisible") > 0){
		this.set_s16("invisible",this.get_s16("invisible")-1);
	}
	
	
	///Timer///////////////////////////////////////////////
	if(this.get_s16("effecttimer") <= 0){
	
		if(this.get_s16("nature_regen") > 0){
			Heal(this,0.25);
			this.set_s16("nature_regen",this.get_s16("nature_regen")-1);
		}
		
		if(this.get_s16("poison") > 0){
			OverHeal(this,-0.25);
			this.set_s16("poison",this.get_s16("poison")-1);
		}

		if(getNet().isServer()){
			if(this.get_s16("nature_regen") > 0)this.Sync("nature_regen",true);
			if(this.get_s16("golden_shield") > 0)this.Sync("golden_shield",true);
			if(this.get_s16("water_bubble") > 0)this.Sync("water_bubble",true);
			if(this.get_s16("poison") > 0)this.Sync("poison",true);
			if(this.get_s16("invisible") > 0)this.Sync("invisible",true);
		}
		
		this.set_s16("effecttimer",15);
	} else this.set_s16("effecttimer",this.get_s16("effecttimer")-1);
}



void onInit(CSprite@ this)
{

	{
		this.RemoveSpriteLayer("nature_regen");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("nature_regen", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(0);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("golden_shield");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("golden_shield", "StatusEffects.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(1);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("water_bubble");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("water_bubble", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(2);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("poison");
		CSpriteLayer@ genericstatuseffect = this.addSpriteLayer("poison", "StatusEffects.png" , 32, 32, 0, this.getBlob().getSkinNum());
		if (genericstatuseffect !is null)
		{
			Animation@ anim = genericstatuseffect.addAnimation("default", 0, false);
			anim.AddFrame(3);
			genericstatuseffect.SetOffset(Vec2f(0,0));
			genericstatuseffect.SetAnimation("default");
			genericstatuseffect.SetVisible(false);
			genericstatuseffect.SetRelativeZ(2.0f);
		}
	}

}

void onTick(CSprite@ this)
{
	
	this.getSpriteLayer("nature_regen").SetVisible(false);
	if(this.getBlob().get_s16("nature_regen") > 0)this.getSpriteLayer("nature_regen").SetVisible(true);
	
	this.getSpriteLayer("golden_shield").SetVisible(false);
	if(this.getBlob().get_s16("golden_shield") > 0)this.getSpriteLayer("golden_shield").SetVisible(true);
	
	this.getSpriteLayer("water_bubble").SetVisible(false);
	if(this.getBlob().get_s16("water_bubble") > 0)this.getSpriteLayer("water_bubble").SetVisible(true);
	
	this.getSpriteLayer("poison").SetVisible(false);
	if(this.getBlob().get_s16("poison") > 0)this.getSpriteLayer("poison").SetVisible(true);
	
	
	
	if(this.getBlob().get_s16("invisible") > 1 && !this.getBlob().isKeyPressed(key_action1) && (!this.getBlob().isKeyPressed(key_action2) || this.getBlob().getName() != "builder")){
		this.SetVisible(false);
			if(this.getSpriteLayer("quiver") !is null)
			this.getSpriteLayer("quiver").SetVisible(false);
			if(this.getSpriteLayer("hook") !is null)
			this.getSpriteLayer("hook").SetVisible(false);
			if(this.getSpriteLayer("rope") !is null)
			this.getSpriteLayer("rope").SetVisible(false);
	} else if(this.getBlob().get_s16("invisible") == 1){
		this.SetVisible(true);
		if(this.getSpriteLayer("quiver") !is null)
		this.getSpriteLayer("quiver").SetVisible(true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;

	dmg *= Defense(this);
	
	return dmg;
}
