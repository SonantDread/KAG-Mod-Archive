const u16 EFFECT_TIME = 6 * 30;

void onInit( CBlob@ this )
{
    AttachmentPoint@ att = this.getAttachments().getAttachmentPointByName("PICKUP");
	att.SetKeysToTake(key_action1 | key_action2);
    att.SetMouseTaken(false);
	this.Tag( "dont deactivate" );
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this is null || caller is null) return;
    if ( caller.getTeamNum() == this.getTeamNum() && caller.getDistanceTo(this) < 10.0f && !this.hasTag("activated") )
	{
		CBitStream params;
		string caller_name = caller.getPlayer().getUsername();
		params.write_string(caller_name);
		caller.CreateGenericButton( 12, Vec2f(0,-8), this, this.getCommandID("activate"), "Drink", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (this is null || params is null) return;
    if (cmd == this.getCommandID("activate"))
    {
		const string caller_name = params.read_string();
		CPlayer@ player = getPlayerByUsername(caller_name);
		if (player is null) return;
		CBlob@ drinker = player.getBlob();
		if ( drinker !is null )
		{
			//effect
			drinker.set_u16( "invisibilityEffectTime", getGameTime() + EFFECT_TIME );
			drinker.AddScript( "/BF_PotionInvisibilityEffect.as" );

			//sound effect
			this.getSprite().PlaySound("/PotionDrink.ogg");
			
			if ( getNet().isServer() )
				this.server_Die();
		}
    }
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return ( this.getTeamNum() == byBlob.getTeamNum() );
}