// Blame Fuzzle.
#include "Knocked.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "LimitedAttacks.as";
#include "Explosion.as";

const f32 MEDIUM_SPEED = 9.0f;
const f32 FAST_SPEED = 16.0f;

const f32 max_range = 256.00f;
const float field_force = 1.0;
const float mass = 1.0;

const float first_radius = 64.0;
const float second_radius = 220.0;
// Speed required to pierce Wooden tiles.

void onInit(CBlob@ this)
{

	this.set_u8("blocks_pierced", 0);
	this.set_bool("static", false);

	this.server_SetTimeToDie(7);

	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 1.0f;

	LimitedAttack_setup(this);

	u32[] offsets;
	this.set("offsets", offsets);
	// Offsets of the tiles that have been hit.

	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.Tag("tether");
	//this.getCurrentScript().tickFrequency = 1;

}

void onTick(CBlob@ this)
{

	f32 angle = 0;

	if (!this.get_bool("static"))
	{

		Vec2f velocity = this.getVelocity();
		angle = velocity.Angle();

		Pierce(this, velocity, angle);


	}
	else
	{

		angle = Maths::get360DegreesFrom256(this.get_u8("angle"));

		this.setVelocity(Vec2f_zero);
		this.setPosition(Vec2f(this.get_f32("lock_x"), this.get_f32("lock_y")));
		this.getShape().SetStatic(true);
		this.doTickScripts = true;

	}

	this.setAngleDegrees(-angle + 180.0f);
	
	CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs) && this.hasTag("tether"))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			
			if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
			{
				f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				f32 factor = 1.00f - Maths::Pow(dist / max_range, 2);
			
				 //SetKnocked(blob, 75 * factor);
			
				if (this.hasTag("tether")) 
	{
	
	

        CBlob@[] blobs;
        getMap().getBlobsInRadius(this.getPosition(), first_radius, blobs);
        for (int i=0; i < blobs.length; i++) 
		{
            CBlob@ blob = blobs[i];
            if ( blob.getTeamNum() == this.getTeamNum() ) continue;

            Vec2f delta = this.getPosition() - blob.getPosition();

            Vec2f force = delta;
            force.Normalize();
            force *= field_force * mass * blob.getMass() * (delta.Length() / second_radius);

            blob.AddForce(force);
			this.doTickScripts = true;
        }
        }
    }
			}
		}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{

	CBlob@ carrier = blob.getCarriedBlob();

	if (carrier !is null)
		if (carrier.hasTag("player")
		        && (this.getTeamNum() == carrier.getTeamNum() || blob.hasTag("temp blob")))
			return false;

	return (this.getTeamNum() != blob.getTeamNum() || blob.getShape().isStatic())
	       && blob.isCollidable();

}

void Pierce(CBlob@ this, Vec2f velocity, const f32 angle)
{

	CMap@ map = this.getMap();

	const f32 speed = velocity.getLength();
	const f32 damage = speed > MEDIUM_SPEED ? 4.0f : 3.5f;

	Vec2f direction = velocity;
	direction.Normalize();

	Vec2f position = this.getPosition();
	Vec2f tip_position = position + direction * 12.0f;
	Vec2f middle_position = position + direction * 6.0f;
	Vec2f tail_position = position - direction * 12.0f;

	Vec2f[] positions =
	{

		position,
		tip_position,
		middle_position,
		tail_position

	};

	for (uint i = 0; i < positions.length; i ++)
	{

		Vec2f temp_position = positions[i];
		TileType type = map.getTile(temp_position).type;

		if (map.isTileSolid(type))
		{

			u32[]@ offsets;
			this.get("offsets", @offsets);
			const u32 offset = map.getTileOffset(temp_position);

			if (offsets.find(offset) != -1)
				continue;

			BallistaHitMap(this, offset, temp_position, velocity, damage, Hitters::ballista);
			this.server_HitMap(temp_position, velocity, damage, Hitters::ballista);

		}
	}

	HitInfo@[] infos;

	if (speed > 0.1f && map.getHitInfosFromArc(tail_position, -angle, 10, (tip_position - tail_position).getLength(), this, true, @infos))
	{

		for (uint i = 0; i < infos.length; i ++)
		{

			CBlob@ blob = infos[i].blob;
			Vec2f hit_position = infos[i].hitpos;

			if (blob !is null)
			{
				if (blob.getShape().getConsts().platform && !CollidesWithPlatform(this, blob, velocity))
					continue;

				if (!doesCollideWithBlob(this, blob) || LimitedAttack_has_hit_actor(this, blob))
					continue;

				this.server_Hit(blob, hit_position, velocity, 0.0f, Hitters::ballista, true);
				BallistaHitBlob(this, hit_position, velocity, 0.0f, blob, Hitters::ballista);
				LimitedAttack_add_actor(this, blob);

			}
		}
	}
}

bool DoExplosion(CBlob@ this, Vec2f velocity)
{

	if (this.hasTag("bomb"))
	{

		if (this.hasTag("dead"))
			return true;

		Explode(this, 16.0f, 2.0f);
		LinearExplosion(this, velocity, 64.0f, 8.0f, 2, 4.0f, Hitters::bomb);

		this.Tag("dead");
		this.server_Die();
		this.getSprite().Gib();

		return true;

	}

	return false;

}

void BallistaHitBlob(CBlob@ this, Vec2f hit_position, Vec2f velocity, const f32 damage, CBlob@ blob, u8 customData)
{

	if (DoExplosion(this, velocity)
	        || this.get_bool("static"))
		return;

	if (blob.hasTag("flesh"))
		this.getSprite().PlaySound("ArrowHitFleshFast.ogg");
	else this.getSprite().PlaySound("ArrowHitGroundFast.ogg");

	if (!blob.getShape().isStatic())
		return;

	if (blob.getHealth() > 0.0f)
	{

		const f32 angle = velocity.Angle();

		if (blob.hasTag("wooden"))
		{
			this.setVelocity(velocity * 0.5f);

			u8 blocks_pierced = this.get_u8("blocks_pierced");
			const f32 speed = velocity.getLength();

			if (blocks_pierced < 1 && speed > FAST_SPEED)
				this.set_u8("blocks_pierced", blocks_pierced + 1);
			else SetStatic(this, angle);

		}
		else SetStatic(this, angle);

	}
	else this.setVelocity(velocity * 0.7f);

}

void BallistaHitMap(CBlob@ this, const u32 offset, Vec2f hit_position, Vec2f velocity, const f32 damage, u8 customData)
{

	if (DoExplosion(this, velocity)
	        || this.get_bool("static"))
		return;

	this.getSprite().PlaySound("ArrowHitGroundFast.ogg");

	CMap@ map = getMap();
	TileType type = map.getTile(offset).type;
	const f32 angle = velocity.Angle();

	if (type == CMap::tile_bedrock)
	{

		this.Tag("dead");
		this.server_Die();
		this.getSprite().Gib();

	}
	else if (!map.isTileGroundStuff(type))
	{

		if (map.getSectorAtPosition(hit_position, "no build") is null)
			map.server_DestroyTile(hit_position, 0.5f, this);

		u8 blocks_pierced = this.get_u8("blocks_pierced");
		const f32 speed = velocity.getLength();

		this.setVelocity(velocity * 0.5f);
		this.push("offsets", offset);

		if (blocks_pierced < 1 && speed > FAST_SPEED
		        && map.isTileWood(type))
			this.set_u8("blocks_pierced", blocks_pierced + 1);
		else SetStatic(this, angle);

	}
	else if (map.isTileSolid(type))
		SetStatic(this, angle);

}

void SetStatic(CBlob@ this, const f32 angle)
{

	Vec2f position = this.getPosition();

	this.set_u8("angle", Maths::get256DegreesFrom360(angle));
	this.set_bool("static", true);
	this.set_f32("lock_x", position.x);
	this.set_f32("lock_y", position.y);

	this.Sync("static", true);
	this.Sync("lock_x", true);
	this.Sync("lock_y", true);

	this.setVelocity(Vec2f_zero);
	this.setPosition(position);
	this.getShape().SetStatic(true);

	//this.getCurrentScript().runFlags |= Script::remove_after_this;

}

bool CollidesWithPlatform(CBlob@ this, CBlob@ blob, Vec2f velocity)
{
	f32 platform_angle = blob.getAngleDegrees();	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	float velocity_angle = direction.AngleWith(velocity);

	return !(velocity_angle > -90.0f && velocity_angle < 90.0f);
}

