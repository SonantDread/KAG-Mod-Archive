void onInit(CBlob@ this)
{
	this.addCommandID("use");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getName() == "builder")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		string hisname = this.getName();
		params.write_string(hisname);
		CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("use"), this.isAttachedTo(caller) ? "Use this rune!" : "Pickup this rune to use.", params);
		if(button !is null)
		{
			if(this.isAttachedTo(caller))
				button.SetEnabled(true);
			else
				button.SetEnabled(false);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		string runename = params.read_string();
		if (caller !is null)
		{
			if(runename == "irune")
			{
				this.getSprite().PlaySound("EvilNotice.ogg");
				caller.set_u32("irune_timer", 301);
			}
			else if(runename == "srune")
			{
				this.getSprite().PlaySound("OrbFireSound.ogg");
				caller.set_u32("srune_timer", 301);
			}

			if (getNet().isServer())
			{
				this.server_Die();
			}
		}
	}
}
