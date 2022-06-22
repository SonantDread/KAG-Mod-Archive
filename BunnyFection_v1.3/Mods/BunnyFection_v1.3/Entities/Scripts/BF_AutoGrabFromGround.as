// set what it grabs with
// this.set_string("autograb blob", "mat_bolts")

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 89; // opt

	if (!this.exists("autograb blob"))
	{
		this.set_string("autograb blob", "");
	}
	if (!this.exists("blob tag"))
	{
		this.set_string("blob tag", "");
	}
	
}

void onTick(CBlob@ this)
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.1f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.isOnGround() && !b.isAttached() && b.getName() == this.get_string("autograb blob"))
			{
				this.server_PutInInventory(b);
			}
			else if (b.isOnGround() && !b.isAttached() && b.hasTag(this.get_string("blob tag")))
			{
				this.server_PutInInventory(b);
			}
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("/PopIn");
}
