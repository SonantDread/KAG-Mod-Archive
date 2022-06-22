#include "Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "MakeDustParticle.as";
#include "ParticleSparks.as";

const f32 ARROW_PUSH_FORCE = 22.0f;
void onInit(CBlob@ this)
{
	this.Tag("exploding");
	this.set_f32("explosive_radius", 92.0f);
	this.set_f32("explosive_damage", 8.0f);
	this.set_f32("map_damage_radius", 92.0f);
	this.set_f32("map_damage_ratio", -1.0f); //heck no!
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		//this.server_SetTimeToDie(3);
		this.set_string("custom_explosion_sound", "OrbExplosion.ogg");
		//this.getSprite().PlaySound("OrbFireSound.ogg");
		this.Tag("projectile");

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
}

bool explodeOnCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ((blob !is null) || blob.getShape().isStatic() && blob.isCollidable());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{

if(blob.hasTag("projectile") || blob.hasTag("tree") || this.getTeamNum() == blob.getTeamNum())
{
return false;
}

bool check = this.getTeamNum() != blob.getTeamNum();
if(!check)
{
CShape@ shape = blob.getShape();
check = (shape.isStatic() && !shape.getConsts().platform);
}

if (check)
{
return true;
}

return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided") && !blob.hasTag("dead") || blob is null)
	{
			this.Tag("exploding");
			this.Sync("exploding", true);

			this.server_SetHealth(-1.0f);
			this.server_Die();
	}
}

void Pierce(CBlob @this)
{
	CMap@ map = this.getMap();
	Vec2f end;
	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	{
		HitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
}

void HitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	this.getSprite().PlaySound(XORRandom(4) == 0 ? "BulletRicochet.ogg" : "BulletImpact.ogg");
	MakeDustParticle(worldPoint, "/DustSmall.png");
	CMap@ map = this.getMap();
	f32 vellen = velocity.Length();
	TileType tile = map.getTile(worldPoint).type;
	if (map.isTileCastle(tile) || map.isTileStone(tile))
	{
		sparks (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage));
	}
	this.server_Die();
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity
		f32 force = (ARROW_PUSH_FORCE * -0.125f) * Maths::Sqrt(hitBlob.getMass()+1);
		hitBlob.AddForce(velocity * force);
	}
}