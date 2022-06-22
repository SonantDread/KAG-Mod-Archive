#include "SpareCode.as";
#include "RulesCore.as";


void onInit(CRules@ this) {

	this.addCommandID("update stats");
	this.addCommandID("update specific stats");
	this.addCommandID("update server stats");

	this.addCommandID("team balancing");
	this.addCommandID("teamElo updating");
	teamEloSet(this, "1000 1000");
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("update stats")){
		string updateMsg = params.read_string();
		CPlayer@ player = getPlayerByUsername(updateMsg.split("+")[0]); 
		string[] Stats = updateMsg.split("+")[1].split(" ");
		if (player !is null){

			updateStats(this, player, Stats);
		}
	}

	if(cmd == this.getCommandID("update specific stats")){
		//increase all stats by one
		string updateMsg = params.read_string();
		string playerName = updateMsg.split("+")[0];
		string statName = updateMsg.split("+")[1];
		int placeholder = this.get_u32(playerName + " " + statName);
;
		if (playerName != ""){
			print(playerName + " " + statName + ": " + placeholder + "//old");
			print(playerName + " " + statName + ": " + (placeholder + 1) + "//new");

			this.set_u32(playerName + " " + statName, placeholder + 1);
		}	
		else{
			tcpr("[USCaptains] " + statName + ": " + playerName);

		}
		
	}
	if(cmd == this.getCommandID("team balancing") && isServer()){
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

	if(cmd == this.getCommandID("teamElo updating") && isServer()){
		string updateMsg = params.read_string();
		teamEloSet(this, updateMsg);
	}

	if(cmd == this.getCommandID("update server stats")){
		string updateMsg = params.read_string();
		string playerName = updateMsg.split("+")[0];
		string statName = updateMsg.split("+")[1].split(" ")[0];
		int statNumber = parseInt(updateMsg.split("+")[1].split(" ")[1]);
		this.set_u32(playerName + " " + statName, statNumber);

	}
}
void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{    
    if(isServer())
    {
        CBitStream params;
        params.write_string(player.getUsername() + "+" + backendUpdate(this, player.getUsername()));
        this.SendCommand(this.getCommandID("update stats"), params, player);
    }
	tcpr("[USCaptains] Update: " + player.getUsername());
}


void updateStats(CRules@ this, CPlayer@ player, string[] Stats)
{
	print(player.getUsername() + ": " + Flatten(Stats));
	for(int i=0; i < checklist.size(); i++)
    {
        this.set_u32(player.getUsername() + " " + checklist[i], parseInt(Stats[i]));
        //this.Sync(checklist[i], true);
    }
}

void onTCPRConnect( CRules@ this ) {
	if (isServer()){
		print("tcpr connected");
		updateAll(this);
	}
}
void onPlayerLeave( CRules@ this, CPlayer@ player ){
	if(isServer()){

		if (player !is null)
		{
			print("[USCaptains] Left: " + player.getUsername());
		}
	}
}
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{

	if (victim !is null && isServer())
	{

		if(this.hasTag("Official") && this.isMatchRunning()){

			//print("[USCaptains] Deaths: " + victim.getUsername());
			specificStatUpdate(this, victim.getUsername(), "Deaths");	
			
			

			if (killer !is null)
			{
				if(killer.getTeamNum() != victim.getTeamNum())
				{
					//print("[USCaptains] Kills: " + killer.getUsername());
					specificStatUpdate(this, killer.getUsername(), "Kills");
				}
			}
			print(customData +"");
		}		
	}	
}
void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam ){
	if (isServer()){
		if (player !is null){
			if (this.hasTag("Official")){
				if (newteam != this.getSpectatorTeamNum()){
					print("[USCaptains] Teams: " + player.getUsername() + " " + newteam + "");
				}
				else{
					print("[USCaptains] Left: " + player.getUsername());	
				}

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

