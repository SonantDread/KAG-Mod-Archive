

void onInit( CBlob@ this )
{
	this.addCommandID("Equip");
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	if(caller.getDistanceTo(this) < 10.0f)
	{
		CButton@ Fire_on = caller.CreateGenericButton( 12, Vec2f(0.0f,1.0f), this, this.getCommandID("Equip"), "", params);
		if(Fire_on != null)
		{
			Fire_on.SetEnabled(true);
		}
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
    if(cmd == this.getCommandID("Equip"))
	{
		caller.set_u8( "armor", 0 );
		caller.getSprite().ReloadSprite("../Mods/BunnyFection/Mods/BunnyFection_v1.3/Entities/Characters/Bunny/Cobalt.png");
		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
	
}