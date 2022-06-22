#include "SpareCode.as";
#include "RulesCore.as";


void onInit(CRules@ this) {

	this.addCommandID("update stats");
	this.addCommandID("update specific stats");
	this.addCommandID("team balancing");
	this.addCommandID("teamElo updating");

	dictionary dict;

	for(int i=0; i < checklist.size(); i++)
	{
	    dict.set(checklist[i], ((i < checklist.size() - 1) ? 1 : 1000));
	}
	this.set("DefaultDict", dict);
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("update stats")){
		string updateMsg = params.read_string();
		CPlayer@ player = getPlayerByUsername(updateMsg.split("+")[0]); 
		string[] Stats = updateMsg.split("+")[1].split(" ");
		if (player !is null){
			dictionary PStats;

			player.get("PlayerStatistics", PStats);
			for(int i=0; i < checklist.size(); i++){

		        PStats.set(checklist[i], parseInt(Stats[i]));
		    }
			player.set("PlayerStatistics", PStats);
		}
	}
	if(cmd == this.getCommandID("team balancing")){
		RulesCore@ core;
		this.get("core", @core);
		string updateMsg = params.read_string();
		print(updateMsg);
		string[] players = updateMsg.split("+")[0].split(" "); 
		int teamNum = parseInt(updateMsg.split("+")[1]);
		print(players.size() + "");
		for(int i=0; i < players.size(); i++){
			CPlayer@ player = getPlayerByUsername(players[i]);
			if (player !is null){
				core.ChangePlayerTeam(player, teamNum);
			}
		}
	}
	/*if(cmd == this.getCommandID("update all")){
		string[] playerList;
		for(int i=0; i < getPlayerCount(); i++){
			CPlayer@ player = getPlayer(i);
			if (player !is null){
				playerList.push_back(player.getUsername());
			}
		}
		print("[USCaptains] Update: " + Flatten(playerList));
	}*/
	if(cmd == this.getCommandID("teamElo updating")){
		string updateMsg = params.read_string();
		teamElo(this, updateMsg.split(" "));
	}
}
void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{	
	retrieveStats(this, player);	
}

void retrieveStats(CRules@ this, CPlayer@ player )
{
	dictionary dict;
	int placeholder;
	this.get("DefaultDict", dict);

	for(int i=0; i < checklist.size(); i++)
	{
		dict.get(checklist[i], placeholder);
		print(checklist[i] + ": " + placeholder);
	}
	player.set("PlayerStatistics", dict);
	tcpr("[USCaptains] Update: Join " + player.getUsername());
}


void updateStats(CRules@ this, CPlayer@ player, int[] Stats)
{
	dictionary PStats;
	player.get("PlayerStatistics", PStats);
	for(int i=0; i < checklist.size(); i++)
    {
        PStats.set(checklist[i], Stats[i]);
    }
	player.set("PlayerStatistics", PStats);
}
void onTCPRConnect( CRules@ this ) {
	print("tcpr connected");
	updateAll(this);
}
void onPlayerLeave( CRules@ this, CPlayer@ player ){


	if (player !is null)
	{
		print("[USCaptains] Left: " + player.getUsername());
	}

}
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	print("le check");

	if (victim !is null)
	{

		if(this.hasTag("Official") && this.isMatchRunning()){

			print("[USCaptains] Deaths: " + victim.getUsername());
			specificStatUpdate(this, victim, "Deaths");	
			if (killer !is null)
			{
				if(killer.getTeamNum() != victim.getTeamNum())
				{
					print("[USCaptains] Kills: " + killer.getUsername());
					specificStatUpdate(this, killer, "Kills");
				}
			}
		}		
	}	
}
void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam ){
	if (player !is null){
		if (this.hasTag("Official")){
			if (newteam != this.getSpectatorTeamNum()){
				print("[USCaptains] Team: " + player.getUsername() + " " + newteam + "");
			}
			else{
				print("[USCaptains] Left: " + player.getUsername());	
			}

		}
	}
}
void updateAll( CRules@ this ){
	string[] playerList;
	for(int i=0; i < getPlayerCount(); i++){
		CPlayer@ player = getPlayer(i);
		if (player !is null){
			playerList.push_back(player.getUsername());
		}
	}
	print("[USCaptains] Update: " + Flatten(playerList));
}