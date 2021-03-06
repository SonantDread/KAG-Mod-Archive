#include "Hitters.as"
#include "MakeMat.as"
#include "FireCommon.as"
void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    //this.set_TileType("background tile", CMap::tile_castle_back);
    this.server_setTeamNum(-1); //allow anyone to break them
	this.Tag("place norotate");

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);
	
	this.Tag("wood");
	this.Tag("large");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		break;
	case Hitters::saw:
		dmg *= 1.5f;
		break;		
	case Hitters::bomb:
	case Hitters::keg:
	case Hitters::arrow:
	case Hitters::cata_stones:
	default:
		dmg=dmg;
		break;
	}		
	return dmg;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}