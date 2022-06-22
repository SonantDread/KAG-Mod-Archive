const string spawn_prop = "spawn_prop";

void onInit(CBlob@ this)
{
	this.set_s16(spawn_prop, 80);
}

void onTick(CBlob@ this)
{
	if (this.get_s16(spawn_prop) > 0 && getGameTime() % 5 == 0)
	{
		this.set_s16(spawn_prop, this.get_s16(spawn_prop) - 1);
	}


	if (this.get_s16(spawn_prop) == 0)
	{
		CBlob@[] blobsInRadius;
		getBlobsByName("fighterplane", @blobsInRadius);
		getBlobsByName("bomberplane", @blobsInRadius);

		if (blobsInRadius.length <= 1)
		{
			this.set_s16(spawn_prop, 252);

			this.getSprite().PlaySound("/BuildVehicle.ogg");

			if (!isServer())
				return;
			server_CreateBlob(XORRandom(100) <= 70 ? "fighterplane" : "bomberplane",this.getTeamNum(),this.getPosition() + Vec2f(64 - XORRandom(32), 0.0f));
			
		}
		else
		{
			this.set_s16(spawn_prop, 170);
		}
	}
}