#define SERVER_ONLY

void onDie(CBlob@ this)
{
	if (this.getPlayer() is null || this is null || getRules() is null)
		return;

	if(getRules().get_bool("bombsondeathcharm_" + this.getPlayer().getUsername()))
	{
		for(uint i=0; i<3; ++i)
		{
			CBlob@ sbomb = server_CreateBlob("sbomb", this.getTeamNum(), this.getPosition());

			if (sbomb !is null)
			{
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				sbomb.setVelocity(vel);
			}
		}
	}
}