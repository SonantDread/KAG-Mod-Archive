#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
	this.Tag("bunker");

	this.getShape().getConsts().mapCollisions = false;

	if (this.getTeamNum() == 0)
    	this.SetFacingLeft(false);
    else
    	this.SetFacingLeft(true);
}

void onDie(CBlob@ this)
{
    Explode(this);

	if (!isServer())
		return;
	server_CreateBlob("constructionyard",this.getTeamNum(),this.getPosition());
}

void Explode(CBlob@ this)
{
    Explode(this, 48.0f, 2.0f);

    this.getCurrentScript().runFlags |= Script::remove_after_this;
    this.server_Die();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.getTeamNum() == this.getTeamNum()) // no colliding against people inside vehicles
		return false;
	else
		return true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::flying)
	{
		this.server_Hit(hitterBlob, hitterBlob.getPosition(), this.getOldVelocity(), 6.5f, Hitters::flying, true);

		return damage / 35;
	}
	if (customData == Hitters::ballista || customData == Hitters::keg)
	{
		return damage / 3;
	}
	return damage;
}