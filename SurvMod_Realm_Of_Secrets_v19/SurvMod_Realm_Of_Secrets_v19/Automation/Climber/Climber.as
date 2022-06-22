
void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob is null)return;
	if (!blob.hasTag("material")) return;
	//if(!this.doesCollideWithBlob(blob))return;
	
	if(blob.getPosition().x > this.getPosition().x-2 && blob.getPosition().x < this.getPosition().x+2){
		blob.setVelocity(Vec2f(0.0f, -4.0f));
	} else {
		blob.setVelocity(Vec2f(0.0f, -1.0f));
		blob.setPosition(Vec2f(this.getPosition().x,blob.getPosition().y));
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	if(isServer()){
		CMap@ map = getMap();
		if (map.getTile(this.getPosition()+Vec2f(0,-6)).type != CMap::tile_castle_back)map.server_SetTile(this.getPosition()+Vec2f(0,-6), CMap::tile_castle_back);
	}
	
	CSpriteLayer@ Case = this.getSprite().addSpriteLayer( "case","Climber.png", 8,8 );
	if(Case !is null)
	{
		Case.addAnimation("default",0,false);
		int[] frames = {4};
		Case.animation.AddFrames(frames);
		Case.SetRelativeZ(200);
		Case.SetOffset(Vec2f(0,-4));
	}
	this.getSprite().SetOffset(Vec2f(0,-4));
	this.getSprite().SetZ(-50);
}