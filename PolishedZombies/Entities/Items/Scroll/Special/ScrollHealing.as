#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("scroll healing");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("scroll healing"), "Heals nearby allies", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("scroll healing"))
	{
	    bool healed = false;
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if (b.hasTag("player") && !b.hasTag("dead") && b.getHealth() != b.getInitialHealth())
					{
						b.server_Heal(b.getInitialHealth());
						healed = true;
					}
				}
			}
		}
		
		if (healed)
		{
			this.server_Die();
		}
	}
}