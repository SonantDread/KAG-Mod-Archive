void onTick(CBlob@ this)
{
	if (this is null) return;
	if (this.getPlayer() is null) return;

	if(getRules().get_bool("lightcharm_" + this.getPlayer().getUsername()) && this.getLightRadius() <= 66.0f)
	{
		this.SetLight(true);
		this.SetLightRadius(70.0f);
		this.SetLightColor(SColor(255, 255, 240, 171));
	}

	else if(!getRules().get_bool("lightcharm_" + this.getPlayer().getUsername()) && this.getLightRadius() > 66.0f)
	{
		this.SetLight(false);
		this.SetLightRadius(0.0f);
	}
}

