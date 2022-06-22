#include "Logging.as";

string[] checklist = {"Wins", "Losses", "Winning_Captain", "Losing_Captain", "Flags", "Kills", "Deaths", "Elo"}; 

int getStats( CRules@ this, string playerName, string SpecifiedStat)
{
	int StatNumber=0;
	if (isClient()){

		StatNumber = this.get_u32(playerName + " " + SpecifiedStat);
	}
	return StatNumber;


}


void setOffi( CRules@ this )
{
	if (!isServer()) { return; }
	if(this.hasTag("Official")){
		this.Untag("Official");
		this.Sync("Official", true);

		tcpr("[USCaptains] Wins: ");
		getNet().server_SendMsg( "Stopping official match" );
	}
	else{
		this.Tag("Official");
		this.Sync("Official", true);
		string[] BlueTeam;
		string[] RedTeam;
		for(int i=0; i < getPlayersCount(); i++)
		{
			CPlayer@ myplayer = getPlayer(i);
			if (myplayer !is null) {
				print(i+myplayer.getUsername()+myplayer.getTeamNum());
				if (myplayer.getTeamNum() == 0) {
			        BlueTeam.push_back(myplayer.getUsername());
			    }
			    else if (myplayer.getTeamNum() == 1) {
					RedTeam.push_back(myplayer.getUsername());
			    }
		   	}
		}
		//sets proper teams
		print("[USCaptains] Teams: " + Flatten(BlueTeam) + " 0" + "+" + Flatten(RedTeam) + " 1" );
		getNet().server_SendMsg( "Starting official match" );
		if(this.get_bool("can choose team")){
				lockteams( this );
		}
		//print("[USCaptains] Connect: ");
	}
}

int[] playerNumlist( CRules@ this){

    int[] orders;
    int team;
    for(int i=0; i < getPlayersCount(); i++)
    {
        orders.push_back(i);
    }
    return orders;
}



void lockteams( CRules@ this )
{
	if (isServer()){	
		if (this.get_bool("can choose team"))
		{
			this.set_bool("can choose team", false);
			this.Sync("can choose team", true);
			getNet().server_SendMsg( "swapping teams is disabled!" );
		}
		else
		{
			this.set_bool("can choose team", true);
			this.Sync("can choose team", true);
			getNet().server_SendMsg( "swapping teams is enabled!" );
		}
	}
}

shared void specificStatUpdate(CRules@ this, string playerName, string statName )
{
	CBitStream params;
    params.write_string(playerName + "+" + statName);
    this.SendCommand(this.getCommandID("update specific stats"), params);
}


void teamEloSet(CRules@ this, string teamEloNumbers)
{
	if (isServer()){
		this.set_string("teamElos", teamEloNumbers);
		this.Sync("teamElos", true);
	}
}

int[] teamEloGet(CRules@ this)
{
	
	int[] teamElos(2);
	string[] stringNumbers = this.get_string("teamElos").split(" ");
	for(int i=0; i < stringNumbers.size(); i++){
		teamElos[i] = parseInt(stringNumbers[i]);
	}
	return teamElos;
}




shared void officialMatchHandling(CRules@ this, int team){

	if(!isServer()){ return; }
	string[] checklist = {"Wins", "Losses", "Winning_Captain", "Losing_Captain", "Flags", "Kills", "Deaths", "Elo"};
	this.SetGlobalMessage("{WINNING_MSG} wins the game!");


	//declaring values and getting them with funcs
	string Winning_Captain = captGrab(this, Maths::Abs(team - 1));
	string Losing_Captain =  captGrab(this, team);
	//string[] WinningTeam = teamGrab(this, Maths::Abs(team - 1));
	//string[] LosingTeam = teamGrab(this, team);

	print("winner =" +Winning_Captain);

	if (Winning_Captain != "" && Losing_Captain != ""){
		//winMsg = Winning_Captain + " lead " + this.getTeam(Maths::Abs(team - 1)).getName();
		//specificStatUpdate(this, Winning_Captain, "Winning_Captain" );
		//specificStatUpdate(this, Losing_Captain, "Losing_Captain" );
		tcpr("[USCaptains] Winning_Captain: " + Winning_Captain);
		tcpr("[USCaptains] Losing_Captain: " + Losing_Captain);
		this.set_string("captain blue", "");
    	this.set_string("captain red", "");

	}
	tcpr("[USCaptains] Wins: " + Maths::Abs(team - 1) + "");

	//endGame Messages

	this.AddGlobalMessageReplacement("WINNING_MSG", this.getTeam(Maths::Abs(team - 1)).getName() + "");
	getNet().server_SendMsg( "Ending official match" );


	this.Untag("Official");
	this.Sync("Official", true);
	if(!this.get_bool("can choose team")){
		this.set_bool("can choose team", true);
		this.Sync("can choose team", true);
		getNet().server_SendMsg( "swapping teams is enabled!" );
	}

}

shared string captGrab(CRules@ this, int team){
	string stringName = "captain " + (team == 0 ? "blue" : "red");
	return this.get_string(stringName);
}

shared string[] teamGrab(CRules@ this, int team){
string[] Team;

for (u32 i=0; i < getPlayersCount(); i++)
	{	

		CPlayer@ myplayer = getPlayer(i);
		if(myplayer != null)
		{	
			if(myplayer.getTeamNum() == team)
			{
				Team.push_back(myplayer.getUsername());
			}
		}      
	}
    return Team;

}
shared string Flatten(string[]@ teamlist){
	string flatList;
	if (teamlist.size() >= 1) {
		flatList += teamlist[0] + ((teamlist.size() > 1) ? " " : "");
		for (uint i = 1; i < teamlist.size(); i++) {
			flatList += teamlist[i] + ((i < teamlist.size() - 1) ? " " : "");
		}
	}
		return flatList;
}
CPlayer@ GetPlayerByIdent(string ident) {
    // Takes an identifier, which is a prefix of the player's character name
    // or username. If there is 1 matching player then they are returned.
    // If 0 or 2+ then a warning is logged.
    ident = ident.toLower();
    log("GetPlayerByIdent", "ident = " + ident);
    CPlayer@[] matches; // players matching ident

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        string username = p.getUsername().toLower();
        string charname = p.getCharacterName().toLower();

        if (username == ident || charname == ident) {
            log("GetPlayerByIdent", "exact match found: " + p.getUsername());
            return p;
        }
        else if (username.find(ident) >= 0 || charname.find(ident) >= 0) {
            matches.push_back(p);
        }
    }

    if (matches.length == 1) {
        log("GetPlayerByIdent", "1 match found: " + matches[0].getUsername());
        return matches[0];
    }
    else if (matches.length == 0) {
        logBroadcast("GetPlayerByIdent", "Couldn't find anyone called " + ident);
    }
    else {
        logBroadcast("GetPlayerByIdent", "Multiple people are called " + ident + ", be more specific.");
    }

    return null;
}

void drawStatCard(CPlayer@ player, Vec2f pos)
{
	if(player!is null)
	{
		GUI::SetFont("menu");

		f32 stepheight = 8;
		Vec2f atopleft = pos;
		atopleft.x -= stepheight;
		atopleft.y -= stepheight*2;

		string statName;
        GUI::DrawPane(atopleft, Vec2f(atopleft.x + 180, (atopleft.y + (checklist.size() * 26))));
		GUI::DrawText(player.getUsername(), Vec2f(pos.x + 2, atopleft.y+10), SColor(0xffffffff));
		atopleft.y += 40;
		for (int i=0; i < checklist.size(); i++){
			if(i == 2 || i == 3){
				statName = (i == 2 ? "Capt Wins" : "Capt Losses");
			}
			else{
				statName = checklist[i];
			}
			GUI::DrawText(statName, Vec2f(pos.x + 2, (atopleft.y+(18*i))), SColor(0xffffffff));
			GUI::DrawText(getStats( getRules(), player.getUsername(), checklist[i])+"", Vec2f(pos.x + 110, atopleft.y+(18*i)), SColor(0xffffffff));
		}

	}

}

shared string statList(CRules@ this, string playerName){
	string stats;
	string[] checklist = {"Wins", "Losses", "Winning_Captain", "Losing_Captain", "Flags", "Kills", "Deaths", "Elo"};
	for(int i=0; i < checklist.size(); i++){
		stats += this.get_u32(playerName + " " + checklist[i]) + (i != (checklist.size() - 1) ? " " : "");
	}
	return stats;
}

shared void updateBackend( CRules@ this, string[] playerNames)
{
	for(int i=0; i < playerNames.size(); i++){
	tcpr("[USCaptains] updateBackend: " + playerNames[i] + "+" + statList(this, playerNames[i]));
	}
	tcpr("[USCaptains] updateBackend: " + "End");

}

shared string[] SharedStringList(string[] StringList){
	string[] SharedStringList = StringList;
	return SharedStringList;
}

