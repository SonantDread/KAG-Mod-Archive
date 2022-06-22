#include "Hitters.as"

#include "FireCommon.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	
	CSprite@ ThisSprite = this.getSprite();
	ThisSprite.SetZ(-100.0f);
	ThisSprite.SetRelativeZ(-20.5f);

	this.getShape().SetStatic(true);
	this.getShape().getConsts().collideWhenAttached = true;
	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.Tag("explosion always teamkill"); // ignore 'no teamkill' for explosives

	//this.set_TileType("background tile", CMap::tile_castle_back);

	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_stone', 4);
		this.set('harvest', harvest);
	}

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

//TODO: fix flags sync and hitting
/*void onDie( CBlob@ this )
{
	SetSolidFlag(this, false);
}*/

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
