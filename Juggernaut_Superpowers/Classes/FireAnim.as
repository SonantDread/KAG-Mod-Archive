// Draw a flame sprite layer

#include "FireParticle.as";
#include "FireCommon.as";
#include "PowersCommon.as"; // new

void onInit(CSprite@ this)
{
	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);

	if (fire !is null)
	{
		{
			Animation@ anim = fire.addAnimation("bigfire", 3, true);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
		}
		{
			Animation@ anim = fire.addAnimation("smallfire", 3, true);
			anim.AddFrame(4);
			anim.AddFrame(5);
			anim.AddFrame(6);
		}
		fire.SetVisible(false);
		fire.SetRelativeZ(10);
	}
	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CSprite@ this)
{
	this.getCurrentScript().tickFrequency = 24; // opt
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ fire = this.getSpriteLayer("fire_animation_large");
	if (fire !is null)
	{
		//if we're burning
		if (blob.hasTag(burning_tag))
		{
			this.getCurrentScript().tickFrequency = 12;

			fire.SetVisible(true);

			//TODO: draw the fire layer with varying sizes based on var - may need sync spam :/
			if(blob.getConfig()=="juggernaut"){
				fire.SetAnimation("bigfire");
			}else{
				fire.SetAnimation("smallfire");
				if (!hasPower(blob, Powers::FIRE_LORD) && this.getAnimation("on_fire") !is null) // new, is not firelord check
				{
					this.SetAnimation("on_fire");
				}
			}

			//set the "on fire" animation if it exists (eg wave arms around)
			
		}
		else
		{
			if (fire.isVisible())
			{
				this.PlaySound("/ExtinguishFire.ogg");
			}
			fire.SetVisible(false);
		}
	}
}
