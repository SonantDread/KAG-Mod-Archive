#include "Logging.as";
#include "RulesCore.as";
#include "SpareCode.as";

const int TEAM_BLUE = 0;
const int TEAM_RED  = 1;

const SColor COLOR_BLUE(0xff0000ff);
const SColor COLOR_RED(0xffff0000);


void onInit(CRules@ this) {
    CaptainsReset(this);
    this.addCommandID("show cptmenu");

    this.addCommandID("captain menu");
    this.addCommandID("default nothing");

    if (!GUI::isFontLoaded("Bigger Font"))
        GUI::LoadFont("Bigger Font", "GUI/Fonts/AveriaSerif-Bold.ttf", 30, true);

}

void onRestart(CRules@ this) {
    CaptainsReset(this);
}

void onTick(CRules@ this) {

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


bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player) {
    // Handle !captains and !pick commands
    
    if(!getNet().isServer()) return true;

    string[]@ tokens = textIn.split(" ");
    int tl = tokens.length;
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
                if (this.get_bool("can choose team")){
                    lockteams(this);
                }
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

        else if(tokens[0] == "!forfeit" || tokens[0] == "!randompick" && player.isMod()){
            if(player.getUsername() == this.get_string("captain blue") || player.getUsername() == this.get_string("captain red")){
                u8 firstPick = (tokens[0] == "!forfeit" ? (XORRandom(2) == 0 ? TEAM_BLUE : TEAM_RED) : (player.getTeamNum() == 0 ? TEAM_RED : TEAM_BLUE));
                this.set_u8("first pick", firstPick);
                this.Sync("first pick", true);

                ExitFightPhase(this);
                StartPickPhase(this);

                sendMenu(this, captGrab(this, firstPick));

                getNet().server_SendMsg("Entering pick phase. First pick: " + (firstPick == TEAM_BLUE ? "Blue" : "Red"));
            }
        }
    }

    return true;
}	

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if(cmd == this.getCommandID("captain menu"))
    {
		if (isServer()){
	        string name;
	        u8 buttonID;

	         // basically useless but i thought maybe it would be useful for you to know which button was pressed instead of which "name was pressed"

	        if(!params.saferead_string(name)) return;
	        if(!params.saferead_u8(buttonID)) return;
	        CPlayer@ caller = getPlayerByUsername(name); 

	        if (caller is null) return;//is the received name a player ?



	        string propname = SELECTED + caller.getUsername(); /////////////////////////////////////////////////// NEWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
	        this.set_u8(propname, buttonID);
	        //you should add a if condition to check if the player is already in a team or not because the button don't delete itself after being clicked
	        //because kag's code to do so doesn't work (deleteAfterClick).

	        //put the code to put the player x in team y here

	        TryPickPlayer(this, caller, this.get_u8("team picking"));
	    }
	}

    if(cmd == this.getCommandID("show cptmenu"))
    {
        string playerName = params.read_string();
        CPlayer@ menuplayer = getPlayerByUsername(playerName);
        if (getLocalPlayer() !is null && menuplayer !is null){
            if (getLocalPlayer() is menuplayer){
                ShowCaptainMenu(menuplayer);
            }
        }
    }
}

void CaptainsReset(CRules@ this) {
    this.set_bool("can choose team", true);
    this.Sync("can choose team", true);
    this.set_bool("pick phase", false);
    this.set_bool("fight for first pick", false);
    this.set_u8("team picking", TEAM_BLUE);
    this.set_u8("first pick", TEAM_BLUE);
    this.set_string("captain blue", "");
    this.set_string("captain red", "");
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

void TryPickPlayer(CRules@ this, CPlayer@ player, int teamNum) {
    // Adds the player to the given team if they are currently spectating and can be picked
    if (player.getTeamNum() == this.getSpectatorTeamNum()) {
        // Don't allow picking of players already on teams
        ChangePlayerTeam(this, player, teamNum);

        string msg = (teamNum == TEAM_BLUE ? "Blue" : "Red") + " team picked " + player.getUsername();
        logBroadcast("TryPickPlayer", msg); 

    }
}


void ChangePlayerTeam(CRules@ this, CPlayer@ player, int teamNum) {
    RulesCore@ core;
    this.get("core", @core);
    core.ChangePlayerTeam(player, teamNum);
}


void StartPickPhase(CRules@ this) {
//    log("StartPickPhase", "Starting pick phase!");
	this.set_u8("team picking", this.get_u8("first pick"));
	this.Sync("team picking", true);
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

void ExitFightPhase(CRules@ this){
    this.set_bool("fight for first pick", false);
    this.Sync("fight for first pick", true);
}



void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){
    if (this.get_bool("fight for first pick") && this.get_s32("timer") == 0 && killer !is null)
    {
        if(getNet().isServer()){
            this.set_u8("first pick", Maths::Abs(victim.getTeamNum() - 1));
            this.Sync("first pick", true);
            ExitFightPhase(this);
            StartPickPhase(this);
            getNet().server_SendMsg(killer.getUsername() + " won the fight!");
            sendMenu(this, killer.getUsername());
        }
    }

    if (getNet().isServer() && this.get_bool("pick phase") && captGrab(this, this.get_u8("team picking")) == victim.getUsername()){
        sendMenu(this, victim.getUsername());
    }
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam ){

    if(this.get_bool("pick phase")) // changed from Ontick to changeteam hook
    {

        if (getPlayerCount() == 0 || CountPlayersInTeam(this.getSpectatorTeamNum()) == 0) {
            ExitPickPhase(this);
        }
        else{
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
            sendMenu(this, captGrab(this, teamPicking));

        }
    }
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
    if (blob !is null && player !is null)
    { 
	print(player.getUsername() + "not nulls");
        if (getPlayerByUsername(captGrab(this, this.get_u8("team picking"))) is player && this.get_bool("pick phase"))
        {
		print(player.getUsername() + "menuTimeRespawn");
            sendMenu(this, player.getUsername());
        }
    }
}
