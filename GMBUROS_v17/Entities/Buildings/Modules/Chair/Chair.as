
void onInit(CBlob@ this)
{
	this.addCommandID("sit");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if(this.isAttachedTo(caller)){
		caller.CreateGenericButton(16, Vec2f(0,-4), this, this.getCommandID("sit"), "Get up",params);
	} else
	if(this.isOverlapping(caller)){
		caller.CreateGenericButton(19, Vec2f(0,-4), this, this.getCommandID("sit"), "Sit",params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sit"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			if(getNet().isServer()){
				if(!this.isAttachedTo(caller)){
					this.server_AttachTo(caller, "SEAT");
					caller.Tag("seated");
				} else {
					this.server_DetachFrom(caller);
					caller.Untag("seated");
				}
				caller.Sync("seated",true);
			}
		}
	}
}