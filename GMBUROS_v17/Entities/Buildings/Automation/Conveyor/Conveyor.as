// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(150);
	this.getShape().SetRotationsAllowed(false);
	
	this.Tag("place norotate");
	this.Tag("blocks sword");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("builder always hit");
	
	this.Tag("ignore blocking actors");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	this.setPosition(this.getPosition()+Vec2f(0,4));

	sprite.SetOffset(Vec2f(0,-3));
	
	this.getSprite().PlaySound("/build_door.ogg");
	
	if(isServer()){
		CMap@ map = getMap();
		if (map.getTile(this.getPosition()+Vec2f(0,-6)).type != CMap::tile_castle_back)map.server_SetTile(this.getPosition()+Vec2f(0,-6), CMap::tile_wood_back);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob is null) return false;
	if (blob.getPosition().y > this.getPosition().y) return false;
	if (!blob.hasTag("material")) return false;
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	if (!blob.hasTag("material")) return;
	if(!this.doesCollideWithBlob(blob))return;
	
	blob.set_u32("autopick time",getGameTime()+10);
	
	if(this.getName() != "climber")
	{
		if (Maths::Abs(blob.getVelocity().y) < 2.0f) blob.setVelocity(Vec2f(this.isFacingLeft() ? -0.5f : 0.5f, -1.0f));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder) damage *= 4.0f;
	return damage;
}