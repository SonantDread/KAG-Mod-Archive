#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetOffset(Vec2f(0, 7));
	this.getShape().SetCenterOfMassOffset(Vec2f(0.0f, 0));
	this.getShape().getConsts().transports = true;
	// override icon
	AddIconToken("$" + this.getName() + "$", "VehicleIcons.png", Vec2f(16, 16), 6);
	this.Tag("heavy weight");
	this.Tag("can grapple");
	this.getShape().SetGravityScale(0.0f);
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.AddPlatformDirection(Vec2f(0, -1), 89, false);
	shape.AddPlatformDirection(Vec2f(0, 1), 90, false);

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if (customData == Hitters::builder)
	{
		damage = this.getInitialHealth() * 0.34 * 2;
	}
	else if (isExplosionHitter(customData))
	{
		damage *= 2;
	}
	else if (customData == Hitters::sword)
	{
		damage *= 1;
	}
	
	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	
	Vec2f vel = blob.getVelocity();
	f32 heightDifference = (blob.getPosition() - this.getPosition()).y;
	// && -heightDifference < (this.getHeight() + blob.getHeight()) / 0.01
	bool fromUp = blob.getVelocity().y >= -0.5;
	return (((blob.getPlayer() !is null || blob.hasTag("vehicle")) && fromUp) || 
		   (blob.hasTag("projectile") && blob.getTeamNum() != this.getTeamNum()));
}

bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}