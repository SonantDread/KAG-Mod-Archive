
#include "Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "MakeDustParticle.as";
#include "ParticleSparks.as";

const f32 ARROW_PUSH_FORCE = 12.0f;

//blob functions
void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	consts.net_threshold_multiplier = 4.0f;
	this.server_SetTimeToDie( 0.5f );	
	this.Tag("projectile");
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && doesCollideWithBlob( this, blob ) && !this.hasTag("collided"))
    {
		if (!solid && !blob.hasTag("flesh") && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
		{
			return;
		}


		f32 dmg = blob.getTeamNum() == this.getTeamNum() ? 0.0f : 1.0f;		
		this.server_Hit( blob, point1, normal, dmg, Hitters::arrow);
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
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

	string bname = blob.getName();
	if(bname == "fishy" || bname == "food")//anything to always hit
	{
		return true;
	}

	return false;
}


void onTick( CBlob@ this )
{
    f32 angle = (this.getVelocity()).Angle();
    Pierce( this ); //map
    this.setAngleDegrees(-angle);

	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.3f + this.getTickSinceCreated()*0.1f );
}

void Pierce( CBlob @this )
{
    CMap@ map = this.getMap();
	Vec2f end;
	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	{
		HitMap( this, end, this.getOldVelocity(), 0.5f, Hitters::arrow );
	}
}


f32 HitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
    if (hitBlob !is null)
    {
		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));

		// play sound
		if (!hitShield)
		{
			if (hitBlob.hasTag("flesh"))
			{
				this.getSprite().PlaySound( "ArrowHitFlesh.ogg" );
			}
			else
			{
				this.getSprite().PlaySound( "BulletImpact.ogg" );	
			}
		}

        this.server_Die();
    }

	return damage;
}

void HitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	this.getSprite().PlaySound( XORRandom(4) == 0 ? "BulletRicochet.ogg" : "BulletImpact.ogg" );
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

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(customData == Hitters::sword)
	{
		return 0.0f; //no cut arrows
	}	
    return damage;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity
		f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass()+1);
		hitBlob.AddForce( velocity * force );
	}
}
