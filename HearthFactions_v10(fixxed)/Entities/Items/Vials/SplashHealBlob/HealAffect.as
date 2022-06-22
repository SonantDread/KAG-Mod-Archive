// v6steeda/Blubahub
// Based on Food.cfg scripts Food.as and Eatable.as

const string heal_id = "heal command";

void onInit(CBlob@ this)
{
	this.addCommandID(heal_id);
	
	this.server_SetTimeToDie(1.0f); // 128 = about 5 3/4 seconds
}

void Heal(CBlob@ this, CBlob@ blob)
{
	bool exists = getBlobByNetworkID(this.getNetworkID()) !is null;
	if (getNet().isServer() && blob.hasTag("player") && blob.getHealth() < blob.getInitialHealth() && !this.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(blob.getNetworkID());

		u8 heal_amount = 255; //in quarter hearts, 255 means full hp

		params.write_u8(heal_amount);
		
		this.SendCommand(this.getCommandID(heal_id), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID(heal_id))
	{
		//if (getGameTime() % 3 == 0) // ~1 second - thanks Blav
		//{
			if (getNet().isServer())
			{
				u16 blob_id;
				if (!params.saferead_u16(blob_id)) return;
	
				CBlob@ theBlob = getBlobByNetworkID(blob_id);
				if (theBlob !is null)
				{
					u8 heal_amount;
					if (!params.saferead_u8(heal_amount)) return;
					
					theBlob.server_Heal(f32(heal_amount) * 0.25f);
					
					if (getGameTime() % 2 == 0) // ~1 second - thanks Blav
					{
						this.SendCommand(this.getCommandID(heal_id), params); // loop
					}
				}
			}
		//}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}
	
	if (getNet().isServer() && !blob.hasTag("dead"))
	{
		Heal(this, blob);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}