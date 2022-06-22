// Zombies gamemode logic script
// Modded by Eanmig
// Remodded by xTheSwiftOnex aka XeonFaux
#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "ZTechnology.as";  
#include "CTF_PopulateSpawnList.as";

//simple config function - edit the variables below to change the basics

void Config(ZombiesCore@ this)
{

    string configstr = "../Mods/PolishedZombies/Rules/PolishedZombies/zombies_vars.cfg";
	if (getRules().exists("Zombiesconfig")) {
	   configstr = getRules().get_string("Zombiesconfig");
	}
	ConfigFile cfg = ConfigFile(configstr);
	
	//how long for the game to play out?
    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}

	s32 max_npc_guards = cfg.read_s32("max_npc_guards", 50);
	s32 max_zombies = cfg.read_s32("max_zombies", 250);
	s32 max_migrants = cfg.read_s32("max_migrants", 10);

	bool destroy_dirt = cfg.read_bool("destroy_dirt", true);
	bool scrolls_spawn = cfg.read_bool("scrolls_spawn", false);
	bool techstuff_spawn = cfg.read_bool("techstuff_spawn", false);

	getRules().set_s32("max_npc_guards", max_npc_guards);
	getRules().set_s32("max_zombies", max_zombies);
	if (max_zombies > 250) max_zombies = 250; // Any more will most likely be too many for servers
	getRules().set_s32("max_migrants", max_migrants);
    
	getRules().set_bool("destroy_dirt", destroy_dirt);
	getRules().set_bool("scrolls_spawn", scrolls_spawn);
	getRules().set_bool("techstuff_spawn", techstuff_spawn);

    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 30));
}

//Zombies spawn system

const s32 spawnspam_limit_time = 10;

shared class ZombiesSpawns : RespawnSystem
{
    ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		
		limit = spawnspam_limit_time;
		getRules().set_bool("everyones_dead",false);
	}

    void Update()
    {
		int everyone_dead = 0;
		int total_count = Zombies_core.players.length + Zombies_core.rules.get_s32("num_migrantsinbed");
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num)
        {
            CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[team_num]);

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
				if (info !is null)
				{
					if (info.can_spawn_time>0) 
						everyone_dead++;
				}
                DoSpawnPlayer(info);
            }
        }
		if (getRules().isMatchRunning())
		{
			if (everyone_dead == total_count && total_count!=0)
				getRules().set_bool("everyones_dead",true); 
			//if (getGameTime() % (10*getTicksASecond()) == 0) warn("ED:"+everyone_dead+" TC:"+total_count);
			// Debug
		}
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if (info !is null)
		{
			u8 spawn_property = 255;
			
			if (info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8(propname, spawn_property);
			Zombies_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

    void DoSpawnPlayer(PlayerInfo@ p_info)
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}
			
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();					
			}

			CBlob@ spawnBlob = getSpawnBlobs(p_info);
            CBlob@ playerBlob;

            if (getRules().isWarmup() || p_info.blob_name == "necromancer")
            {
            	p_info.blob_name = "builder";
            }
            
            if (spawnBlob !is null)
            {
            	@playerBlob = SpawnPlayerIntoWorld(spawnBlob.getPosition(), p_info);

            	if(spawnBlob.hasTag("bed")){
                	CBitStream params;
					params.write_netid(playerBlob.getNetworkID());
					spawnBlob.SendCommand(spawnBlob.getCommandID("respawn"), params);
                }
            }
            else
            {
            	@playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);
            }
            
            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info (in bool canSpawnPlayer(PlayerInfo@ p_info)) "); return false; }

		//return true;
        //if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ c_info = cast<CTFPlayerInfo@>(p_info);
		if (c_info !is null)
        {
        	CBlob@ pickSpawn = getBlobByNetworkID(c_info.spawn_point);
			
			if (pickSpawn !is null && pickSpawn.hasTag("respawn") && 
				pickSpawn.getTeamNum() == p_info.team && 
				pickSpawn.get_bool("BedAvailable") == false)
			{
				CBitStream params;
				params.write_netid(pickSpawn.getNetworkID());
				return pickSpawn.getPosition();
			}
			else
			{
				CMap@ map = getMap();
				if (map !is null)
				{
					f32 x = 32.0f;
					return Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);
				}
			}
        }
        return Vec2f(0,0);
    }

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info (in void RemovePlayerFromSpawn(PlayerInfo@ p_info))"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8(propname, 255); //not respawning
		Zombies_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username)); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn(CPlayer@ player)
    {
		s32 tickspawndelay = 0;
		if (player.getDeaths() != 0)
		{
			int gamestart = getRules().get_s32("gamestart");
			int day_cycle = getRules().daycycle_speed * 60;
			int timeElapsed = ((getGameTime() - gamestart) / getTicksASecond()) % day_cycle;
			tickspawndelay = (day_cycle - timeElapsed) * getTicksASecond();
			warn("DC: " + day_cycle + " TE:" + timeElapsed);
			if (timeElapsed<30) 
				tickspawndelay = 0;
			else
				tickspawndelay = 300;
		}
		
		//; //
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info  (in void AddPlayerToSpawn(CPlayer@ player))"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		//print("ADD SPAWN FOR " + player.getUsername()+ "Spawn Delay: " +tickspawndelay);

		if (info.team < Zombies_core.teams.length)
		{
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning(CPlayer@ player)
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}
	CBlob@ getSpawnBlobs(PlayerInfo@ p_info)
	{
		CBlob@[] available;
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		u16 spawnpoint = info.spawn_point;

		// pick closest to death position
		if (spawnpoint > 0)
		{
			CBlob@ pickSpawn = getBlobByNetworkID(spawnpoint);
			if (pickSpawn !is null && pickSpawn.getTeamNum() == info.team && pickSpawn.get_bool("BedAvailable") == false)
			{
				return pickSpawn;
			}
			else
			{
				spawnpoint = 0; // can't pick this -> auto-pick
			}
		}

		// auto-pick closest
		if (spawnpoint == 0)
		{
			// get "respawn" bases
			CBlob@[] posts;
			getBlobsByTag("respawn", @posts);
			getBlobsByTag("bed", @posts);

			for (uint i = 0; i < posts.length; i++)
			{
				CBlob@ blob = posts[i];

				if (blob.getTeamNum() == info.team && blob.get_bool("BedAvailable") == false)
				{
					available.push_back(blob);
				}
			}

			while (available.size() > 0)
			{
				f32 closestDist = 999999.9f;
				uint closestIndex = 999;
				for (uint i = 0; i < available.length; i++)
				{
					CBlob @b = available[i];
					Vec2f bpos = b.getPosition();
					const f32 dist = (bpos - info.deathPosition).getLength();
					if (dist < closestDist)
					{
						closestDist = dist;
						closestIndex = i;
					}
				}
				if (closestIndex >= 999)
				{
					break;
				}
				return available[closestIndex];
			}
		}

		return null;
	}
};

shared class ZombiesCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns)
    {
        super(_rules, _respawns);
    }
    
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob("Entities/Meta/WARMusic.cfg");
		int gamestart = getGameTime();
		rules.set_s32("gamestart",gamestart);
		rules.SetCurrentState(WARMUP);
    }

    void Update()
    {
		
        if (rules.isGameOver()) { return; }

		int day_cycle = getRules().daycycle_speed * 60;
		int transition = rules.get_s32("transition");
		int max_zombies = rules.get_s32("max_zombies");
		int max_migrants = rules.get_s32("max_migrants");
		int num_migrantsinbed = rules.get_s32("num_migrantsinbed");
		int gamestart = rules.get_s32("gamestart");

		int timeElapsed = getGameTime() - gamestart;
		float difficulty = 2.0 * timeElapsed / getTicksASecond() / day_cycle;
		int dayNumber = (timeElapsed / getTicksASecond() / day_cycle) + 1;
		float actdiff = 3.0 * dayNumber;
		rules.set_u8("day_number", dayNumber);

		// Actdiff = 4 * DAYNUMBER

		int num_zombies = rules.get_s32("num_zombies");
		CBlob@[] zombie_blobs;
		getBlobsByTag("zombie", @zombie_blobs);
		num_zombies = zombie_blobs.length;
		rules.set_s32("num_zombies", num_zombies);

		int num_migrants = rules.get_s32("num_migrants");
		CBlob@[] migrant_blobs;
		getBlobsByTag("migrant", @migrant_blobs);
		num_migrants = migrant_blobs.length;
		rules.set_s32("num_migrants", num_migrants);

		int num_zombiePortals = rules.get_s32("num_zombiePortals");
		CBlob@[] zombiePortal_blobs;
		getBlobsByTag("Zombie_Portal", @zombiePortal_blobs);
		num_zombiePortals = zombiePortal_blobs.length;
		rules.set_s32("num_zombiePortals", num_zombiePortals);
		
		if (rules.isWarmup() && timeElapsed > getTicksASecond() * 30)
		{
			rules.SetCurrentState(GAME);
			warn("TE:"+timeElapsed);
		}

		rules.set_f32("difficulty", difficulty / 3.0);
		int intdif = difficulty;
		if (intdif <= 0)
			intdif = 1;

		int spawnRate = getTicksASecond() * (6 - (difficulty / 2.0));
		int extra_zombies = 0;
		if (dayNumber > 10)
			extra_zombies = (dayNumber - 10) * 5;
		if (extra_zombies > max_zombies - 100)
			extra_zombies = max_zombies - 100;
		if (spawnRate < 8)
			spawnRate=8;

		int wraithRate = 2 + (intdif / 4);

		if (getGameTime() % 150 == 0)
		{
			printf("Zombies: " + num_zombies + ", Migrants: " + num_migrants);
		}
			
	    if (getGameTime() % (spawnRate) == 0 && num_zombies < 100 + extra_zombies)
        {
			
			CMap@ map = getMap();
			if (map !is null)
			{
				Vec2f[] zombiePlaces;
				rules.SetGlobalMessage("Day " + dayNumber + ": " + num_zombiePortals + " Zombie Portals");			
				
				getMap().getMarkers("zombie spawn", zombiePlaces);
				
				if (zombiePlaces.length<=0)
				{
					
					for (int zp=8; zp<16; zp++)
					{
						Vec2f col;
						
						getMap().rayCastSolid(Vec2f((map.tilemapwidth-zp)*8, 0.0f), Vec2f((map.tilemapwidth-zp)*8, map.tilemapheight*8), col);
						col.y-=16.0;
						zombiePlaces.push_back(col);
					}
				}
				if (map.getDayTime()>0.8 || map.getDayTime()<0.1)
				{	
					Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];

					int r;
					if (actdiff > 21)
						r = XORRandom(40);
					else 
						r = XORRandom(actdiff);

					int rr = XORRandom(65);

					if (r >= 38 && rr < 3)
                        server_CreateBlob("banshee", -1, sp);
                    else if (r >= 34 && rr < 15)    
                        server_CreateBlob("wraith", -1, sp);
					else if (r >= 24)
						server_CreateBlob("zknight", -1, sp);
					else if (r >= 23)
						server_CreateBlob("horror", -1, sp);
					else if (r >= 15)
						server_CreateBlob("gasbag", -1, sp);
					else if (r >= 7)
						server_CreateBlob("zombie", -1, sp);
					else if (r >= 1)
						server_CreateBlob("skeleton", -1, sp);
					
					if (transition == 1 && (dayNumber % 5) == 0)
					{

						transition=0;
						rules.set_s32("transition",0);
						Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];
						for (int i = 0; i < dayNumber / 5; i++)
						{
							server_CreateBlob("king", -1, sp);
							if (dayNumber > 5)
							{
								server_CreateBlob("abomination", -1, sp);
							}
						}
					}
					
				}
				else
				{
					if (transition == 0)
					{	
						rules.set_s32("transition",1);
					}
				}
			}
		}
		
        RulesCore::Update(); //update respawns
        CheckTeamWon();

    }

    //team stuff

    void AddTeam(CTeam@ team)
    {
        CTFTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        CTFPlayerInfo p(player.getUsername(), 0, "builder");
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		warn("sync");
    }

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
			CBlob@ blob = victim.getBlob();
			if(blob !is null){
				NotifyDeathPosition(victim, blob.getPosition());
			}
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

    //checks
    void CheckTeamWon()
    {
        if (!rules.isMatchRunning()) { return; }
        int gamestart = rules.get_s32("gamestart");	
        int num_zombiePortals = rules.get_s32("num_zombiePortals");
		int day_cycle = getRules().daycycle_speed*60;			
		int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
		if (getRules().get_bool("everyones_dead")) 
		{
		
            rules.SetCurrentState(GAME_OVER);
            rules.SetGlobalMessage("You survived for "+ dayNumber+" days. God you guys must be bad.");		
			getRules().set_bool("everyones_dead",false); 
		}
		else if (dayNumber == 30)
		{
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage("You managed to survive for 30 rounds!");
		}
		
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            CTFTeamInfo@ team_info = cast<CTFTeamInfo@>(teams[team]);
        }
    }

    void NotifyDeathPosition(CPlayer@ player, Vec2f deathPosition)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (getInfoFromPlayer(player));
		if (info is null) { return; }
		info.deathPosition = deathPosition;
	}
};

//pass stuff to the core from each of the hooks

void spawnPortal(Vec2f pos)
{
	server_CreateBlob("ZombiePortal",-1,pos+Vec2f(0,-24.0));
}

void spawnRandomTech(Vec2f pos)
{
	bool techstuff_spawn = getRules().get_bool("techstuff_spawn");
	if (techstuff_spawn)
	{
		int r = XORRandom(2);
		if (r == 0)
			server_CreateBlob("RocketLauncher",-1,pos+Vec2f(0,-16.0));
		else
		if (r == 1)
			server_CreateBlob("megasaw",-1,pos+Vec2f(0,-16.0));
	}
}

void spawnRandomScroll(Vec2f pos)
{
	bool scrolls_spawn = getRules().get_bool("scrolls_spawn");
	if (scrolls_spawn)
	{
		int r = XORRandom(16);
		if (r == 0)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "carnage");
		else
		if (r == 1)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "midas");				
		else
		if (r == 2)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "tame");				
		else
		if (r == 3)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "necro");	
		else
		if (r == 4)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "stone");
		else
		if (r == 5)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "light");
		else
		if (r == 6)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "bison");
		else
		if (r == 7)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "healing");	
		else
		if (r == 8)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "drought");
		else
		if (r == 9)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "shark");
		else
		if (r == 10)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "horde");
		else
		if (r == 11)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "meteor");
		else
		if (r == 12)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "chicken");
		else
		if (r == 13)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "return");
		else
		if (r == 14)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "skeleton");
		else
		if (r == 15)
			server_MakePredefinedScroll(pos + Vec2f(0,-16.0), "zombie");
	}
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
    printf("Restarting rules script: " + getCurrentScriptName());
    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core);
    SetupScrolls(getRules());
	Vec2f[] zombiePlaces;
	getMap().getMarkers("zombie portal", zombiePlaces);
	if (zombiePlaces.length>0)
	{
		for (int i=0; i<zombiePlaces.length; i++)
		{
			spawnPortal(zombiePlaces[i]);
		}
	}
	Vec2f[] techPlaces;
	getMap().getMarkers("random scroll", techPlaces);
	if (techPlaces.length>0)
	{
		for (int i=0; i<techPlaces.length; i++)
		{
			int r = XORRandom(6);
			if (r == 0)
			{
				spawnRandomTech(techPlaces[i]);
			}
		}
	}

	Vec2f[] scrollPlaces;
	getMap().getMarkers("random scroll", scrollPlaces);
	if (scrollPlaces.length>0)
	{
		for (int i=0; i<scrollPlaces.length; i++)
		{
			spawnRandomScroll(scrollPlaces[i]);
		}
	}

    //this.SetCurrentState(GAME);
    
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

