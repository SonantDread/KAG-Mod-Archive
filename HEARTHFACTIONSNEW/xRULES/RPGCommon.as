//RPGCommon.as

#include "Factions.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "CTF_Structs.as";
#include "Rules/CommonScripts/BaseTeamInfo.as";

shared class RPGRespawns : RespawnSystem
{
	s16[] used;

    RPGCore@ c;

    CRules@ rules;

    CTFPlayerInfo@[] spawns;

    RPGRespawns(CRules@ _rules)
    {
        super();
        @rules = _rules; 
    }

    void SetCore(RulesCore@ _core)
    {
        RespawnSystem::SetCore(_core);
        @c = cast < RPGCore@ > (core); 
    }
    void Update()
    {
        for (uint i = 0; i < spawns.length; i++)
        {
            CTFPlayerInfo@ info = cast <CTFPlayerInfo@> (spawns[i]);

            if(info !is null)
            {
                DoSpawnPlayer(info); 
            }
        }
    }
    void AddPlayerToSpawn(CPlayer@ player)
    {
        CTFPlayerInfo@ info = cast <CTFPlayerInfo@> (core.getInfoFromPlayer(player));

        if (info is null) 
        { 
            return;  
        }

        RemovePlayerFromSpawn(info);
        
        if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
        {
            return;  
        }

        spawns.push_back(info); 
    }
    void RemovePlayerFromSpawn(CTFPlayerInfo@ p_info)
    {
        if (p_info is null) 
        { 
            return; 
        }

        for(int i = 0; i < spawns.length; i++)
        {
            CTFPlayerInfo@ info = cast <CTFPlayerInfo@> (spawns[i]);
            if(info is p_info)
            {
                spawns.removeAt(i);
                i--;
            }
        } 
    }
    void DoSpawnPlayer(CTFPlayerInfo@ p_info)
    {
        if(canSpawnPlayer(p_info))
        {
            CPlayer@ player = getPlayerByUsername(p_info.username);

            if (player is null)
            {
                return;
            }
            
            Respawn(rules, player);
            RemovePlayerFromSpawn(player); 
        }
    }
    bool canSpawnPlayer(CTFPlayerInfo@ p_info)
    {
        if (p_info is null)
        {
            return false; 
        }

        CPlayer@ p = getPlayerByUsername(p_info.username);

        if (p is null)
        {
            return false;
        }

        if (!isSpawning(p))
        {
            return false;
        }

        int x;
        p.get("lsr", x);

        bool sp = p_info.lastSpawnRequest > x + getTicksASecond()*(p.getTeamNum() == 7 ? 1 : 15);

        if(sp)
        {
            RemovePlayerFromSpawn(p);
            p.set("lsr", p_info.lastSpawnRequest);
            return true;
        }
        else
        {
            p_info.lastSpawnRequest = getGameTime();
        }

        return false;
    }
    CBlob@ Respawn( CRules@ _rules, CPlayer@ player )
    {
        if (player !is null)
        {
            CBlob@ blob = player.getBlob();         

            Factions@ f;
            _rules.get("factions", @f);

            RPGCore@ rc;
            _rules.get("core", @rc);

            s8 team = -1;
            
            string Class = "peasant"; //MIGRANT
            Vec2f spawnloc = getSpawnLocation(player);

            Faction@ target = f.getFactionByMemberName(player.getUsername());
            if(target !is null)
            {   
                team = target.getTeamNum();
                Class = "peasant";
                spawnloc = getBaseLocation(team);
				if((target.name).get_length() == 46)//If this is a slave faction        ~Numan was here
				{
					if(spawnloc != Vec2f(0,0))
					{
						Class = "slave"; 
					}
					else
					{
						print("some slaves should of left their team at this point");
						//REMOVE ALREADY!! 		~Numan
						CBitStream params;
						params.write_u8(target.team);
						_rules.SendCommand(_rules.getCommandID("killFaction"), params);
						//rc.ChangePlayerTeam(player, -1);
						
						spawnloc = getSpawnLocation(player);
					}
					team = -1;
					
				}
			}
			
			
	    
			CBlob@ newBlob = server_CreateBlob(Class,team,spawnloc);
			newBlob.server_SetPlayer(player);
			
			if(blob !is null)
				{
					blob.server_SetPlayer(null);
					blob.server_Die();
				}
		
			return newBlob;
        }
        return null;
    }

    Vec2f getSpawnLocation( CPlayer@ player )
    {
        Vec2f[] spawnpoints;
        if (getMap().getMarkers("rpg_spawn", spawnpoints )) 
        {
            return spawnpoints[ XORRandom( spawnpoints.length ) ];
        }
        return Vec2f(0,0);
    }

    Vec2f getBaseLocation(u8 x)
    {
        CBlob@[] bases;
		getBlobsByTag("faction_base", @bases);
        array<int> baseSelection(bases.length);//          ~numan was also here
		
		int basePosMarker = 0;
		
		for(int i = 0; i < bases.length; i++)
        {
            if(bases[i].getTeamNum() == x)
            {
				baseSelection[basePosMarker] = i;
				basePosMarker++;
			}
        }
		if(basePosMarker > 0)
		{
			return bases[baseSelection[XORRandom(basePosMarker)]].getPosition();
		}
        return Vec2f(0,0);
    }

    bool isSpawning(CPlayer@ player)
    {
        if(player !is null)
        {
            if(player.getBlob() !is null)
            {
                return false;
            }
            return true;
        }
        return true;
    }
    CTFPlayerInfo@ getInfoFromName(string username)
    {
        for (uint k = 0; k < spawns.length; k++)
        {
            if (spawns[k].username == username)
            {
                return spawns[k];
            }
        }

        return null;
    }
};

shared class RPGCore : RulesCore
{
    RPGRespawns@ rpgrespawns;

    RPGCore() 
    { 
        super();
        error("DO NOT DO THIS! INITIALISE WITH RULESCORE(RULES,RESPAWNS)"); 
    }

    RPGCore(CRules@ _rules, RespawnSystem@ _respawns) 
    { 
        super(_rules, _respawns);
    }

    //delay setup
    RPGCore(bool delay_setup) { if (delay_setup == false) error("RULESCORE: Delayed setup used incorrectly"); }

    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        @rules = _rules;
        @rpgrespawns = cast <RPGRespawns@> (_respawns);

        if (rpgrespawns !is null)
        {
            rpgrespawns.SetCore(this);
        }

        SetupTeams();
        SetupPlayers();
        AddAllPlayersToSpawn(); 
    }

    void Update()
    {
        if (rpgrespawns !is null)
        {
            rpgrespawns.Update();
        }
    }
    void SetupTeams()
    {
        teams.clear();
    }

    void AddPlayerSpawn(CPlayer@ player)
    {

        CTFPlayerInfo@ p = rpgrespawns.getInfoFromName(player.getUsername());
        if (p is null)
        {
            AddPlayer(player);
        }
        else
        {
            if (p.lastSpawnRequest != 0 && p.lastSpawnRequest + 5 > getGameTime()) // safety - we dont want too much requests
            {
                return;
            }
        }

        if (player.lastBlobName.length() > 0 && p !is null)
        {
            p.blob_name = filterBlobNameToSpawn(player.lastBlobName, player);
        }

        if (rpgrespawns !is null)
        {
            rpgrespawns.RemovePlayerFromSpawn(player);
            rpgrespawns.AddPlayerToSpawn(player);
            
            if (p !is null)
            {
                p.lastSpawnRequest = getGameTime();
                player.set("lsr", getGameTime());
            }
        }
    }

    void ChangePlayerTeam(CPlayer@ player, int newTeamNum)
    {
        if(player is null)
            return;

        CTFPlayerInfo@ p = rpgrespawns.getInfoFromName(player.getUsername());

        if(p is null)
            return;

        if (p.team == newTeamNum)
        {
            return;
        }

        if (rpgrespawns !is null)
        {
            rpgrespawns.RemovePlayerFromSpawn(player);
        }

        ChangeTeamPlayerCount(p.team, -1);
        ChangeTeamPlayerCount(newTeamNum, 1);

        //RemovePlayerBlob(player);

        u8 oldteam = player.getTeamNum();
        p.setTeam(newTeamNum);
        player.server_setTeamNum(newTeamNum);

        rpgrespawns.AddPlayerToSpawn(player);
    }

    void AddAllPlayersToSpawn()
    {
        uint len = rpgrespawns.spawns.length;
        uint salt = XORRandom(len);
        for (uint k = 0; k < len; k++)
        {
            CTFPlayerInfo@ p = rpgrespawns.spawns[((k + salt) * 997) % len];
            p.lastSpawnRequest = 0;
            CPlayer@ player = getPlayerByUsername(p.username);
            AddPlayerSpawn(player);
        }
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        CTFPlayerInfo@ check = rpgrespawns.getInfoFromName(player.getUsername());
        if (check is null)
        {
            CTFPlayerInfo p(player.getUsername(), team, default_config);
            rpgrespawns.spawns.push_back(@p);
            ChangeTeamPlayerCount(p.team, 1);
        }
    }

    void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
    {
        AddPlayerSpawn(victim);
    }
};
