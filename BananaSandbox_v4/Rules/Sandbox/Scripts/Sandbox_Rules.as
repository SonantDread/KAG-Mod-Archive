
//Sandbox gamemode logic script

#define SERVER_ONLY

#include "Sandbox_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "PlayerUtils.as";

//simple config function - edit the variables below to change the basics

void Config(SandboxCore@ this)
{
	string configstr = "Rules/Sandbox/sandbox_vars.cfg";
	if (getRules().exists("sandboxconfig"))
	{
		configstr = getRules().get_string("sandboxconfig");
	}
	ConfigFile cfg = ConfigFile(configstr);

	//how long for the game to play out?
	s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
	if (gameDurationMinutes <= 0)
	{
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
	else
	{
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}

	//spawn after death time
	this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 15));

}

//Sandbox spawn system

const s32 spawnspam_limit_time = 10;

class SandboxSpawns : RespawnSystem
{
	SandboxCore@ Sandbox_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Sandbox_core = cast < SandboxCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < Sandbox_core.teams.length; ++team_num)
		{
			SandboxTeamInfo@ team = cast < SandboxTeamInfo@ > (Sandbox_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(SandboxPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "Sandbox spawn time " + info.username;

			Sandbox_core.rules.set_u8(propname, spawn_property);
			Sandbox_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if (inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob(name);
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
		}

		return true;
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

			p_info.blob_name = "builder"; //hard-set the respawn blob
			CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);

			if (playerBlob !is null)
			{
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);

				// spawn resources
				SetMaterials(playerBlob, "mat_wood", 500);
				SetMaterials(playerBlob, "mat_stone", 250);
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (p_info);

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		return true;
		/*
		if (force) { return true; }

		return info.can_spawn_time <= 0;*/
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		SandboxPlayerInfo@ c_info = cast < SandboxPlayerInfo@ > (p_info);
		if (c_info !is null)
		{
			CMap@ map = getMap();
			if (map !is null)
			{
				f32 x = XORRandom(map.tilemapwidth - 2) * map.tilesize + 32.0f;
				return Vec2f(x, map.getLandYAtX(s32(x / map.tilesize)) * map.tilesize - 16.0f);
			}
		}

		return Vec2f(0, 0);
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (p_info);

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "Sandbox spawn time " + info.username;

		for (uint i = 0; i < Sandbox_core.teams.length; i++)
		{
			SandboxTeamInfo@ team = cast < SandboxTeamInfo@ > (Sandbox_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		Sandbox_core.rules.set_u8(propname, 255);   //not respawning
		Sandbox_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(Sandbox_core.spawnTime);

		SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("Sandbox LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

//		print("ADD SPAWN FOR " + player.getUsername());

		if (info.team < Sandbox_core.teams.length)
		{
			SandboxTeamInfo@ team = cast < SandboxTeamInfo@ > (Sandbox_core.teams[info.team]);

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
		SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < Sandbox_core.teams.length; i++)
		{
			SandboxTeamInfo@ team = cast < SandboxTeamInfo@ > (Sandbox_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

class SandboxCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;

	SandboxSpawns@ Sandbox_spawns;

	SandboxCore() {}

	SandboxCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		@Sandbox_spawns = cast < SandboxSpawns@ > (_respawns);
		server_CreateBlob("Entities/Meta/WARMusic.cfg");
	}

	void Update()
	{

		if (rules.isGameOver()) { return; }

		RulesCore::Update(); //update respawns
		CheckTeamWon();

		for(int i = 0; i < players.length(); i++)
		{
			SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (players[i]);

			if(info.spam_timer > 0)
			{
				info.spam_timer--;
				if(info.spam_timer == 0)
					info.spam_count = 0;
			}
			if(info.spam_cooldown > 0)
				info.spam_cooldown--;
		}
	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		SandboxTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		SandboxPlayerInfo p(player.getUsername(), 0, "builder");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
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
		//can you win sandbox? :)
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			SandboxTeamInfo@ team_info = cast < SandboxTeamInfo@ > (teams[team]);
		}
	}

};

//pass stuff to the core from each of the hooks

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
	SandboxSpawns spawns();
	SandboxCore core(this, spawns);
	Config(core);

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");

	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	// Spam filter
	if(!isSuperAdmin(player))
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			SandboxPlayerInfo@ info = cast < SandboxPlayerInfo@ > (core.getInfoFromPlayer(player));
			if (info !is null)
			{
				if(info.spam_cooldown > 0)
				{
					text_out = "!nospam";
					return true;
				}

				info.spam_timer = 5 * getTicksASecond();
				info.spam_count++;

				if(info.spam_count == 15)
				{
					info.spam_cooldown = 60 * getTicksASecond();
					text_out = "!nospam";
					return true;
				}
			}
		}
	}

	return true;
}
