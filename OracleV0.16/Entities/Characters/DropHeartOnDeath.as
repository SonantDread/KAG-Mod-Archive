
//random heart on death (default is 100% of the time for consistency + to reward murder)

#define SERVER_ONLY

const f32 probability = 1.0f; //between 0 and 1

void dropHeart(CBlob@ this)
{
	if (!this.hasTag("dropped heart")) //double check
	{
		CPlayer@ killer = this.getPlayerOfRecentDamage();
		CPlayer@ myplayer = this.getDamageOwnerPlayer();

		if (killer is null || ((myplayer !is null) && killer.getUsername() == myplayer.getUsername())) { return; }

		this.Tag("dropped heart");

		if ((XORRandom(1024) / 1024.0f) < probability)
		{
			CBlob@ heart = server_CreateBlob("heart", -1, this.getPosition());

			if (heart !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				heart.setVelocity(vel);
			}
		}
	}
}