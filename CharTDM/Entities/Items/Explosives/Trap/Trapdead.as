void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.server_SetTimeToDie(3);
}
