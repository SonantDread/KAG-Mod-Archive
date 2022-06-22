void onTick(CBlob@ this)
{
	if (this is null) return;
	if (this.getPlayer() is null) return;

	if(getRules().get_bool("quickbuildcharm_" + this.getPlayer().getUsername()) && this.get_u32("build delay") > 5)
	{
		this.set_u32("build delay", 5);
	}

	else if(!getRules().get_bool("quickbuildcharm_" + this.getPlayer().getUsername()) && this.get_u32("build delay") < 6)
	{
		this.set_u32("build delay", 7);
	}
}