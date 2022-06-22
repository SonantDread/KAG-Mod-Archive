
//random heart on death (default is 100% of the time for consistency + to reward murder)

#define SERVER_ONLY

//random heart on death (default is 100% of the time for consistency + to reward murder)

#define SERVER_ONLY

void dropHeart(CBlob@ this)
{
	if (!this.hasTag("dropped heart")) //double check
	{
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();

		if (killer is null || ((myplayer !is null) && killer.getUsername() == myplayer.getUsername())) { return; }

		this.Tag("dropped heart");

		if ((XORRandom(1024) / 1024.0f) < 1.0f)
		{
			CBlob@ heart = server_CreateBlob("heart", -1, this.getPosition());

			if (heart !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				heart.setVelocity(vel);
			}
		}
		if ((XORRandom(1024) / 1024.0f) < 0.8f)
		{
			CBlob@ bluelifefiber = server_CreateBlob("bluelifefiber", -1, this.getPosition());

			if (bluelifefiber !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				bluelifefiber.setVelocity(vel);
			}
		}
	}
}

void dropHeart2(CBlob@ this)
{
	if (!this.hasTag("dropped heart")) //double check
	{
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();

		if (killer is null || ((myplayer !is null) && killer.getUsername() == myplayer.getUsername())) { return; }

		this.Tag("dropped heart");

				if ((XORRandom(1024) / 1024.0f) < 1.0f)
		{
			CBlob@ heart = server_CreateBlob("heart", -1, this.getPosition());

			if (heart !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				heart.setVelocity(vel);
			}
		}
		if ((XORRandom(1024) / 1024.0f) < 0.8f)
		{
			CBlob@ redlifefiber = server_CreateBlob("redlifefiber", -1, this.getPosition());

			if (redlifefiber !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				redlifefiber.setVelocity(vel);
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.getTeamNum() == 0)
	{
 				if (getNet().isServer())
	if (this.hasTag("switch class") || this.hasTag("dropped heart") || this.hasBlob("food", 1)) { return; }    //don't make a heart on change class, or if this has already run before or if had bread

				dropHeart(this);
				this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	
	else if (this.getTeamNum() == 1)
	{
 				if (getNet().isServer())
				if (this.hasTag("switch class") || this.hasTag("dropped heart") || this.hasBlob("food", 1)) { return; }    //don't make a heart on change class, or if this has already run before or if had bread

				dropHeart2(this);
				this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}
