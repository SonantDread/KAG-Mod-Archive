#include "Hitters.as";
#include "FighterVarsCommon.as"

void onInit(CBlob@ this)
{
	//this.Tag("exploding");
	this.set_f32("explosive_radius", 24.0f);
	this.set_f32("explosive_damage", 8.0f);
	this.set_f32("map_damage_radius", 15.0f);
	this.set_f32("map_damage_ratio", -1.0f); //heck no!
	
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;

	this.getSprite().setRenderStyle(RenderStyle::light);
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(0.0f);
		this.server_SetTimeToDie(3);
		this.SetLight(true);
		this.SetLightRadius(24.0f);
		this.SetLightColor(SColor(255, 211, 121, 224));
		this.set_string("custom_explosion_sound", "OrbExplosion.ogg");
		this.getSprite().SetZ(1000.0f);

		//makes a stupid annoying sound
		//ParticleZombieLightning( this.getPosition() );

		// done post init
		//this.getCurrentScript().tickFrequency = 10;
	}

	Vec2f thisVel = this.getVelocity();
	Vec2f velNorm = thisVel;
	velNorm.Normalize();

	f32 angle = thisVel.Angle();
	this.setAngleDegrees(-angle);

	// spark trail effect
	if ( getNet().isClient() )
	{
		//bulletTrail(this.getPosition(), 1);

		trailSparks(this.getPosition() - velNorm*16.0f, 2, 4.0f, 1.0f);
	}
}

bool isEnemy( CBlob@ this, CBlob@ target )
{
	CBlob@ friend = getBlobByNetworkID(target.get_netid("brain_friend_id"));
	return 
	(
		( target.getTeamNum() != this.getTeamNum() && (target.hasTag("door") || target.getName() == "trap_block") )
		||
		(
			target.hasTag("flesh") 
			&& !target.hasTag("dead") 
			&& target.getTeamNum() != this.getTeamNum() 
			&& ( friend is null || friend.getTeamNum() != this.getTeamNum() )
		)
	);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return ( isEnemy(this, blob) || blob.getName() == "barrel" || blob.getName() == "gravity_bomb" || blob.getName() == "boulder" );
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (solid)
	{
		this.server_Die();
		
		if(blob !is null && isEnemy(this, blob) )
		{
			this.server_Die();
		} 
	}
}

void onDie(CBlob@ this)
{
	Explode( this );
}

void Explode( CBlob@ this )
{
    CMap@ map = getMap();
	Vec2f thisPos = this.getPosition();
    if (map !is null)   
	{
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(thisPos, 20.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b !is null && b.getTeamNum() != this.getTeamNum())
				{
					Vec2f bPos = b.getPosition();
					
					if ( !map.rayCastSolid(thisPos, bPos) )
					{
						FighterHitData fighterHitData(2, 3.0f, 0.04f);
						server_fighterHit(this, b, bPos, bPos-thisPos, 10, Hitters::bomb, false, fighterHitData);
						//this.server_Hit(b, bPos, bPos-thisPos, 0.75f, Hitters::water, false);
					}
				}
			}
		}
	}
	
	this.getSprite().PlaySound("acidburn1.ogg", 1.5f, 1.0f + XORRandom(3)/10.0f);
	explosionFX(thisPos, 8);
	explodeSparks(thisPos, 20, 16.0f, 6.0f);
}

Random _sprk_r;
void trailSparks(Vec2f pos, int amount, f32 radius, f32 speed)
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * speed, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        Vec2f randomPosVec = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * radius;

        CParticle@ p = ParticlePixel( pos + randomPosVec, vel, SColor( 255, 50+_sprk_r.NextRanged(128), 255, 50+_sprk_r.NextRanged(128)), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 20 + _sprk_r.NextRanged(20);
        p.scale = 0.5f + _sprk_r.NextFloat();
        p.damping = 0.95f;
        p.gravity = Vec2f(0,0);
    }
}

void explodeSparks(Vec2f pos, int amount, f32 radius, f32 speed)
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * speed, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        Vec2f randomPosVec = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * radius;

        CParticle@ p = ParticlePixel( pos + randomPosVec, vel, SColor( 255, 50+_sprk_r.NextRanged(128), 255, 50+_sprk_r.NextRanged(128)), true );
        if(p is null) return; //bail if we stop getting particles

        p.timeout = 40 + _sprk_r.NextRanged(40);
        p.scale = 0.5f + _sprk_r.NextFloat();
        p.damping = 0.95f;
        p.gravity = Vec2f(0,0.05f);
    }
}

void bulletTrail(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 1.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

		const f32 rad = 2.0f;
		Vec2f randomPosVec = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
		CParticle@ explodeP = ParticleAnimated( "tinypuff2.png", pos + randomPosVec, vel, float(XORRandom(360)), 1.0f, 4 + XORRandom(3), 0.0f, false );
		if ( explodeP !is null)
		{
			explodeP.setRenderStyle(RenderStyle::light);

	        explodeP.damping = 0.9f;
	        explodeP.gravity = Vec2f(0,0);
		}
    }
}

void explosionFX(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 2.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

		const f32 rad = 8.0f;
		Vec2f randomPosVec = Vec2f( XORRandom(128)-64, XORRandom(128)-64 ) * 0.015625f * rad;
		CParticle@ explodeP = ParticleAnimated( "genericexplosion2.png", pos + randomPosVec, vel, float(XORRandom(360)), 1.0f, 4 + XORRandom(3), 0.0f, false );
		if ( explodeP !is null)
		{
			explodeP.setRenderStyle(RenderStyle::light);

	        explodeP.damping = 0.9f;
	        explodeP.gravity = Vec2f(0,0.05f);
		}
    }
}
