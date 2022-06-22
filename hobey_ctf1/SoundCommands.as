
#include "RulesCore.as";
#include "Logging.as"

string commandsoundslocation = "../Mods/hobey_ctf1/CommandSounds/";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
    RulesCore@ core;
    this.get("core", @core);
    
    return true;
}


bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
    if (player is null) return true;
    CPlayer@ localplayer = getLocalPlayer();
    
    if (player is localplayer) {
        string[]@ tokens = text_in.split(" ");
        u8 tlen = tokens.length;
        
        if (tokens[0] == "!mute" && tlen >=2)
        {
            string targetIdent = tokens[1];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
            if (target != null)
            {
                this.set_bool(target.getUsername() + "is_muted", true);
            }
        }
        
        else if (tokens[0] == "!unmute" && tlen >=2)
        {
            string targetIdent = tokens[1];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
            if (target != null)
            {
                this.set_bool(target.getUsername() + "is_muted", false);
            }
        }
        if (text_in == "!muteall")
        {
            this.set_bool("muteall", true);
        }
        
        else if (text_in == "!unmuteall")
        {
            this.set_bool("muteall", false);
        }
    }
    
    bool soundplayed = false;
    bool player_is_muted = this.get_bool(player.getUsername() + "is_muted");
    bool muteall = this.get_bool("muteall");
    u32 time_since_last_sound_use = getGameTime() - this.get_u32(player.getUsername() + "lastsoundplayedtime");
    u32 soundcooldown = this.get_u32(player.getUsername() + "soundcooldown");
    
    // Sounds that can be heard only by teammates (you dont need to be alive to use those)
    
    if (player_is_muted == false && localplayer.getTeamNum() == player.getTeamNum() && time_since_last_sound_use >= soundcooldown)
    {
        if (text_in == "ez 1vfasfafasfafasfafsfa12"  || text_in == "!p2 edfasfsagafasfaz1v1")
        {
            if (muteall == false)
            {
                Sound::Play(commandsoundslocation + "conniptions.ogg");
            }
            this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
            this.set_u32(player.getUsername() + "soundcooldown", 45);
        }
    }
    
    
    // Taunts (player needs to be alive, can be heard by anyone)
    
    CBlob@ blob = player.getBlob();
    
    if (blob is null) {
        return true;
    }
    
    Vec2f pos = blob.getPosition();
    
    if (player_is_muted == false && time_since_last_sound_use >= soundcooldown)
    {
        if (text_in == "gives me conniptions"  || text_in == "conniptions")
        {
            if (muteall == false)
            {
                Sound::Play(commandsoundslocation + "conniptions.ogg", pos);
            }
            this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
            this.set_u32(player.getUsername() + "soundcooldown", 45);
        }
        else if (text_in == "TUTURU" || text_in == "Tuturu!" || text_in == "tuturu" || text_in == "Tuturu" || text_in == "TU TU RU" || text_in == "tu tu ru" || text_in == "tutturu")
        {
            if (muteall == false)
            {
                int random = XORRandom(9) + 1;
                Sound::Play(commandsoundslocation + "Tuturu" + random + ".ogg", pos);
            }
            this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
            this.set_u32(player.getUsername() + "soundcooldown", 45);
        }
        else if (text_in == "poggers" || text_in == "POGGERS" || text_in == "pog")
        {
            if (muteall == false)
            {
                Sound::Play(commandsoundslocation + "poggers.ogg", pos);
            }
            this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
            this.set_u32(player.getUsername() + "soundcooldown", 45);
        }
    }
    
    return true;
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