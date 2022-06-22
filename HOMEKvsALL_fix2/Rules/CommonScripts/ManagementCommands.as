#include "Logging.as"
#include "RulesCore.as"

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
    string[]@ tokens = textIn.split(" ");
    int tlen = tokens.size();

    if (tokens[0] =="!blue" && tlen>=2 && player.isMod()) 
    {
        for (int i = 1; i < tokens.size(); i++)
        {
            string targetIdent = tokens[i];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
            if(target != null)
            {
                ChangePlayerTeam(this, target, 0);
            }
        }
    }
    else if (tokens[0] == "!red" && tlen >= 2 && player.isMod())
    {
        for (int i = 1; i < tokens.size(); i++)
        {
            string targetIdent = tokens[i];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
            if(target != null)
            {
                ChangePlayerTeam(this, target, 1);
            }
        }
    }
    else if (tokens[0] == "!spec" && tlen >= 2 && player.isMod())
    {
        for (int i = 1; i < tokens.size(); i++)
        {
            string targetIdent = tokens[i];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
            if(target != null)
            {
                ChangePlayerTeam(this, target, this.getSpectatorTeamNum());
            }
        }
    }
    else if (tokens[0] == "!settickets")
    {
        if (tokens[1] != "~")
        {
            s16 tickets = Maths::Max(0, parseInt(tokens[1]));
            this.set_s16("blueTickets", tickets);
            this.Sync("blueTickets", true);
        }
        if (tokens[2] != "~")
        {
            s16 tickets = Maths::Max(0, parseInt(tokens[2]));
            this.set_s16("redTickets", tickets);
            this.Sync("redTickets", true);
        } 
    }

    return true;
}

void ChangePlayerTeam(CRules@ this, CPlayer@ player, int teamNum) {
    RulesCore@ core;
    this.get("core", @core);
    core.ChangePlayerTeam(player, teamNum);
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