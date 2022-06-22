#include "Hitters.as";

void onTick(CBlob @this){

	if(!this.hasTag("Plagued")){
	
		this.Tag("Plagued");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("plague");
			CSpriteLayer@ plague = sprite.addSpriteLayer("plague", "PlagueBolt.png", 32, 32);

			if (plague !is null)
			{
				Animation@ anim = plague.addAnimation("default", 0, true);
				int[] frames = {0};
				anim.AddFrames(frames);
				plague.SetRelativeZ(1.0f);
				plague.SetOffset(Vec2f(0,0));
			}
		}
		
		this.set_u32("plague_timer",getGameTime()+60);
		
		this.SetLight(true);
		this.SetLightRadius(16.0f);
		this.SetLightColor(SColor(255, 0, 255, 0));
	}
	
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		CSpriteLayer@ plague = sprite.getSpriteLayer("plague");

		if (plague !is null)
		{
			plague.RotateBy(-5,Vec2f(0,0));
		}
	}

	if(this.get_u32("plague_timer") < getGameTime()){
		this.set_u32("plague_timer",getGameTime()+60);
		if(!this.hasTag("undead"))this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.25f, Hitters::suddengib, true);
		if(getNet().isServer()){
			server_CreateBlob("plague",-2,this.getPosition()+Vec2f(32,0));
			server_CreateBlob("plague",-2,this.getPosition()+Vec2f(-32,0));
		}
		
		this.Untag("Plagued");
		this.RemoveScript("Plague.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("plague");
		}
	}

	if(this.hasTag("Cleanse")){
		this.Untag("Plagued");
		this.RemoveScript("Plague.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("plague");
		}
	}
}