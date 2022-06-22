

void onTick(CBlob @this){

	if(!this.hasTag("AirBubble")){
	
		this.Tag("AirBubble");
	
		CSprite@ sprite = this.getSprite();
	
		if(sprite !is null){
			sprite.RemoveSpriteLayer("airbubble");
			CSpriteLayer@ airbubble = sprite.addSpriteLayer("airbubble", "AirBubble.png", 32, 32);

			if (airbubble !is null)
			{
				Animation@ anim = airbubble.addAnimation("default", 4, false);
				int[] frames = {0, 1, 2, 3};
				anim.AddFrames(frames);
				airbubble.SetRelativeZ(-1.0f);
				airbubble.SetOffset(Vec2f(0,0));
				airbubble.setRenderStyle(RenderStyle::additive);
			}
			
			sprite.RemoveSpriteLayer("airbubbleoutter");
			CSpriteLayer@ airbubbleoutter = sprite.addSpriteLayer("airbubbleoutter", "AirBubbleOutter.png", 32, 32);

			if (airbubbleoutter !is null)
			{
				Animation@ anim = airbubbleoutter.addAnimation("default", 4, false);
				int[] frames = {0, 1, 2, 3};
				anim.AddFrames(frames);
				airbubbleoutter.SetRelativeZ(1.0f);
				airbubbleoutter.SetOffset(Vec2f(0,0));
				//airbubbleoutter.setRenderStyle(RenderStyle::additive);
			}
		}
		
		this.set_u32("air_buff",getGameTime()+(30*30));
	}

	if(this.get_u32("air_buff") < getGameTime()){
		this.Untag("AirBubble");
		this.RemoveScript("AirBubble.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("airbubble");
			sprite.RemoveSpriteLayer("airbubbleoutter");
		}
	}

}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if(sprite !is null){
		sprite.RemoveSpriteLayer("airbubble");
		sprite.RemoveSpriteLayer("airbubbleoutter");
	}
}