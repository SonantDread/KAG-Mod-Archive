// Boat logic
#include "KnockedCommon.as"

void onInit(CBlob@ this)
{
	this.addCommandID("dropBomb");
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ blob = ap.getOccupied();

				if (blob !is null && ap.socket)
				{
					if (ap.name == "FLYER" && !isKnocked(blob))
					{
						if (ap.isKeyPressed(key_action3))
						{
							if (blob.isMyPlayer())
							{
								CBitStream params;
								params.write_netid(blob.getPlayer().getNetworkID());
								this.SendCommand(this.getCommandID("dropBomb"), params);
							}
						}

					}
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("dropBomb"))
	{
		if (!(getNet().isServer())) return;
		if ((this.get_s32("bombTimer") + 90) <= getGameTime())
		{
			CInventory@ inv = this.getInventory();
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @blob = inv.getItem(i);
				if (blob.getName() == "bombball")
				{
					if(this.server_PutOutInventory(blob))
					{
						blob.setPosition(this.getPosition() + Vec2f(0.0f, 10.0f));
						u16 netid;
						if (params.saferead_netid(netid)) blob.SetDamageOwnerPlayer(getPlayerByNetworkId(netid));
						this.set_s32("bombTimer", getGameTime());
						return;
					}
				}
			}
		}
	}
}
