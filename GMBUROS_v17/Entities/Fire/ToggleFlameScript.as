
void onInit(CBlob@ this)
{
	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.Tag("dont deactivate");
	this.Tag("activatable");
	this.addCommandID("activate");

	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater()){
		Light(this, false);
	}
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.Untag("lit");
	}
	else
	{
		this.SetLight(true);
		this.Tag("lit");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate")){
		Light(this, !this.isLight());
	}
}