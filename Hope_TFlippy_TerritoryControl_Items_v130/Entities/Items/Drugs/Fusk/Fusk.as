void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
	
	this.Tag("forcefeed_always");
}

void onTick(CBlob@ this)
{
	CBlob@[] hoomans;
	this.getMap().getBlobsInRadius(this.getPosition(), 1.0f, hoomans);
	for (int i = 0; i < hoomans.length; i++)
	{
		if (hoomans[i] !is null)
		{
			CBlob@ blob = hoomans[i];
			if (blob.getPlayer() !is null && blob !is null && !this.isAttached())
			{
				int random = XORRandom(1000); // 0.05% for a tick
				if (5 > random && !blob.hasTag("injected")) 
				{
					if (!blob.hasScript("Fusk_Effect.as")) blob.AddScript("Fusk_Effect.as");
					blob.add_f32("fusk_effect", 0.25f);
					this.getSprite().PlaySound("Pus_Attack_0.og", 2.00f, 1.00f);

					print("injected fusk");
					blob.Tag("injected");
					if (isServer())
					{
						this.server_Die();
						blob.Untag("injected");
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Inject!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		// this.getSprite().PlaySound("Huuu.ogg", 1.0f, 1.5f);
		this.getSprite().PlaySound("Pus_Attack_0.ogg", 2.00f, 1.00f);

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.hasScript("Fusk_Effect.as")) caller.AddScript("Fusk_Effect.as");
			caller.add_f32("fusk_effect", 0.25f);
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
