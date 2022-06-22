//set your turret values here

void onInit( CBlob@ this )
{
	this.set_f32( "min_fire_distance", 150.0f );
	this.set_u16( "shoot_interval", 5 );//plus a fixed 45 from the fuse
	this.set_u16( "target_lock_time", 15 );//values higher than 10 recommended to save on performance!
	this.set_bool( "arc360", true );//360 degrees firing?

	this.set_string( "projectile", "bf_stoneballistaarrow" );
	this.set_f32( "projectile_speed", 14.0f );
	this.set_f32( "projectile_lifetime", 0.80f );
	
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
