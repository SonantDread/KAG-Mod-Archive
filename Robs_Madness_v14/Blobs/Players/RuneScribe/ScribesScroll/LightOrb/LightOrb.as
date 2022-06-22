// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.getShape().SetStatic(true);
}

void onInit(CSprite@ this)
{
	this.setRenderStyle(RenderStyle::additive);
}