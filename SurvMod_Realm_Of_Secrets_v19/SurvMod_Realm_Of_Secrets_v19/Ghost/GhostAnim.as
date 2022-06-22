
void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	Vec2f pos = blob.getPosition();

	//this.SetAnimation("clean");
	
	if (!left && right && !up && !down)this.SetFrameIndex(0);
	if (left && !right && !up && !down)this.SetFrameIndex(1);
	//if (!left && !right && up && !down)this.SetFrameIndex(2);
	//if (!left && !right && !up && down)this.SetFrameIndex(3);
	
	if(!blob.hasTag("visible"))this.SetVisible(false);
	else {
		this.SetVisible(true);
		this.setRenderStyle(RenderStyle::normal);
	}
	
	if(getLocalPlayerBlob() !is null){
		if(getLocalPlayerBlob().hasTag("spirit_view")){
			if(this.isVisible() == false){
				this.SetVisible(true);
				this.setRenderStyle(RenderStyle::additive);
			}
		}
	}
}