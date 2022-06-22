﻿#include "MapFlags.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
	shape.getConsts().mapCollisions = false;
	shape.SetStatic(true);
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().RotateBy(XORRandom(4) * 90, Vec2f(0, 0));
	this.getSprite().SetZ(-50); //background

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.server_setTeamNum(-1);
	
	this.Tag("builder always hit");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob.hasTag("flesh"))
	{
		this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob !is null && hitterBlob !is this)
	{
		this.server_Hit(hitterBlob, hitterBlob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, false);
	}
	
	return damage;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}