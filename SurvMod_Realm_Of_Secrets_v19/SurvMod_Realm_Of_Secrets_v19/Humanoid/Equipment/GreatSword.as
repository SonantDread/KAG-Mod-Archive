
#include "EquipmentCommon.as";
#include "CommonParticles.as";

void onTick(CBlob@ this)
{
	if(this.get_u16("sarm_equip") == Equipment::GreatSwordAlt){
		if(this.isOnGround()){
			this.set_u16("ground_height",this.getPosition().y);
			this.Untag("shadow_aura");
		}
		if(this.isKeyPressed(key_action2))if(this.get_u16("sarm_equip_type") == 2)if(this.get_s16("darkness") > 0){ //Shadow blade alt
			//if(this.get_u16("ground_height") < this.getPosition().y+64)
			this.setVelocity(this.getVelocity()*0.90f+Vec2f(0,-0.5f));
			//else this.setVelocity(this.getVelocity()*0.80f);
			this.Tag("shadow_aura");
			cpr(this.getPosition()+(Vec2f(XORRandom(64),0).RotateBy(XORRandom(360))),Vec2f(XORRandom(7)-3,-XORRandom(7)-2)*0.3f);
			cpr(this.getPosition()+(Vec2f(XORRandom(8)+8,0).RotateBy(XORRandom(360))),Vec2f(XORRandom(2)-1,-XORRandom(7)-2)*0.4f);
			
			if(getGameTime() % 20 == 0 || this.isKeyJustPressed(key_action2))this.sub_s16("darkness",1);
		}
		this.getCurrentScript().tickFrequency = 1;
	} else this.getCurrentScript().tickFrequency = 61;
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("aura");
	CSpriteLayer@ aura = this.addSpriteLayer("aura", "DarkAura.png" , 128, 128, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (aura !is null)
	{
		Animation@ anim = aura.addAnimation("default", 0, false);
		anim.AddFrame(0);
		aura.SetVisible(false);
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ aura = this.getSpriteLayer("aura");

	if (aura !is null)
	{
		if(this.getBlob().hasTag("shadow_aura")){
			aura.setRenderStyle(RenderStyle::light);
			aura.SetRelativeZ(-100.0f);
			aura.SetVisible(true);
			aura.RotateBy(10,Vec2f(0,0));
		} else {
			aura.SetVisible(false);
		}
	}
}