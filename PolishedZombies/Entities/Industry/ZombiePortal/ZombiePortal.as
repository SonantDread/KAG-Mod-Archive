void onInit(CBlob@ this)
{	 
	this.Tag("Zombie_Portal");
	this.Untag("building");
	
	this.getSprite().SetZ(-50); //background

	CSpriteLayer@ portal = this.getSprite().addSpriteLayer("portal", "ZombiePortal.png" , 64, 64, -1, -1);
	CSpriteLayer@ lightning = this.getSprite().addSpriteLayer("lightning", "EvilLightning.png" , 32, 32, -1, -1);
	Animation@ anim = portal.addAnimation("default", 0, true);
	Animation@ lanim = lightning.addAnimation("default", 4, false);
	for (int i=0; i<7; i++) lanim.AddFrame(i*4);
	Animation@ lanim2 = lightning.addAnimation("default2", 4, false);
	for (int i=0; i<7; i++) lanim2.AddFrame(i*4+1);
	anim.AddFrame(1);
	portal.SetRelativeZ(1000);
	
	this.getShape().getConsts().mapCollisions = false;

	this.set_bool("portalbreach",false);
	this.set_bool("portalplaybreach",false);
	this.SetLight(false);
	this.SetLightRadius(64.0f);
}

void onDie(CBlob@ this)
{
	server_DropCoins(this.getPosition() + Vec2f(0,-32.0f), 350);
}

void onTick(CBlob@ this)
{
	Vec2f pos = this.getPosition();

	if(this.get_bool("portalbreach"))
	{
		// Play sound if have not already
		if (this.get_bool("portalplaybreach"))
		{
			this.getSprite().PlaySound("PortalBreach");
			this.set_bool("portalplaybreach",false);
			this.SetLight(true);
		}

		int spawnRate = 16 + (184 * (this.getHealth() / 42.0));
		if (getGameTime() % spawnRate == 0)
		{
			this.getSprite().PlaySound("Thunder");
			CSpriteLayer@ lightning = this.getSprite().getSpriteLayer("lightning");
			if (XORRandom(4) > 2)
				lightning.SetAnimation("default");
			else
				lightning.SetAnimation("default2");

			// Rest is server stuff
			if (!getNet().isServer())
				return;

			int num_zombies = getRules().get_s32("num_zombies");
			int max_zombies = getRules().get_s32("max_zombies");

			// We want some zombies to spawn during the day on the surface
			if (max_zombies - num_zombies > 35)
			{
				if (getGameTime() % 60 == 0)
				{
					bool playerPresent = false;
					CBlob@[] blobs;
					getMap().getBlobsInRadius(pos, 48, @blobs);
					for (uint step = 0; step < blobs.length; ++step)
					{
						CBlob@ blob = blobs[step];
						if (blob.hasTag("player"))
						{
							playerPresent = true;
						}
					}

					// Give portals a chance to turn back off if players leave them alone.
					if (playerPresent == false && XORRandom(5) == 0)
					{
						this.SetLight(false);
						this.set_bool("portalbreach", false);
						this.Sync("portalbreach", false);
						return;
					}
				}

				// Spawn Zombiesss
				int r = XORRandom(12);
				int rr = XORRandom(8);

				if (r == 11 && rr < 2)
					server_CreateBlob("wraith", -1, pos);
				else if (r == 9 && rr > 6)
					server_CreateBlob("zknight", -1, pos);
				else if (r == 7)
					server_CreateBlob("horror", -1, pos);
				else if (r == 6)
					server_CreateBlob("gasbag", -1, pos);
				else if (r == 5)
					server_CreateBlob("zombie", -1, pos);
				else if (r == 4)
					server_CreateBlob("skeleton", -1, pos);
				else if (r == 3)
					server_CreateBlob("catto", -1, pos);
				else if (r == 2)
					server_CreateBlob("zchicken", -1, pos);
				else if (r == 1)
					server_CreateBlob("hknight", -1, pos);
				
				num_zombies++;
				getRules().set_s32("num_zombies",num_zombies);
			}
		}
	}
	else
	{
		if (getGameTime() % 60 == 0)
		{
			CBlob@[] blobs;
			this.getMap().getBlobsInRadius(pos, 24, @blobs);
			for (uint step = 0; step < blobs.length; ++step)
			{
				CBlob@ other = blobs[step];
				if (other.hasTag("player"))
				{
					this.set_bool("portalbreach",true);
					this.set_bool("portalplaybreach",true);
					this.Sync("portalplaybreach",true);
					this.Sync("portalbreach",true);
				}
			}
		}
	}
}