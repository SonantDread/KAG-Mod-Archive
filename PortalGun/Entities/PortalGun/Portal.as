
const f32 MIN_EXIT_VELOCITY = 5.0f; // makes a blob pop out more.
const f32 MAX_EXIT_VELOCITY = 20.0f; // prevents round the world trips in one jump.

void onInit( CBlob@ this )
{	
	this.getSprite().SetZ(1000.0f);	
	this.setAngleDegrees( this.get_f32("pangle"));
	this.getShape().SetOffset(Vec2f(6, 0));
	this.getShape().SetStatic(true);
	this.Tag("no falldamage"); // any overlapping blobs don't get fall damage, handy dandy
	this.Tag("invincible");
	this.Tag("portal");
}

CBlob@ getBlob(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 6.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (!b.getShape().isStatic() && !b.isAttached() && b.getName() != "portalbullet") // anymore blobs to not teleport?
			{
				return b;
			}
		}
	}
	return null;
}

CBlob@ getPortal(CBlob@ this)
{		
	CBlob@[] portals;
	if (getBlobsByTag("portal", @portals))
	{
		for (uint i = 0; i < portals.length; i++)
		{
			CBlob@ p = portals[i];
					
			if (p.getName() == "portal" && p.getTeamNum() != this.getTeamNum() && p.get_u16( "ownerID") == this.get_u16( "ownerID") )
			{
				return p;			
			}
		}
	}
	return null;
}

void onTick(CBlob@ this)
{	

	CBlob@ portal = getPortal(this); // get the other portal.

	/*
	CBlob@[] players;
	if (getBlobsByTag("player", @players))
	{
		for (uint i = 0; i < players.length; i++)
		{
			CBlob@ player = players[i];
			if (player !is null)
			{
				if (this.isOverlapping(player) && player.getOldVelocity().Length() > 5 && portal !is null)
				{
					player.getShape().getConsts().mapCollisions = false; // too dodgy
				}
				else 
				{
					player.getShape().getConsts().mapCollisions = true;
				}
			}
		}
	} */

	if (portal !is null)
	{
		CBlob @blob = getBlob(this); // get the blob we want to teleport.
		if (blob !is null)
		{			
			Vec2f velocity_old = blob.getOldVelocity();			
			if (getGameTime() > blob.get_u32("portal timer") + 2 )
			{		
				Vec2f exitVelocity = Vec2f( 0, Maths::Min(Maths::Max(velocity_old.y, MIN_EXIT_VELOCITY), MAX_EXIT_VELOCITY));

				f32 pangle = portal.getAngleDegrees();						

				Vec2f dir = Vec2f(blob.getRadius()+6.0f, 0.0f);
				dir.RotateBy(pangle);
				float velangle = dir.AngleWith(velocity_old);

				blob.setPosition(portal.getPosition()+dir);
				blob.setVelocity(exitVelocity.RotateBy(pangle-90));

				blob.set_u32("portal timer", getGameTime()); 
			}
		}
	}

	CBlob@ owner = getBlobByNetworkID( this.get_u16( "ownerID" ) );
	if (owner is null || owner.hasTag("dead")) // owner dead check
	{
		this.server_Die();
	}

	if (this.getTickSinceCreated() > 30 && getGameTime() % 10 == 0) // not sure when this is nessesary, why not.
	{			
		
		f32 angle = this.getAngleDegrees()+90;
		bool angled = (angle == 45.0f || angle == 135.0f || angle == 225.0f || angle == 315.0f);
		if(angled)
		{
			AngledCheck(this);
		}
		else
		{
			FlatCheck(this);
		}		
	}	
}

void FlatCheck(CBlob@ this)
{
	f32 angle = this.getAngleDegrees();
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	const f32 ts = map.tilesize;

	Vec2f off = Vec2f(pos + Vec2f(-ts, 0).RotateBy(angle));
	Vec2f upperoff = Vec2f(pos + Vec2f(-ts, -ts).RotateBy(angle));
	Vec2f loweroff = Vec2f(pos + Vec2f(-ts, ts).RotateBy(angle));
	Vec2f uppermid = Vec2f(pos + Vec2f(0, -ts).RotateBy(angle));
	Vec2f lowermid = Vec2f(pos + Vec2f(0, ts).RotateBy(angle));

	bool hastilespaces = (!map.isTileSolid(pos) && map.isTileSolid(off) && map.isTileSolid(upperoff)
				 		&& map.isTileSolid(loweroff) && !map.isTileSolid(uppermid) && !map.isTileSolid(lowermid));
	if (!hastilespaces)
	{
		this.server_Die();
	}
}

void AngledCheck(CBlob@ this)
{
	f32 angle = this.getAngleDegrees();
	CMap@ map = this.getMap();
	const f32 ts = map.tilesize;
	Vec2f pos = this.getPosition();
	Vec2f mid = Vec2f(pos + Vec2f(-6, 0).RotateBy(angle));
	Vec2f down = Vec2f(pos + Vec2f(-6, 10).RotateBy(angle));
	Vec2f up = Vec2f(pos + Vec2f(-6, -10).RotateBy(angle));

	CBlob@ blob_mid = map.getBlobAtPosition(mid);
	CBlob@ blob_up = map.getBlobAtPosition(up);
	CBlob@ blob_down = map.getBlobAtPosition(down);

	bool surface_mid = blob_mid !is null ? blob_mid.getName() =="stone_triangle" || blob_mid.getName() =="wood_triangle" || blob_mid.getName() =="triangle" : false;
	bool surface_upper =  blob_up !is null ? blob_up.getName() =="stone_triangle" || blob_up.getName() =="wood_triangle" || blob_up.getName() =="triangle" : false;
	bool surface_lower = blob_down !is null ? blob_down.getName() =="stone_triangle" || blob_down.getName() =="wood_triangle" || blob_down.getName() =="triangle" : false;

	bool hasSupport = (surface_upper && surface_lower && surface_mid );
	if (!hasSupport )
	{
		this.server_Die();
	}
	
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("/PortalDie");
}
