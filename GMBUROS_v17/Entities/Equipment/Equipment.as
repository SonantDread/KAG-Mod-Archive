
void onInit(CBlob @ this)
{
	this.Tag("save");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((blob.getControls() is null || !blob.hasTag("player")) && (blob.getBrain() is null));
}