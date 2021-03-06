
void onInit(CBlob @ this){
	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");
	
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || this.isAttached()) return;
	
	if (!blob.isAttached() && !blob.hasTag("player") && !blob.getShape().isStatic() && (blob.hasTag("material") || blob.hasTag("hopperable")))
	{
		if (getNet().isServer()) this.server_PutInInventory(blob);
		if (getNet().isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}