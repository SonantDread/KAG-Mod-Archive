void onTick(CBrain@ this)
{
	this.getCurrentScript().tickFrequency = 1;
	CBlob @blob = this.getBlob();
	
	if (blob.isInWater())
	{	
		blob.setKeyPressed(key_up, true);
	}
}