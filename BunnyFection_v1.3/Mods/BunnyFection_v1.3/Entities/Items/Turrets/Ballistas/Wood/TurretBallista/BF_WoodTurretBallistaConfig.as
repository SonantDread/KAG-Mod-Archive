//set your turret values here

void onInit( CBlob@ this )
{
	this.set_f32( "min_fire_distance", 110.0f );
	this.set_u16( "shoot_interval", 5 );//plus a fixed 45 from the fuse
	this.set_u16( "target_lock_time", 15 );//values higher than 10 recommended to save on performance!
	this.set_bool( "arc360", true );//360 degrees firing?

	this.set_string( "projectile", "bf_woodballistaarrow" );
	this.set_f32( "projectile_speed", 13.0f );
	this.set_f32( "projectile_lifetime", 0.60f );
	
	///global settings below
	this.Tag( "heavy weight" );
	this.Tag( "turret" );
	this.Tag( "place norotate" );
	this.addCommandID("upgrade");
}

/*
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	bool firing = this.get_bool( "litFuse" );
	return ( !firing && this.getTeamNum() == byBlob.getTeamNum() );
}
*/

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ up = caller.CreateGenericButton( "$mat_stone$", Vec2f(0.0f,0.0f), this, this.getCommandID("upgrade"), "50", params);
	if(caller.getDistanceTo(this) < 20.0f && caller.getBlobCount("mat_stone") >= 50)
	{
		if(up != null)
		{
			up.SetEnabled(true);
		}
	}
	else
	{
		up.SetEnabled(false);
	}
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	u16 netID;
	if(!params.saferead_netid(netID))
	{
	    return;
	}
	CBlob@ caller = getBlobByNetworkID(netID);
    if(cmd == this.getCommandID("upgrade"))
	{
		caller.TakeBlob("mat_stone", 50);
		if(this !is null)
		{
			Vec2f pos = this.getPosition();
			this.server_Die();
			CBlob @newBlob = server_CreateBlob( "bf_stoneturretballista", 0, pos );
		}
	}
}