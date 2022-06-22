#include "Hitters.as"

#include "FireCommon.as"

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);

	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = true;

	CShape@ shape = this.getShape();
	//shape.AddPlatformDirection(Vec2f(0, -1), 90, false);
	shape.SetRotationsAllowed(false);

	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){
	if(this.getAngleDegrees() == 0 && this.getPosition().y-8 > blob.getPosition().y)return true;
	if(this.getAngleDegrees() == 90 && this.getPosition().x+8 < blob.getPosition().x)return true;
	if(this.getAngleDegrees() == 180 && this.getPosition().y+8 < blob.getPosition().y)return true;
	if(this.getAngleDegrees() == 270 && this.getPosition().x-8 > blob.getPosition().x)return true;
	return false;
}