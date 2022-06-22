

void onTick(CBlob @this){

	if(!this.hasTag("Invisible")){
	
		this.Tag("Invisible");
	
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			if(getLocalPlayerBlob() !is this)this.SetVisible(false);
			sprite.setRenderStyle(RenderStyle::additive);
		}
		this.set_u32("invis_timer",getGameTime()+(30*30));
	}

	if(this.get_u32("invis_timer") < getGameTime()){
		this.Untag("Invisible");
		this.RemoveScript("Invisibility.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			this.SetVisible(true);
			sprite.setRenderStyle(RenderStyle::normal);
		}
	}

}