

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetZ(-20.0f);
	this.set_string("username", "");
	this.set_s16("coins",0);

	this.addCommandID("claim");
	
	this.Tag("builder always hit");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if(forBlob.getPlayer() !is null)
	if(forBlob.getPlayer().getUsername() == this.get_string("username"))return true;
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.isOverlapping(this))
	if(caller.getPlayer() !is null)
		{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		if (caller.isOverlapping(this) && this.get_string("username") == "")
		caller.CreateGenericButton(16, Vec2f(0, -6), this, this.getCommandID("claim"), "claim locker", params);
		}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
	if (cmd == this.getCommandID("claim"))
		{
			if (this.get_string("username") != "") return;
		
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller is null) return;
			
			CPlayer@ player = caller.getPlayer();
			if (player is null) return;
			
			this.set_string("username", player.getUsername());
			this.server_setTeamNum(player.getTeamNum());
			this.Sync("username", true);
		}

	}
}

void onDie(CBlob@ this)
{
	CPlayer @player = getPlayerByUsername(this.get_string("username"));
	if (getNet().isServer())
	if(player !is null){
		player.server_setCoins(player.getCoins()+this.get_s16("coins"));
	}
}