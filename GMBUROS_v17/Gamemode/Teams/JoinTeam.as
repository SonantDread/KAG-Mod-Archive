

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || !getNet().isServer()) return;

	CPlayer@ p = blob.getPlayer();
	if(p is null)return;
	
	int team = this.getTeamNum();
	
	//print("Num in team:"+getNumInTeam(team));
	//print("Max in team:"+getMaxPerTeam(team));

	if(getNumInTeam(team) < getMaxPerTeam(team))
	if (blob.getTeamNum() >= 20 && p.getTeamNum() >= 20)
	{
		if (getNet().isServer())
		{	
			p.server_setTeamNum(team);
			blob.server_setTeamNum(team);
		}
		return;
	}

}


int getNumInTeam(int team)
{
	int amount = 0;
	for(int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null){
			if(player.getTeamNum() == team)amount++;
		}
	}
	return amount;
}

int getMaxPerTeam(int team)
{
	int amount = 0;
	string types = "";
	
	CBlob@[] bulwarks;
	getBlobsByTag("bulwark", @bulwarks);
	for(uint i = 0; i < bulwarks.length; i++)
	{
		CBlob@ bulwark = bulwarks[i];
		if(bulwark !is null && bulwark.getTeamNum() == team)
		if(types.find(bulwark.getName()) < 0){
			amount++;
			types += bulwark.getName();
		}
	}
	
	return amount*2;
}