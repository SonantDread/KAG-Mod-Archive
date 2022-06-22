 //#include "Knocked.as"
 #include "PlacementCommon.as"

const f32 BULLET_SPEED = 15.0f;
const f32 BULLET_RANGE = 1000.0f;

void onInit(CBlob@ this)
{
	this.addCommandID("shootblue");
	this.addCommandID("shootorange");
	this.server_setTeamNum(0);
	this.getCurrentScript().runFlags |= Script::tick_attached;
	this.getShape().getConsts().collideWhenAttached = false;
}

void onTick(CBlob@ this)
{
	 if (this.isAttached()) 
	 {	
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
	    CBlob@ holder = point.getOccupied();
	    const bool action1 = holder.isKeyJustPressed( key_action1 );
	    const bool action2 = holder.isKeyJustPressed( key_action2 );
		if(holder !is null)
		{			
			if (action1)
			{
				Shoot(this,holder,1);
			} 
			else if (action2)
			{
				Shoot(this,holder,2);
			}

			Vec2f vec = holder.getAimPos() - this.getPosition();
			const f32 aimangle = getAimAngle(this,holder);

			//CSprite@ sprite = this.getSprite();
			//sprite.ResetTransform();
	        //sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-5,0) : Vec2f(5,0) );	        
	        this.setAngleDegrees( aimangle ); 
	        if (aimangle > 180)
	        {
	        	this.SetFacingLeft(true);
	        }
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		if (attachedPoint.name == "PICKUP")
		{
			this.set_u16( "ownerID" ,attached.getNetworkID()); // set owner to the player who picks it up
			if (attached.getName() == "archer")
			{	
				attached.RemoveScript("ArcherLogic.as");
			}	
			else if (attached.getName() == "builder")
			{	
				//attached.set_TileType("buildtile", 0); // doesn't work
				BlockCursor bc;
				attached.set("blockCursor", null); // kills any held block tiles, basically to remove the red line when trying to build
				attached.set("blockCursor", bc); // add it again because we need it

				attached.RemoveScript("BuilderLogic.as");
				attached.RemoveScript("BlobPlacement.as"); // have remove this and add it on detach else blob placement stops working
			}		
			else if (attached.getName() == "knight")
			{	
				attached.RemoveScript("KnightLogic.as");
			}	
		}	
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (getNet().isServer())
	{
		if (detached.getName() == "archer")
		{	
			detached.AddScript("ArcherLogic.as");
		}
		if (detached.getName() == "builder")
		{	
			detached.AddScript("BuilderLogic.as");
			detached.AddScript("BlobPlacement.as");
		}
		else if (detached.getName() == "knight")
		{	
			detached.AddScript("KnightLogic.as");
		}
	}
}

void Shoot( CBlob@ this, CBlob@ holder, u8 type)
{
	if ( !holder.isMyPlayer() )
		return;

	Vec2f pos = holder.getPosition();
	Vec2f aimVector = holder.getAimPos() - pos;
	const f32 aimdist = aimVector.Normalize();
	
	Vec2f vel = (aimVector * BULLET_SPEED);

	f32 lifetime = Maths::Min( 0.05f + BULLET_RANGE/BULLET_SPEED/32.0f, 1.35f); // stolen from shiprekt

	CBitStream params;
	params.write_Vec2f( vel );
	params.write_f32( lifetime );
	
	params.write_bool( true );
	Vec2f rPos = ( pos + aimVector*3 );
	params.write_Vec2f( rPos );	

	this.getSprite().PlaySound("/PortalShoot");
	
	if (type == 1)
	{
		this.SendCommand( this.getCommandID("shootblue"), params );
	}
	else if (type == 2)
	{
		this.SendCommand( this.getCommandID("shootorange"), params );
	}
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();
    return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	Vec2f velocity = params.read_Vec2f();
	f32 lifetime = params.read_f32();
	Vec2f pos;		
	Vec2f rPos = params.read_Vec2f();
	pos = rPos + this.getPosition();

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
    CBlob@ holder = point.getOccupied();
	u16 blobID = holder.getNetworkID();

	if (this.getCommandID("shootblue") == cmd /* && canShoot( this ) */ )
	{		
		if (getNet().isServer())
		{
			this.server_setTeamNum(0);
            CBlob@ bullet = server_CreateBlob( "portalbullet", 0, pos );
            if (bullet !is null)
            {
	            bullet.set_u16( "ownerID", this.get_u16( "ownerID" ) ); 
                bullet.setVelocity( velocity );
                bullet.server_SetTimeToDie( lifetime ); 
            }
    	}			
	}

	if (this.getCommandID("shootorange") == cmd /* && canShoot( this ) */ )
	{		
		if (getNet().isServer())
		{
			this.server_setTeamNum(4);
            CBlob@ bullet = server_CreateBlob( "portalbullet", 4, pos );
            if (bullet !is null)
            {
            	bullet.set_u16( "ownerID", this.get_u16( "ownerID" ) );
                bullet.setVelocity( velocity );
                bullet.server_SetTimeToDie( lifetime ); 
            }
    	}		
	}
}