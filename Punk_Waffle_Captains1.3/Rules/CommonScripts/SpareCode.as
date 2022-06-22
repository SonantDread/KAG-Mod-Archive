#include "Logging.as";

string[] checklist = {"Wins", "Losses", "Winning_Captains", "Losing_Captain", "Flags", "Kills", "Deaths", "Elo"};

int getStats( CRules@ this, CPlayer@ Player, string SpecifiedStat)
{
	dictionary PlayerDict;
	int StatNumber;
	Player.get("PlayerStatistics", PlayerDict);
	PlayerDict.get(SpecifiedStat, StatNumber);
	return StatNumber;
}


void setOffi( CRules@ this )
{
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

int GetStats( CRules@ this, CPlayer@ Player, string SpecifiedStat)
{
	dictionary PlayerDict;
	int StatNumber;
	Player.get("PlayerStatistics", PlayerDict);
	PlayerDict.get(SpecifiedStat, StatNumber);
	print(StatNumber + "");
	return StatNumber;
}


void lockteams( CRules@ this )
{
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

void specificStatUpdate(CRules@ this, CPlayer@ player, string statName )
{
	dictionary PStats;
	int placeholder;
	player.get("PlayerStatistics", PStats);
	PStats.set(statName, (getStats(this, player, statName) + 1));
	player.set("PlayerStatistics", PStats);	
}

void teamElo(CRules@ this, string[] teamEloNumbers)
{
	int[] teamElos(2);
	if (teamEloNumbers.size() == 2){
		for(int i=0; i < teamEloNumbers.size(); i++){
			teamElos[i] = (parseInt(teamEloNumbers[i]));
		}
			print("working");

		this.set("teamElos", teamElos);
	}
}



shared void officialMatchHandling(CRules@ this, int team){
	
	print('tagged');
	this.SetGlobalMessage("{WINNING_MSG} wins the game!");


	//declaring values and getting them with funcs
	string Winning_Captain = captGrab(this, Maths::Abs(team - 1));
	string Losing_Captain =  captGrab(this, team);
	string[] WinningTeam = teamGrab(this, Maths::Abs(team - 1));
	string[] LosingTeam = teamGrab(this, team);

	//tcprmsgs
	
	tcpr("[USCaptains] Wins: " + Maths::Abs(team - 1) + "");
	//tcpr("[USCaptains] Losses: " + Flatten(LosingTeam));
	//tcpr("[USCaptains] endGame: " + Maths::Abs(team - 1) + "");
	if (Winning_Captain != "" && Losing_Captain != ""){
		//winMsg = Winning_Captain + " lead " + this.getTeam(Maths::Abs(team - 1)).getName();
		tcpr("[USCaptains] Winning_Captain: " + Winning_Captain);
		tcpr("[USCaptains] Losing_Captain: " + Losing_Captain);
	}
	//endGame Messages

	this.AddGlobalMessageReplacement("WINNING_MSG", Maths::Abs(team - 1) + "");
	getNet().server_SendMsg( "Ending official match" );


	CBitStream params;
	this.SendCommand(this.getCommandID('update all'), params);

	this.Untag("Official");

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

const string SELECTED = "selected : ";

void ShowCaptainMenu(CPlayer@ player)
{
    if(isClient()){
    	if(getLocalPlayer() is player){
    		print(player.getUsername() + "menuTimeRespawn");

			CRules@ rules = getRules();
			
			string[] playerNameList;
			for (int i = 0; i < getPlayerCount(); i++){
				CPlayer@ myplayer = getPlayer(i);
				if (myplayer.getTeamNum() == rules.getSpectatorTeamNum()){
					playerNameList.push_back(myplayer.getUsername());
				}
			}


			getHUD().ClearMenus(true);

			//hide main menu and other gui
			u8 MENU_WIDTH = 4;
		 	u8 MENU_HEIGHT = playerNameList.size() / 2 + playerNameList.size() % 2;


			Vec2f center = Vec2f(178, 350);
			string description = getTranslatedString("Pick List");
			CGridMenu@ menu = CreateGridMenu(center, null, Vec2f(MENU_WIDTH, MENU_HEIGHT), description);
			if (menu !is null)
			{
				menu.modal = true;
				menu.deleteAfterClick = true;


				if (menu.getButtonsCount() % MENU_WIDTH != 0)
				{
					menu.FillUpRow();
				}

				string propname = SELECTED + player.getUsername();
		        u8 selected = rules.get_u8(propname);
		        string statCard = "PLayerStats\n\n";
		        string statName;
				for (int i = 0; i < playerNameList.size(); ++i)
				{
					CBitStream params;

					params.write_string(playerNameList[i]);
					params.write_u8(i);
					
					CGridButton@ txtButton = menu.AddTextButton(playerNameList[i], rules.getCommandID("captain menu"), Vec2f(MENU_WIDTH/2, 1), params);
					for (int b; b < checklist.size(); b++){
						if(b == 2 or b == 3){
							statName = (b == 3 ? "Capt Wins" : "Capt Losses");
						}
						else{
							statName = checklist[b];
						}
						statCard += statName + " " + getStats( getRules(), getPlayerByUsername(playerNameList[i]), checklist[b])+"\n";
					}
					print("it gets to here0");
					if (txtButton !is null)
					{
						txtButton.clickable = true; // set this to false for non captain player
						txtButton.SetEnabled(true);
						txtButton.hoverText = statCard;
					}
					if (i == 0){
						menu.SetDefaultCommand(rules.getCommandID("default nothing"), params);

					}
					print("it gets to here1");

				}
			}
		}
	}
}

void sendMenu(CRules@ this, string username){
    CBitStream params;

    params.write_string(username);
    this.SendCommand(this.getCommandID("show cptmenu"), params, true);
}