void onRestart(CRules@ this)
{
	for (uint i = 0; i < getPlayerCount(); ++ i)
	{
		CPlayer@ player = getPlayer(i);
		player.setDeaths(0);
		player.setKills(0);
		player.setAssists(0);
	}
}
