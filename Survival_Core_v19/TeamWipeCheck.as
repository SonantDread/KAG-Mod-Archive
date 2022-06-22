
void TeamWipeCheck(int team){

	if(!isServer())return;

	int Bulwarks = 0;
	{
		CBlob@[] b;
		getBlobsByTag("bulwark", @b);
		for(uint i = 0; i < b.length; i++)
		{
			if(b[i].getTeamNum() == team)
			{
				Bulwarks++;
			}
		}
	}
	
	if(Bulwarks < 1)
	{
		int randomTeam = 200+XORRandom(50);
		for(u8 i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if(p !is null && p.getTeamNum() == team)
			{
				p.server_setTeamNum(randomTeam);
				CBlob@ b = p.getBlob();
				if(b !is null)if(b.getTeamNum() == team)
				{
					b.server_setTeamNum(randomTeam);
				}
			}
		}
		
		CBlob@[] teamBlobs;	   
		getBlobsByName("stone_door", @teamBlobs);
		getBlobsByName("wooden_door", @teamBlobs);
		getBlobsByName("storage", @teamBlobs);
		getBlobsByName("quarry", @teamBlobs);
		getBlobsByName("spikes", @teamBlobs);
		getBlobsByName("trap_block", @teamBlobs);
		for (uint i = 0; i < teamBlobs.length; i++)
		{
			CBlob@ b = teamBlobs[i];
			if(b.getTeamNum() == team)
			{
				b.server_setTeamNum(-1);
			}
		}
		
		print("Team "+team+" has been disbanded due to have 0 bulwarks left.");
	} else {
		print("Team "+team+" has "+Bulwarks+" bulwarks left.");
	}

}