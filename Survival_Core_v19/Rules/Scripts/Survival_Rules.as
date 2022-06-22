#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Health.as";
#include "MaterialCommon.as";
#include "GetPlayerData.as"

shared class Players
{ CTFPlayerInfo@[] list; Players(){} };

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(getRandomTeam());

	Players@ players;
	this.get("players", @players);
	players.list.push_back(CTFPlayerInfo(player.getUsername(),0,""));
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	player.server_setTeamNum(newteam);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if(blob !is null)
		blob.server_Die();

	Players@ players;
	this.get("players", @players);
	if(players !is null) {
		for(s8 i = 0; i < players.list.length; i++) {
			if(players.list[i] !is null && players.list[i].username == player.getUsername()) {
				players.list.removeAt(i);
				i--;
			}
		}
	}
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim is null)
		return;
	victim.set_u32("respawn time", 
		((victim.getTeamNum() >= 100 && victim.getTeamNum() <= 200) ?
		 (getGameTime() + (30*10)) : (getGameTime() + (30*7))));
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();

	if(gametime > 30)
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if(blob is null)// && player.get_u32("respawn time") <= getGameTime())
			{
				CBlob@ new_blob = server_CreateBlob(this.get_string("spawn_blob"));

				int team = player.getTeamNum();
				if(team >= 50) {
					team = getRandomTeam();
					player.server_setTeamNum(team);
				}
				
				int newPos = XORRandom(getMap().tilemapwidth) * getMap().tilesize;
				int newLandY = getMap().getLandYAtX(newPos / 8) * 8;

				Vec2f StartPos = Vec2f(newPos, newLandY - 8);
				
				CBlob@[] ruins;
				getBlobsByName("ruins", @ruins);
				
				if(ruins.length > 0){
					StartPos = ruins[XORRandom(ruins.length)].getPosition();		
				}
				
				if(team < 8)//if player is already on a team, then spawn him at one of his bases
				{
					CBlob@[] flag_bases;
					getBlobsByTag("bulwark", @flag_bases);
					Vec2f[] spawns;
					for(uint i = 0; i < flag_bases.length; i++)
					{
						CBlob@ flag_base = flag_bases[i];
						if(flag_base !is null && flag_base.getTeamNum() == team)
						{
							spawns.push_back(flag_base.getPosition());
						}
					}
					if(spawns.length > 0)StartPos = spawns[XORRandom(spawns.length)];
					
				}
				new_blob.setPosition(StartPos);
				new_blob.server_setTeamNum(team);
				new_blob.server_SetPlayer(player);
				
				deletePlayerLifeData(player);
				
				server_Heal(new_blob,100.0f);
				Material::createFor(new_blob,"coin",1);
			}
		}
	}
}

void onInit(CRules@ this)
{
	Reset(this);

	this.set_string("spawn_blob","builder");
	//print("File path:"+getFilePath("Survival_SpawnBlobs.as"));
	this.AddScript("Survival_SpawnBlobs.as");
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());

	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30*1));
			p.server_setTeamNum(getRandomTeam());
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}
	this.SetGlobalMessage("");
	this.set("players", @players);
	this.SetCurrentState(GAME);
}

int getRandomTeam()
{
	bool redo = true;
	int team = 100;
	while(redo){
		team = 100+XORRandom(100);
		redo = false;
		for(int i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if(player !is null){
				if(player.getTeamNum() == team)redo = true;
			}
		}
	}
	return team;
}