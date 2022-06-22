#include "Hitters.as";
#include "TeamColour.as";

void onInit( CBlob@ this )
{
	this.SetLight(true);	
	this.SetLightColor(getTeamColor(this.getTeamNum()));
	this.SetLightRadius(16.0f);

	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;
	consts.bullet = true;
	consts.net_threshold_multiplier = 2.0f;
	this.Tag("projectile");
}

void onTick( CBlob@ this )
{
   	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = this.getPosition();

	f32 angle = (this.getVelocity()).Angle();
	this.setAngleDegrees(-angle);
	
	if (position.x < 0.1f ||
	        position.x > (map.tilemapwidth * map.tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}	

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		HitMap(this, end, this.getOldVelocity());
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && !this.hasTag("collided"))
	{
		if (blob.getName() == "triangle" || blob.getName() == "wood_triangle" || blob.getName() == "stone_triangle")
		{
			this.Tag("collided");
			this.setPosition(blob.getPosition());
			HitBlob(this, blob, point1, this.getOldVelocity());
		}	
		else if (blob.getShape().isStatic() && blob.getShape().getConsts().collidable && !blob.getShape().getConsts().platform)
		{
			this.server_Die();
		}
	}
}

void HitBlob(CBlob@ this, CBlob@ triblob, Vec2f worldPoint, Vec2f velocity)
{
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();

	if (triblob !is null)
	{
		this.setVelocity(Vec2f(0, 0));	
		const f32 ts = map.tilesize; 
		const bool facingleft = triblob.isFacingLeft();
		f32 angle = facingleft ? triblob.getAngleDegrees()-135.0f : triblob.getAngleDegrees()-45.0f ;
		Vec2f pos = triblob.getPosition();	

		Vec2f down = Vec2f(pos + Vec2f(-2, ts).RotateBy(angle));
		Vec2f up = Vec2f(pos + Vec2f(-2, -ts).RotateBy(angle));

		CBlob@ blob_up = getMap().getBlobAtPosition(up);
		CBlob@ blob_down = getMap().getBlobAtPosition(down);

		bool surface_upper =  blob_up !is null ? blob_up.getName() == "stone_triangle" || blob_up.getName() =="wood_triangle" || blob_up.getName() =="triangle"  : false;
		bool surface_lower = blob_down !is null ? blob_down.getName() == "stone_triangle" || blob_down.getName() =="wood_triangle" || blob_down.getName() =="triangle"  : false;

		Vec2f upperfront = Vec2f(pos + Vec2f(4, -4).RotateBy(angle));
		Vec2f lowerfront = Vec2f(pos + Vec2f(4, 4).RotateBy(angle));	
		Vec2f midfront = Vec2f(pos + Vec2f(8, 0).RotateBy(angle));	

		bool othersurfacesclear = surface_upper && surface_lower && // has triangle blobs left and right
								 !map.isTileSolid(upperfront) && !map.isTileSolid(lowerfront) && !map.isTileSolid(midfront) && // front not blocked by solids
								 !blockingblobs(this, pos, map, angle, true); // not blocked by blobs

		if (othersurfacesclear)
		{			
			MakeWithThePortal(this, angle, pos+( Vec2f(2,0).RotateBy(angle)));
		}
		else
		{
			this.server_Die();
		}	
	}
}

void HitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity)
{
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	f32 angle = 0;
	Vec2f pos;
	bool othersurfacesclear;	

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);

	Vec2f tp = worldPoint-norm;
	tp = map.getTileSpacePosition(tp);
	Vec2f lock = map.getTileWorldPosition(tp);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock+Vec2f(4.0f,4.0f));
	pos = this.getPosition();

	const f32 ts = map.tilesize;

	Vec2f left = Vec2f(pos + Vec2f(-ts, 0));
	Vec2f right = Vec2f(pos + Vec2f(ts, 0));
	Vec2f down = Vec2f(pos + Vec2f(0, ts));
	Vec2f up = Vec2f(pos + Vec2f(0, -ts));

	bool surface_left = map.isTileSolid(left);
	bool surface_right = map.isTileSolid(right);
	bool surface_above = map.isTileSolid(up);
	bool surface_below = map.isTileSolid(down);

	if (surface_right && (!surface_left || !surface_below || !surface_above))
	{ angle = 180; }
	else if (surface_left && (!surface_below || !surface_right || !surface_above))	
	{ angle = 0; }
	else if (surface_above && (!surface_left || !surface_right || !surface_below))	
	{ angle = 90; }
	else if (surface_below && (!surface_left || !surface_right || !surface_above))	
	{ angle = 270; }
	else 
	{ this.server_Die(); }

	Vec2f upperbehind = Vec2f(pos + Vec2f(-ts, -ts).RotateBy(angle));
	Vec2f lowerbehind = Vec2f(pos + Vec2f(-ts, ts).RotateBy(angle));
	//Vec2f midbehind = Vec2f(pos + Vec2f(-ts, 0).RotateBy(angle)); // not needed, just checked it above
	Vec2f upperfront = Vec2f(pos + Vec2f(ts, -ts).RotateBy(angle));
	Vec2f lowerfront = Vec2f(pos + Vec2f(ts, ts).RotateBy(angle));
	Vec2f midfront = Vec2f(pos + Vec2f(ts, 0).RotateBy(angle));
	Vec2f uppermid = Vec2f(pos + Vec2f(0, -ts).RotateBy(angle));
	Vec2f lowermid = Vec2f(pos + Vec2f(0, ts).RotateBy(angle));

	othersurfacesclear = map.isTileSolid(upperbehind) && map.isTileSolid(lowerbehind) &&  // has solid tiles to place on
						!map.isTileSolid(uppermid) && !map.isTileSolid(lowermid) && // sides not blocked
						!map.isTileSolid(upperfront) && !map.isTileSolid(lowerfront) && !map.isTileSolid(midfront) && // infront not blocked
						!blockingblobs(this, pos, map, angle, false); // solid blobs blocking portal placement.

	if (othersurfacesclear)
	{			
		MakeWithThePortal(this, angle, pos);
	}
	else
	{
		this.server_Die();
	}
}

void MakeWithThePortal(CBlob@ this, f32 angle, Vec2f pos)
{
	CBlob@[] allblobs;
	getBlobs(@allblobs);
	for (uint i = 0; i < allblobs.length; i++)
	{
		CBlob@ blob = allblobs[i];
		
		if (blob.getName() == "portal" && blob.getTeamNum() == this.getTeamNum()  && blob.get_u16( "ownerID") == this.get_u16( "ownerID"))
		{
			blob.server_Die(); // kill any portal the same colour, by the same person.
		}
	}

    CBlob@ portal = server_CreateBlobNoInit( "portal");
    if (portal !is null)
    {           
    	portal.SetLight(true);
		portal.SetLightColor(getTeamColor(this.getTeamNum()));
		portal.SetLightRadius(32.0f);
    	portal.server_setTeamNum(this.getTeamNum());
    	portal.setPosition(pos); 
    	
    	portal.set_f32("pangle", angle); 
        portal.set_u16( "ownerID", this.get_u16( "ownerID" ) ); 

        portal.Init();
		this.server_Die();	
    }
}

bool blockingblobs(CBlob@ this, Vec2f pos, CMap@ map, f32 angle, bool angled)
{	
	u8 extra = angled ? 6:0;
	Vec2f mid = Vec2f(pos + Vec2f(0+extra, 0).RotateBy(angle));
	Vec2f uppermid = Vec2f(pos + Vec2f(0+extra, -8).RotateBy(angle));
	Vec2f lowermid = Vec2f(pos + Vec2f(0+extra, 8).RotateBy(angle));

	if (map.getSectorAtPosition(pos, "no build") !is null || map.getSectorAtPosition(uppermid, "no build") !is null || map.getSectorAtPosition(lowermid, "no build") !is null)
	{
		return true;
	}

	CBlob@[] blobs;
	if(map.getBlobsAtPosition(uppermid, @blobs) || map.getBlobsAtPosition(lowermid, @blobs) || map.getBlobsAtPosition(mid, @blobs))
	{
		for(u32 i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if(blob !is null)
			{	//string bname = blob.getName();
				if(blob.getShape().getConsts().support > 0)
				{
					return true;
				}
			}
		}
	}

	CBlob@[] pblobs;
	if(map.getBlobsAtPosition(pos, @pblobs))
	{
		for(u32 i = 0; i < pblobs.length; i++)
		{
			CBlob@ pblob = pblobs[i];
			if(pblob !is null)
			{
				if(pblob.getName() == "portal" && pblob.getTeamNum() != this.getTeamNum()) // only check center position for portals
				{
					return true;
				}
			}
		}
	}
	return false;
}