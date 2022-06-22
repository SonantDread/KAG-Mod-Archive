#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.set_bool("open", false);
	this.Tag("place norotate");
	this.Tag("builder always hit");
	
	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");
	
	this.Tag("explosion always teamkill"); // ignore 'no teamkill' for explosives

	this.set_TileType("background tile", CMap::tile_castle_back);
	
	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_wood', 3);
		this.set('harvest', harvest);
	}
	
	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	MakeDamageFrame(this);
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}