// GenericPistonHead.as

void onInit(CSprite@ this)
{
	this.SetZ(-100);
}

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}