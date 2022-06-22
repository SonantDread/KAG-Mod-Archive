

void onTick(CBlob @this){

	//this.getCurrentScript().tickFrequency = 1;
	
	if(!this.hasTag("StoneShield")){
	
		this.Tag("StoneShield");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("stone_shield");
			CSpriteLayer@ stone_shield = sprite.addSpriteLayer("stone_shield", "StoneShield.png", 32, 32);

			if (stone_shield !is null)
			{
				Animation@ anim = stone_shield.addAnimation("default", 0, false);
				int[] frames = {0};
				anim.AddFrames(frames);
				stone_shield.SetRelativeZ(1.0f);
				stone_shield.SetOffset(Vec2f(0,0));
			}
		}
		
		this.set_u32("stone_buff",getGameTime()+(30*30));
	}

	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		CSpriteLayer@ stone_shield = sprite.getSpriteLayer("stone_shield");

		if (stone_shield !is null)
		{
			stone_shield.RotateBy(-10,Vec2f(0,0));
		}
	}
	
	if(this.get_u32("stone_buff") < getGameTime()){
		this.Untag("StoneShield");
		this.RemoveScript("StoneShield.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("stone_shield");
		}
	}

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("stone_shield");
	}
}