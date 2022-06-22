#include "Hitters.as";

const f32 SPLASH_FACTOR = 5.0f;

void Splash(CBlob@ this, const uint splash_halfwidth, const uint splash_halfheight,
            const f32 splash_offset, const bool shouldStun = true)
{
	//extinguish fire
	CMap@ map = this.getMap();
	Sound::Play("SplashSlow.ogg", this.getPosition(), 3.0f);


    //bool raycast = this.hasTag("splash ray cast");

	if (map !is null)
	{
		bool is_server = getNet().isServer();
		Vec2f pos = this.getPosition() +
		            Vec2f(this.isFacingLeft() ?
		                  -splash_halfwidth * map.tilesize*splash_offset :
		                  splash_halfwidth * map.tilesize * splash_offset,
		                  0);

		for (int x_step = -splash_halfwidth - 2; x_step < splash_halfwidth + 2; ++x_step)
		{
			for (int y_step = -splash_halfheight - 2; y_step < splash_halfheight + 2; ++y_step)
			{
				Vec2f wpos = pos + Vec2f(x_step * map.tilesize, y_step * map.tilesize);
				Vec2f outpos;

				//extinguish the fire at this pos
				if (is_server)
				{
					map.server_setFireWorldspace(wpos, false);
				}

				//make a splash!
				bool random_fact = ((x_step + y_step + getGameTime() + 125678) % 7 > 3);

				if (x_step >= -splash_halfwidth && x_step < splash_halfwidth &&
				        y_step >= -splash_halfheight && y_step < splash_halfheight &&
				        (random_fact || y_step == 0 || x_step == 0))
				{
					map.SplashEffect(wpos, Vec2f(0, 10), 8.0f);
				}
			}
		}

		const f32 radius = Maths::Max(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);

		u8 hitter = shouldStun ? Hitters::water_stun : Hitters::water;

		Vec2f offset = Vec2f(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);
		Vec2f tl = pos - offset * 0.5f;
		Vec2f br = pos + offset * 0.5f;
		if (is_server)
		{
			CBlob@ ownerBlob;
			CPlayer@ damagePlayer = this.getDamageOwnerPlayer();
			if (damagePlayer !is null)
			{
				@ownerBlob = damagePlayer.getBlob();
			}

			CBlob@[] blobs;
			map.getBlobsInRadius(pos, radius, @blobs);
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (this is blob)
					continue;

				string blobname = blob.getName();
				bool hitHard = blob.getTeamNum() != this.getTeamNum() || ownerBlob is blob
								|| blobname=="trampoline" || blobname=="drill" || blobname=="mine"
								|| blobname=="keg" || blobname=="crate" || blobname=="food";
								// || blob.hasTag("vehicle"); // ok this would be toxic

				Vec2f splashforce = getSplashForce(pos, blob);

				if (shouldStun && (ownerBlob is blob || (this.isOverlapping(blob) && hitHard)))
				{
					this.server_Hit(blob, pos, splashforce, 0.0f, Hitters::water_stun_force, true);
				}
				else if (hitHard)
				{
					this.server_Hit(blob, pos, splashforce, 0.0f, hitter, true);
				}
				else //still have to hit teamies so we can put them out!
				{
					this.server_Hit(blob, pos, splashforce, 0.0f, Hitters::water, true);
				}
			}
		}
	}
}

// copied from Explosion.as ...... should be in bombcommon?
// It's not even in Explosion.as, here is a pretty weird place for this
Vec2f getBombForce(CBlob@ this, f32 radius, Vec2f hit_blob_pos, Vec2f pos, f32 hit_blob_mass, f32 &out scale)
{
	Vec2f offset = hit_blob_pos - pos;
	f32 distance = offset.Length();
	//set the scale (2 step)
	scale = (distance > (radius * 0.7)) ? 0.5f : 1.0f;
	//the force, copy across
	Vec2f bombforce = offset;
	bombforce.Normalize();
	bombforce *= 2.0f;
	bombforce.y -= 0.2f; // push up for greater cinematic effect
	bombforce.x = Maths::Round(bombforce.x);
	bombforce.y = Maths::Round(bombforce.y);
	bombforce /= 2.0f;
	bombforce *= hit_blob_mass * (3.0f) * scale;
	return bombforce;
}

Vec2f getSplashForce(Vec2f pos, CBlob@ hitBlob)
{
	Vec2f velocity = hitBlob.getPosition() - pos; // start with offset (direction of splash)
	// f32 distance = velocity.getLength(); // could use if we want to weaken at longer range

	const f32 oomph_range = 60.0f; 	// degree range from due left/right over which to scale oomph
	const f32 oomph_factor = 0.80f; // % of normal vel to add to vertical
	const f32 de_oomph_horizontal = 0.30f; // % of oomph velocity to remove from horizontal
	const f32 upwards_oomph = 0.50f; // % of normal oomph factor to add to ~90° (up) hits

	// Weaken the splash if it's accelerating / adding more velocity to an already moving blob
	const f32 accel_range = 1.50f; // % of splash vel, range of blob vel over which to curb accel

	const f32 stopping_force = 1.00f; // % of antiparallel blob velocity to counteract
	const f32 perp_velocity_lost = 0.20f; // % of perpendicular blob velocity to counteract

	// Adjust velocity to make it more vertical (oomph factor)
	velocity.Normalize();
	f32 angle = velocity.getAngleDegrees();
	f32 oomph_scale;
	if (angle > 90 && angle < 270)
		oomph_scale = (Maths::Max(0, oomph_range - Maths::Abs(180-angle)) / oomph_range);
	else
	{
		if (angle < 90)
			oomph_scale = (Maths::Max(0, oomph_range - angle) / oomph_range);
		else
			oomph_scale = (Maths::Max(0, oomph_range - (360-angle)) / oomph_range);
	}

	if (oomph_scale > 0)
	{
		if (velocity.x > 0)
			velocity.x -= de_oomph_horizontal * oomph_factor * oomph_scale;
		else if (velocity.x < 0)
			velocity.x += de_oomph_horizontal * oomph_factor * oomph_scale;
	}
	else
	{
		// set scale based on how close to 90° (relative to edges of the left/right oomph ranges)
		oomph_scale = Maths::Max(0, ((90-oomph_range) - Maths::Abs(90-angle)) / (90-oomph_range));
		oomph_scale *= upwards_oomph;
	}

	velocity.y -= oomph_factor * oomph_scale;

	velocity = velocity * SPLASH_FACTOR;

	// Adjust for hitBlob's preexisting velocity (stronger stopping force, weaker acceleration)
	angle = velocity.getAngleDegrees();
	Vec2f blobvel = hitBlob.getVelocity();
	velocity.RotateBy(angle);
	blobvel.RotateBy(angle);
	velocity.y -= blobvel.y * perp_velocity_lost;
	if (blobvel.x < 0)
	{
		velocity.x -= blobvel.x * stopping_force;
	}
	else if (blobvel.x > 0 && accel_range > 0) // accel_range enabled
	{
		velocity *= Maths::Max(0.0f, 1.0f - blobvel.x / (velocity.x * accel_range));
	}
	velocity.RotateBy(-1.0f * angle); // set velocity back to proper angle
	// blobvel.RotateBy(-1.0 * angle);

	// +0.3 mass to push really light things harder (like mats)
	// TODO: make sure +0.3 mass isn't stupid
	return velocity * (hitBlob.getMass() + 0.3f);
}

bool isSplashHitter(u8 hitter)
{
	// Hitters that should push blobs
	return hitter == Hitters::water_stun
		   || hitter == Hitters::water_stun_force;
}
