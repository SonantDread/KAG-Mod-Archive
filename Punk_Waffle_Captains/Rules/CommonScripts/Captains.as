#include "Logging.as";
#include "RulesCore.as";

const int TEAM_BLUE = 0;
const int TEAM_RED  = 1;

const SColor COLOR_BLUE(0xff0000ff);
const SColor COLOR_RED(0xffff0000);


void onInit(CRules@ this) {
    CaptainsReset(this);
    if (!GUI::isFontLoaded("Bigger Font"))
        GUI::LoadFont("Bigger Font", "GUI/Fonts/AveriaSerif-Bold.ttf", 30, true);

}

void onRestart(CRules@ this) {
    CaptainsReset(this);
}

void onTick(CRules@ this) {
    /*
    log("onTick", "pick phase: " + this.get_bool("pick phase") + 
            ", team picking: " + this.get_u8("team picking"));
    */
    if (getPlayerCount() == 0 || CountPlayersInTeam(this.getSpectatorTeamNum()) == 0) {
        ExitPickPhase(this);
    }
    else if (this.get_bool("pick phase")) {
        // Set the team that's picking
        int teamPicking;
        int blueCount = CountPlayersInTeam(TEAM_BLUE);
        int redCount = CountPlayersInTeam(TEAM_RED);

        if (blueCount == redCount) {
            teamPicking = this.get_u8("first pick");
        }
        else {
            teamPicking = blueCount < redCount ? TEAM_BLUE : TEAM_RED;
        }

        //log("onTick", "Set team picking to " + teamPicking);
        this.set_u8("team picking", teamPicking);
        this.Sync("team picking", true);
    }

    if (getNet().isServer() && this.get_bool("fight for first pick") && this.get_s32("timer") != 0) {
        s32 TimeLeft = this.get_s32("timer") - getGameTime();
        if (TimeLeft <= 0) {
            this.set_s32("timer", 0);
            this.Sync("timer", true);

            this.SetCurrentState(GAME);
            getNet().server_SendMsg("Fight for first pick!");
        }
    }
}

void onRender(CRules@ this) {
    if (this.get_bool("pick phase") && this.exists("team picking")) {
        // Draw interface
        u8 teamPicking = this.get_u8("team picking");

        Vec2f topLeft(100,200);
        Vec2f padding(4, 4);
        Vec2f endPadding(6, 0);
        string msg = (teamPicking == TEAM_BLUE ? "Blue" : "Red") + " team is picking";
        Vec2f textDims;
        GUI::SetFont("menu");
        GUI::GetTextDimensions(msg, textDims);
        GUI::DrawPane(topLeft, topLeft + textDims + padding*2 + endPadding);
        GUI::DrawText(msg, topLeft+padding, teamPicking == TEAM_BLUE ? COLOR_BLUE : COLOR_RED);
    }

    if (this.get_bool("fight for first pick"))
    {
        string msg = "Fight for first pick!";

        if (this.get_s32("timer") != 0)
        {
            s32 TimeLeft = (this.get_s32("timer") - getGameTime());
            msg = (TimeLeft / 30 + 1) + " seconds until fight!";
        }

        Vec2f Mid(getScreenWidth() / 2, getScreenHeight() * 0.2);
        Vec2f textDims;
        GUI::SetFont("Bigger Font");
        GUI::GetTextDimensions(msg, textDims);
		GUI::DrawTextCentered(msg, Mid, COLOR_RED);
	}
}

/*void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    if(getNet().isServer())
    {
        this.Sync("pick phase", true);
        this.Sync("team picking", true);
        this.Sync("timer", true);
        this.Sync("fight for first pick", true);
    }
}*/

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    // Handle !captains and !pick commands
    
    if(!getNet().isServer()) return true;

    string[]@ tokens = textIn.split(" ");
    int tl = tokens.length;
    string[]@ BlueTeam;
	string[]@ RedTeam;
	this.get("blues", @BlueTeam);
	this.get("reds", @RedTeam);
    if (tl > 0) {
        if ( player.isMod() && tokens[0] == "!captains" && tl >= 3) {
            CPlayer@ captain_blue = GetPlayerByIdent(tokens[1]);
            CPlayer@ captain_red  = GetPlayerByIdent(tokens[2]);
            if (captain_blue is null || captain_red is null) {
                log("onServerProcessChat", "One of the given captain names was invalid.");
            }
            else
            {
                // Set all relevant teams in one go
                RulesCore@ core;
                this.get("core", @core);

                int specTeam = this.getSpectatorTeamNum();

                for(int i = 0; i < getPlayerCount(); i++)
                {
                    CPlayer@ player = getPlayer(i);
                    if(player is captain_blue){
                        core.ChangePlayerTeam(player, TEAM_BLUE);
                        this.set_string("captain blue", player.getUsername());
                    }
                    else if(player is captain_red){
                        core.ChangePlayerTeam(player, TEAM_RED);
                        this.set_string("captain red", player.getUsername());
                    }
                    else{
                        core.ChangePlayerTeam(player, specTeam);
                    }
                }
                
                ExitPickPhase(this);
                StartFightPhase(this);
            }
        }
        else if (tokens[0] == "!pick" && tl >= 2) {
        	if (this.get_bool("pick phase")) {
	            u8 teamPicking = this.get_u8("team picking");
	            CPlayer@ captain_blue = getPlayerByUsername(this.get_string("captain blue"));
	            CPlayer@ captain_red  = getPlayerByUsername(this.get_string("captain red"));
	            if (captain_blue is null || captain_red is null) {
	                logBroadcast("onServerProcessChat", 
	                        "ERROR: in pick phase but a captain is null; exiting pick phase.");
	                ExitPickPhase(this);
	            }
	            else if (player is captain_blue && teamPicking == TEAM_BLUE ||
	                        player is captain_red && teamPicking == TEAM_RED) {
	                string targetIdent = tokens[1];
	                CPlayer@ target = GetPlayerByIdent(targetIdent);
	                if (target !is null) {
	                    TryPickPlayer(this, target, player.getTeamNum());
	                }
	            }
	        }
	        if(this.hasTag("Official")){
	        	string[]@ TargetTeam;
	        	string targetIdent = tokens[1];
	        	this.get((player.getTeamNum() == 0 ? "blues": "reds"), @TargetTeam);
	            CPlayer@ target = GetPlayerByIdent(targetIdent);
	        	if (target !is null) {
		        	TargetTeam.push_back(target.getUsername());
		        	this.set((player.getTeamNum() == 0 ? "blues" : "reds"), TargetTeam); 
		        }
	        }
	        if (player is getPlayerByUsername(this.get_string("captain blue"))|| player is getPlayerByUsername(this.get_string("captain red"))) {
	        	if (!this.get_bool("pick phase") && !this.get_bool("fight for first pick")) {
		            string targetIdent = tokens[1];
		            CPlayer@ target = GetPlayerByIdent(targetIdent);
		            if (target !is null) {
		                TryPickPlayer(this, target, player.getTeamNum());
		            }
		        }
	        }
        }
        else if(tokens[0] == "!randompick" && player.isMod() && !this.get_bool("fight for first pick")){
            u8 firstPick = XORRandom(2) == 0 ? TEAM_BLUE : TEAM_RED;
            this.set_u8("first pick", firstPick);
            this.Sync("first pick", true);
            getNet().server_SendMsg("Entering pick phase. First pick: " + (firstPick == TEAM_BLUE ? "Blue" : "Red"));
        }
        else if(tokens[0] == "!forfeit"){
            if(player.getUsername() == this.get_string("captain blue") || player.getUsername() == this.get_string("captain red")){
                u8 firstPick = player.getTeamNum() == 0 ? TEAM_RED : TEAM_BLUE;
                this.set_u8("first pick", firstPick);
                this.Sync("first pick", true);
                this.set_bool("fight for first pick", false);
                this.Sync("fight for first pick", true);
                StartPickPhase(this);
                getNet().server_SendMsg("Entering pick phase. First pick: " + (firstPick == TEAM_BLUE ? "Blue" : "Red"));
            }
        }
    }

    return true;
}	


void CaptainsReset(CRules@ this) {
    this.set_bool("can choose team", true);
    this.set_bool("pick phase", false);
    this.set_bool("fight for first pick", false);
    this.set_u8("team picking", TEAM_BLUE);
    this.set_u8("first pick", TEAM_BLUE);
    this.set_s32("timer", 0);
}

int CountPlayersInTeam(int teamNum) {
    int count = 0;

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        if (p.getTeamNum() == teamNum)
            count++;
    }

    return count;
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

void TryPickPlayer(CRules@ this, CPlayer@ player, int teamNum) {
    // Adds the player to the given team if they are currently spectating and can be picked
    if (player.getTeamNum() == this.getSpectatorTeamNum()) {
        // Don't allow picking of players already on teams
        ChangePlayerTeam(this, player, teamNum);

        string msg = (teamNum == TEAM_BLUE ? "Blue" : "Red") + " team picked " + player.getUsername();
        logBroadcast("TryPickPlayer", msg); 
    }
}

/*void ForceAllToSpectate(CRules@ this) {
    int specTeam = this.getSpectatorTeamNum();

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null || p.getTeamNum() == specTeam) continue;
        ChangePlayerTeam(this, p, specTeam);
    }
}*/

void ChangePlayerTeam(CRules@ this, CPlayer@ player, int teamNum) {
    RulesCore@ core;
    this.get("core", @core);
    core.ChangePlayerTeam(player, teamNum);
}

/*void SetBlueCaptain(CRules@ this, CPlayer@ capn) {
    log("SetBlueCaptain", "Setting captain to: " + capn.getUsername());
    this.set_string("captain blue", capn.getUsername());
    ChangePlayerTeam(this, capn, TEAM_BLUE);
}

void SetRedCaptain(CRules@ this, CPlayer@ capn) {
    log("SetRedCaptain", "Setting captain to: " + capn.getUsername());
    this.set_string("captain red", capn.getUsername());
    ChangePlayerTeam(this, capn, TEAM_RED);
}*/

void StartPickPhase(CRules@ this) {
//    log("StartPickPhase", "Starting pick phase!");
    this.set_bool("pick phase", true);
    this.Sync("pick phase", true);
}
void StartFightPhase(CRules@ this) {
    if( this.get_s16("redTickets") <= 0 || this.get_s16("blueTickets") <=0)
    {
        this.set_s16("redTickets", 10);
        this.set_s16("blueTickets", 10);
        this.Sync("redTickets", true);
        this.Sync("blueTickets", true);
    }
    this.set_bool("fight for first pick", true);
    this.set_s32("timer", getGameTime() + 360);
    this.Sync("timer", true);
    this.Sync("fight for first pick", true);
    

}
void ExitPickPhase(CRules@ this) {
//    log("StartPickPhase", "Starting pick phase!");
    this.set_bool("pick phase", false);
    this.Sync("pick phase", true);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){
    if (getNet().isServer() && this.get_bool("fight for first pick") && this.get_s32("timer") == 0 && killer !is null)
    {
    	string[] teams = { "Blue", "Red" };
        this.set_u8("first pick", Maths::Abs(victim.getTeamNum() - 1));
        this.Sync("first pick", true);
        this.set_bool("fight for first pick", false);
        this.Sync("fight for first pick", true);
        StartPickPhase(this);

        getNet().server_SendMsg(this.get_string("captain " + teams[Maths::Abs(victim.getTeamNum() - 1)].toLower() + "") + " won the fight!");
    }
}
