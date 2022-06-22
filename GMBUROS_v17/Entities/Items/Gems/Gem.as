void onInit(CBlob@ this)
{
	this.SetLight(true);
	
	if(this.getName() == "gem"){
		this.SetLightColor(SColor(255,0,255,0));
		this.SetLightRadius(12);
		if(this.getSprite() !is null)this.getSprite().SetFrame(1);
	}
	
	if(this.getName() == "weak_gem"){
		this.SetLightColor(SColor(255,128,0,255));
		this.SetLightRadius(8);
	}
	
	if(this.getName() == "strong_gem"){
		this.SetLightColor(SColor(255,255,255,0));
		this.SetLightRadius(16);
		if(this.getSprite() !is null)this.getSprite().SetFrame(2);
	}
	
	if(this.getName() == "unstable_gem"){
		this.SetLightColor(SColor(255,255,0,0));
		this.SetLightRadius(20);
		if(this.getSprite() !is null)this.getSprite().SetFrame(3);
	}
	
	this.Tag("save");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid || this.isInInventory())
	{
		return;
	}

	f32 vellen = this.getShape().vellen;
	// sound
	const f32 soundbase = 2.5f;
	const f32 sounddampen = soundbase * 2.0f;

	if (vellen > soundbase)
	{
		f32 volume = Maths::Min(1.25f, Maths::Max(0.2f, (vellen - soundbase) / soundbase));

		this.getSprite().PlayRandomSound("/Rubble", volume);
	}
}