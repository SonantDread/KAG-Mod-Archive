
#include "Default/DefaultLoaders.as"

void Configure()
{
    v_driver = 0;  // disable video
    s_soundon = 0; // disable audio
}

void InitializeGame()
{
    sv_gamemode = "CTF";
    sv_test = 0;
    
    sv_maxplayers = 16;
    sv_enable_joinfull = 1;
    sv_reservedslots = 1;
    // sv_rconpassword = "";
    sv_allow_globals_mods = 0;
    
    sv_maxping = 500;
    sv_maxping_warnings = 1200;
    sv_pingkick_time = 20;
    
    sv_maxhack_warnings = 50;
    sv_global_bans = 0;
    sv_freezeban_time = 0;
    sv_verify_mods = 0;
    
    print("Initializing Game Script");
    LoadDefaultMapLoaders();
    
    if (getNet().CreateServer())
    {
        LoadRules("Rules/" + sv_gamemode + "/gamemode.cfg");
        
        if (sv_mapcycle.size() > 0)
        {
            LoadMapCycle(sv_mapcycle);
        }
        else
        {
            LoadMapCycle("Rules/" + sv_gamemode + "/mapcycle.cfg");
        }
        
        LoadNextMap();
    }
}