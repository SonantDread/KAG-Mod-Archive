// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";
#include "RespawnSystem.as";
#include "RulesCore.as";
#include "MakeCrate.as"

const u16 SPAWN_COOLDOWN = 15;

namespace GameTypes
{
	enum type
	{
		TDM = 0,
		TEAM_STOCK,
		FFA_STOCK
	}
}

shared class SSKPlayerInfo : PlayerInfo
{
	u32 can_spawn_time;
	bool thrownBomb;

	SSKPlayerInfo() { Setup("", 0, ""); }
	SSKPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		thrownBomb = false;
	}
};

//teams

shared class SSKTeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;
	int kills;
	int stocks;

	SSKTeamInfo() { super(); }

	SSKTeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		kills = 0;
		stocks = 0;
		//spawns.clear();
	}
};

shared class SSK_HUD
{
	u8 gameType;

	//is this our team?
	u8 team_num;
	//exclaim!
	string unit_pattern;
	u8 spawn_time;
	//units
	s16 kills;
	s16 kills_limit; //here for convenience

	s16 teamStocks;

	SSK_HUD() { }
	SSK_HUD(CBitStream@ bt) { Unserialise(bt); }

	void Serialise(CBitStream@ bt)
	{
		bt.write_u8(gameType);
		bt.write_u8(team_num);
		bt.write_string(unit_pattern);
		bt.write_u8(spawn_time);
		bt.write_s16(kills);
		bt.write_s16(kills_limit);
		bt.write_s16(teamStocks);
	}

	void Unserialise(CBitStream@ bt)
	{
		gameType = bt.read_u8();
		team_num = bt.read_u8();
		unit_pattern = bt.read_string();
		spawn_time = bt.read_u8();
		kills = bt.read_s16();
		kills_limit = bt.read_s16();
		teamStocks = bt.read_s16();
	}

};

shared class SSKCore : RulesCore
{
	u8 gameType;

	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;
	s32 minimum_players_in_team;
	s32 kills_to_win;
	s32 kills_to_win_per_player;
	bool all_death_counts_as_kill;
	bool sudden_death;

	s32 starting_stocks;

	s32 players_in_small_team;
	bool scramble_teams;

	SSKSpawns@ ssk_spawns;

	SSKCore() {}

	SSKCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		gametime = getGameTime() + 100;
		@ssk_spawns = cast < SSKSpawns@ > (_respawns);
		players_in_small_team = -1;
		all_death_counts_as_kill = false;
		sudden_death = false;

		sv_mapautocycle = true;
	}

	int gametime;
	void Update()
	{
		//HUD
		// lets save the CPU and do this only once in a while
		if (getGameTime() % 16 == 0)
		{
			updateHUD();
		}

		if (this.gameType == GameTypes::TEAM_STOCK || this.gameType == GameTypes::FFA_STOCK)
		{
			if (getGameTime() % 256 == 0)
			{
				updateTeamStocks();
			}
		}

		if (rules.isGameOver()) { return; }

		s32 ticksToStart = gametime - getGameTime();

		ssk_spawns.force = false;

		if (ticksToStart <= 0 && (rules.isWarmup()))
		{
			rules.SetCurrentState(GAME);
		}
		else if (ticksToStart > 0 && rules.isWarmup()) //is the start of the game, spawn everyone + give mats
		{
			rules.SetGlobalMessage("Match starts in " + ((ticksToStart / 30) + 1));
			ssk_spawns.force = true;

			//set kills and cache #players in smaller team

			if (players_in_small_team == -1 || (getGameTime() % 30) == 4)
			{
				players_in_small_team = 100;

				for (uint team_num = 0; team_num < teams.length; ++team_num)
				{
					SSKTeamInfo@ team = cast < SSKTeamInfo@ > (teams[team_num]);

					if (team.players_count < players_in_small_team)
					{
						players_in_small_team = team.players_count;
					}
				}

				kills_to_win = Maths::Max(players_in_small_team, 1) * kills_to_win_per_player;
			}
		}

		if ((rules.isIntermission() || rules.isWarmup()) && (!allTeamsHavePlayers()))  //CHECK IF TEAMS HAVE ENOUGH PLAYERS
		{
			gametime = getGameTime() + warmUpTime;
			rules.set_u32("game_end_time", gametime + gameDuration);
			rules.SetGlobalMessage("Not enough players in each team for the game to start.\nPlease wait for someone to join...");
			ssk_spawns.force = true;
		}
		else if (rules.isMatchRunning())
		{
			rules.SetGlobalMessage("");
		}

		//  SpawnPowerups();
		RulesCore::Update(); //update respawns

		if (this.gameType == GameTypes::FFA_STOCK)
		{
			CheckPlayerWonFFA();
		}
		else
		{
			CheckTeamWon();
		}

		if (getGameTime() % 2000 == 0)
			SpawnBombs();
	}

	void updateHUD()
	{
		bool hidekills = (rules.isIntermission() || rules.isWarmup());
		CBitStream serialised_team_hud;
		serialised_team_hud.write_u16(0x5afe); //check bits

		for (uint team_num = 0; team_num < teams.length; ++team_num)
		{
			SSK_HUD hud;
			SSKTeamInfo@ team = cast < SSKTeamInfo@ > (teams[team_num]);

			hud.gameType = this.gameType;
			hud.team_num = team_num;
			hud.kills = team.kills;
			hud.kills_limit = -1;
			if (!hidekills)
			{
				if (kills_to_win <= 0)
					hud.kills_limit = -2;
				else
					hud.kills_limit = kills_to_win;
			}
			hud.teamStocks = team.stocks;

			string temp = "";

			for (uint player_num = 0; player_num < players.length; ++player_num)
			{
				SSKPlayerInfo@ player = cast < SSKPlayerInfo@ > (players[player_num]);

				if (player.team == team_num)
				{
					CPlayer@ e_player = getPlayerByUsername(player.username);

					if (e_player !is null)
					{
						CBlob@ player_blob = e_player.getBlob();
						bool blob_alive = player_blob !is null;

						if (blob_alive)
						{
							string player_char = "k"; //default to sword

							if (player_blob.getName() == "super_archer")
							{
								player_char = "a";
							}

							temp += player_char;
						}
						else
						{
							temp += "s";
						}
					}
				}
			}

			hud.unit_pattern = temp;

			bool set_spawn_time = false;
			if (team.spawns.length > 0 && !rules.isIntermission())
			{
				u32 st = cast < SSKPlayerInfo@ > (team.spawns[0]).can_spawn_time;
				if (st < 200)
				{
					hud.spawn_time = (st / 30);
					set_spawn_time = true;
				}
			}
			if (!set_spawn_time)
			{
				hud.spawn_time = 255;
			}	

			hud.Serialise(serialised_team_hud);
		}

		rules.set_CBitStream("ssk_serialised_team_hud", serialised_team_hud);
		rules.Sync("ssk_serialised_team_hud", true);
	}

	//HELPERS

	bool allTeamsHavePlayers()
	{
		for (uint i = 0; i < teams.length; i++)
		{
			if (teams[i].players_count < minimum_players_in_team)
			{
				return false;
			}
		}

		return true;
	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		SSKTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		SSKPlayerInfo p(player.getUsername(), player.getTeamNum(), player.isBot() ? "super_knight" : "super_knight");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (rules.isWarmup()) return;

		if (!rules.isMatchRunning() && !all_death_counts_as_kill) return;

		if (victim !is null)
		{
			if (this.gameType == GameTypes::TDM)
			{
				if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
				{
					addKill(killer.getTeamNum());
				}
				else if (all_death_counts_as_kill)
				{
					for (int i = 0; i < rules.getTeamsNum(); i++)
					{
						if (i != victim.getTeamNum())
						{
							addKill(i);
						}
					}
				}
			}
			else if (this.gameType == GameTypes::TEAM_STOCK || this.gameType == GameTypes::FFA_STOCK)
			{
				string victimName = victim.getUsername();
				u8 victimStocks = rules.get_u8("playerStocks"+victimName);
				if (victimStocks > 0)
				{
					victimStocks--;

					rules.set_u8("playerStocks"+victimName, victimStocks);
					rules.Sync("playerStocks"+victimName, true);

					updateTeamStocks();
				}
			}	
		}
	}

	void onSetPlayer(CBlob@ blob, CPlayer@ player)
	{
		if (blob !is null && player !is null)
		{
			GiveSpawnResources(blob, player);
		}
	}

	//setup the SSK bases

	void SetupBase(CBlob@ base)
	{
		if (base is null)
		{
			return;
		}

		//nothing to do
	}


	void SetupBases()
	{
		const string base_name = "ssk_spawn";
		// destroy all previous spawns if present
		CBlob@[] oldBases;
		getBlobsByName(base_name, @oldBases);

		for (uint i = 0; i < oldBases.length; i++)
		{
			oldBases[i].server_Die();
		}

		//spawn the spawns :D
		CMap@ map = getMap();

		if (map !is null)
		{
			// team 0 ruins
			Vec2f[] respawnPositions;
			Vec2f respawnPos;

			if (!getMap().getMarkers("blue main spawn", respawnPositions))
			{
				warn("SSK: Blue spawn marker not found on map");
				respawnPos = Vec2f(150.0f, map.getLandYAtX(150.0f / map.tilesize) * map.tilesize - 32.0f);
				respawnPos.y -= 16.0f;
				SetupBase(server_CreateBlob(base_name, 0, respawnPos));
			}
			else
			{
				for (uint i = 0; i < respawnPositions.length; i++)
				{
					respawnPos = respawnPositions[i];
					respawnPos.y -= 16.0f;
					SetupBase(server_CreateBlob(base_name, 0, respawnPos));
				}
			}

			respawnPositions.clear();


			// team 1 ruins
			if (!getMap().getMarkers("red main spawn", respawnPositions))
			{
				warn("SSK: Red spawn marker not found on map");
				respawnPos = Vec2f(map.tilemapwidth * map.tilesize - 150.0f, map.getLandYAtX(map.tilemapwidth - (150.0f / map.tilesize)) * map.tilesize - 32.0f);
				respawnPos.y -= 16.0f;
				SetupBase(server_CreateBlob(base_name, 1, respawnPos));
			}
			else
			{
				for (uint i = 0; i < respawnPositions.length; i++)
				{
					respawnPos = respawnPositions[i];
					respawnPos.y -= 16.0f;
					SetupBase(server_CreateBlob(base_name, 1, respawnPos));
				}
			}

			respawnPositions.clear();
		}

		rules.SetCurrentState(WARMUP);
	}

	//checks
	void CheckTeamWon()
	{
		if (!rules.isMatchRunning()) { return; }

		int winteamIndex = -1;
		SSKTeamInfo@ winteam = null;
		s8 team_wins_on_end = -1;

		if (this.gameType == GameTypes::TDM)
		{
			int highkills = 0;
			for (uint team_num = 0; team_num < teams.length; ++team_num)
			{
				SSKTeamInfo@ team = cast < SSKTeamInfo@ > (teams[team_num]);

				if (team.kills > highkills)
				{
					highkills = team.kills;
					team_wins_on_end = team_num;

					if (team.kills >= kills_to_win)
					{
						@winteam = team;
						winteamIndex = team_num;
					}
				}
				else if (team.kills > 0 && team.kills == highkills)
				{
					team_wins_on_end = -1;
				}
			}
		}
		else if (this.gameType == GameTypes::TEAM_STOCK || this.gameType == GameTypes::FFA_STOCK)
		{
			//clear the winning team - we'll find that ourselves
			@winteam = null;
			winteamIndex = -1;

			//set up an array of which teams are alive
			array<bool> teams_alive;
			s32 teams_alive_count = 0;
			for (uint team_num = 0; team_num < teams.length; ++team_num)
			{
				SSKTeamInfo@ team = cast < SSKTeamInfo@ > (teams[team_num]);
				if (team.stocks > 0)
				{
					teams_alive.push_back(true);
					teams_alive_count++;
				}
				else
				{
					teams_alive.push_back(false);
				}
			}

			//only one team remains!
			if (teams_alive_count == 1)
			{
				for (int i = 0; i < teams.length; i++)
				{
					if (teams_alive[i])
					{
						@winteam = cast < SSKTeamInfo@ > (teams[i]);
						winteamIndex = i;
						team_wins_on_end = i;
					}
				}
			}
		}

		//sudden death mode - check if anyone survives
		if (sudden_death)
		{
			//clear the winning team - we'll find that ourselves
			@winteam = null;
			winteamIndex = -1;

			//set up an array of which teams are alive
			array<bool> teams_alive;
			s32 teams_alive_count = 0;
			for (int i = 0; i < teams.length; i++)
				teams_alive.push_back(false);

			//check with each player
			for (int i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ p = getPlayer(i);
				if (p !is null)
				{
					CBlob@ b = p.getBlob();
					s32 team = p.getTeamNum();
					if (b !is null && !b.hasTag("dead") && //blob alive
					        team >= 0 && team < teams.length) //team sensible
					{
						if (!teams_alive[team])
						{
							teams_alive[team] = true;
							teams_alive_count++;
						}
					}
				}
			}

			//only one team remains!
			if (teams_alive_count == 1)
			{
				for (int i = 0; i < teams.length; i++)
				{
					if (teams_alive[i])
					{
						@winteam = cast < SSKTeamInfo@ > (teams[i]);
						winteamIndex = i;
						team_wins_on_end = i;
					}
				}
			}
			//no teams survived, draw
			if (teams_alive_count == 0)
			{
				rules.SetTeamWon(-1);   //game over!
				rules.SetCurrentState(GAME_OVER);
				rules.SetGlobalMessage("It's a tie!");
				return;
			}

		}

		rules.set_s8("team_wins_on_end", team_wins_on_end);

		if (winteamIndex >= 0)
		{
			// add winning team coins
			if (rules.isMatchRunning())
			{
				CBlob@[] players;
				getBlobsByTag("player", @players);
				for (uint i = 0; i < players.length; i++)
				{
					CPlayer@ player = players[i].getPlayer();
					if (player !is null && player.getTeamNum() == winteamIndex)
					{
						player.server_setCoins(player.getCoins() + 10);
					}
				}
			}

			rules.SetTeamWon(winteamIndex);   //game over!
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage(winteam.name + " wins the game!");
		}
	}

	void CheckPlayerWonFFA()
	{
		if (!rules.isMatchRunning()) { return; }

		int playersLeft = 0;
		string lastPlayerStandingUsername;
		string lastPlayerStandingCharacterName;

		// Check for last player alive
		for (int i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p !is null)
			{
				if (rules.get_u8("playerStocks"+p.getUsername()) > 0)
				{
					playersLeft++;
					
					if (playersLeft > 1)
						return;

					lastPlayerStandingUsername = p.getUsername();
					lastPlayerStandingCharacterName = p.getCharacterName();				}
			}
		}

		// Win or tie conditions
		if (playersLeft == 1)
		{
			rules.set_string("winning_player", lastPlayerStandingUsername);
			rules.Sync("winning_player", true);

			// add winning player coins
			if (rules.isMatchRunning())
			{
				CPlayer@ lastPlayer = getPlayerByUsername(lastPlayerStandingUsername);
				if (lastPlayer !is null)
				{
					lastPlayer.server_setCoins(lastPlayer.getCoins() + 10);
				}
			}
 
			rules.SetCurrentState(GAME_OVER);	//game over!
			rules.SetGlobalMessage(lastPlayerStandingCharacterName + " wins the game!");
		}
		else if (playersLeft == 0)
		{
			rules.SetTeamWon(-1);   //game over!
			rules.SetCurrentState(GAME_OVER);
			rules.SetGlobalMessage("It's a tie!");
			return;
		}
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			SSKTeamInfo@ team_info = cast < SSKTeamInfo@ > (teams[team]);
			team_info.kills++;
		}
	}

	void updateTeamStocks()
	{
		// Reset stock count
		for (uint i = 0; i < this.teams.length; i++)
		{
			SSKTeamInfo@ team_info = cast < SSKTeamInfo@ > (teams[i]);
			team_info.stocks = 0;
		}

		// Sum up all player stocks on team
		for (int i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				if (player.getTeamNum() < teams.length)
				{
					SSKTeamInfo@ team_info = cast < SSKTeamInfo@ > (teams[player.getTeamNum()]);

					string playerName = player.getUsername();
					team_info.stocks += rules.get_u8("playerStocks"+playerName);
				}
			}
		}
	}

	void SpawnPowerups()
	{
		if (getGameTime() % 200 == 0 && XORRandom(12) == 0)
		{
			SpawnPowerup();
		}
	}

	void SpawnPowerup()
	{
		CBlob@ powerup = server_CreateBlob("powerup", -1, Vec2f(getMap().tilesize * 0.5f * getMap().tilemapwidth, 50.0f));
	}

	void SpawnBombs()
	{
		Vec2f[] bombPlaces;
		if (getMap().getMarkers("bombs", bombPlaces))
		{
			for (uint i = 0; i < bombPlaces.length; i++)
			{
				server_CreateBlob("mat_bombs", -1, bombPlaces[i]);
			}
		}
	}


	void GiveSpawnResources(CBlob@ blob, CPlayer@ player)
	{
		// give superArcher arrows

		if (blob.getName() == "super_archer")
		{
			// first check if its in surroundings
			CBlob@[] blobsInRadius;
			CMap@ map = getMap();
			bool found = false;
			if (map.getBlobsInRadius(blob.getPosition(), 60.0f, @blobsInRadius))
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if (b.getName() == "mat_arrows")
					{
						found = true;
						if (!found)
						{
							blob.server_PutInInventory(b);
						}
						else
						{
							b.server_Die();
						}
					}
				}
			}

			if (!found)
			{
				giveStartingMat(blob, "mat_arrows");
				giveStartingMat(blob, "mat_waterarrows");
				giveStartingMat(blob, "mat_firearrows");
				giveStartingMat(blob, "mat_bombarrows");
			}
		}
		else if (blob.getName() == "builder")
		{
			SetMaterials(blob, "mat_wood", 200);
			SetMaterials(blob, "mat_stone", 100);
		}
	}

	void giveStartingMat(CBlob@ blob, string matName)
	{
		CBlob@ mat = server_CreateBlob(matName);
		if (mat !is null)
		{
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
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

		CBlob@ mat = server_CreateBlobNoInit(name);

		if (mat !is null)
		{
			mat.Tag('custom quantity');
			mat.Init();

			mat.server_SetQuantity(quantity);

			if (not blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
		}

		return true;
	}

	void AddPlayerSpawn(CPlayer@ player)
	{

		PlayerInfo@ p = getInfoFromName(player.getUsername());
		if (p is null)
		{
			AddPlayer(player);
		}
		else
		{
			if (p.lastSpawnRequest != 0 && p.lastSpawnRequest + 5 > getGameTime()) // safety - we dont want too much requests
			{
				//  printf("too many spawn requests " + p.lastSpawnRequest + " " + getGameTime());
				return;
			}

			// kill old player
			RemovePlayerBlob(player);
		}

		/*
		if (player.lastBlobName.length() > 0 && p !is null)
		{
			p.blob_name = filterBlobNameToSpawn(player.lastBlobName, player);
		}
		*/

		if (player !is null)
		{
			string playerClassConfig = rules.get_string("playerClassConfig"+player.getUsername());
			if (playerClassConfig.length() > 0)
			{
				p.blob_name = playerClassConfig;
			}
		}

		if (respawns !is null)
		{
			respawns.RemovePlayerFromSpawn(player);
			respawns.AddPlayerToSpawn(player);
			if (p !is null)
			{
				p.lastSpawnRequest = getGameTime();
			}
		}
	}
};

//SSK spawn system

shared class SSKSpawns : RespawnSystem
{
	SSKCore@ SSK_core;

	bool force;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@SSK_core = cast < SSKCore@ > (core);
	}

	void Update()
	{
		bool canSpawnPlayer = SSK_core.rules.get_u16("spawn cooldown") <= 0;
		for (uint team_num = 0; team_num < SSK_core.teams.length; ++team_num)
		{
			SSKTeamInfo@ team = cast < SSKTeamInfo@ > (SSK_core.teams[team_num]);

			// spawn time update
			for (uint i = 0; i < team.spawns.length; i++)
			{
				SSKPlayerInfo@ info = cast < SSKPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				// spawn players if possible
				if (canSpawnPlayer)
				{
					DoSpawnPlayer(info);
					canSpawnPlayer = SSK_core.rules.get_u16("spawn cooldown") <= 0;
				}
				
			}
		}

		// update spawning cooldown
		u16 spawnCooldown = SSK_core.rules.get_u16("spawn cooldown");
		if (spawnCooldown > 0)
		{
			spawnCooldown--;
			SSK_core.rules.set_u16("spawn cooldown", spawnCooldown);
		}
	}

	void UpdateSpawnTime(SSKPlayerInfo@ info, int i)
	{
		//default
		u8 spawn_property = 254;

		//flag for no respawn
		bool huge_respawn = info.can_spawn_time >= 0x00ffffff;
		bool no_respawn = SSK_core.rules.isMatchRunning() ? huge_respawn : false;
		CPlayer@ player = getPlayerByUsername(info.username);

		if (no_respawn)
		{
			spawn_property = 253;
		}

		if (info !is null && info.can_spawn_time > 0)
		{
			if (!no_respawn)
			{
				if (huge_respawn)
				{
					info.can_spawn_time = 5;
				}

				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}
			else
			{
				info.can_spawn_time = 255;
			}
		}

		string propname = "ssk spawn time " + info.username;
		SSK_core.rules.set_u8(propname, spawn_property);
		if (info !is null && info.can_spawn_time >= 0)
		{
			SSK_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (force || canSpawnPlayer(p_info))
		{
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

			string playerBlobName = "";
			if ( SSK_core.rules.isMatchRunning() && 
					(SSK_core.gameType == GameTypes::TEAM_STOCK || SSK_core.gameType == GameTypes::FFA_STOCK) && 
					SSK_core.rules.get_u8("playerStocks"+p_info.username) <= 0 )
			{
				playerBlobName = "builder";
			}

			if (SSK_core.gameType == GameTypes::FFA_STOCK)
			{
				CBlob@ playerBlob = AttemptRandomPlayerSpawn(p_info, playerBlobName);
				if (playerBlob !is null)
				{
					// spawn resources
					p_info.spawnsCount++;
					RemovePlayerFromSpawn(player);

					SSK_core.rules.set_u16("spawn cooldown", SPAWN_COOLDOWN);
				}
			}
			else
			{
				CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info, playerBlobName);
				if (playerBlob !is null)
				{
					// spawn resources
					p_info.spawnsCount++;
					RemovePlayerFromSpawn(player);
				}
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		SSKPlayerInfo@ info = cast < SSKPlayerInfo@ > (p_info);

		if (info is null) { warn("SSK LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		return info.can_spawn_time == 0;
	}

	CBlob@ SpawnPlayerIntoWorld(Vec2f at, PlayerInfo@ p_info, string blob_name)
	{
		CPlayer@ player = getPlayerByUsername(p_info.username);

		if (player !is null)
		{
			if (blob_name == "")
			{
				blob_name = p_info.blob_name;
			}
			CBlob @newBlob = server_CreateBlob(blob_name, p_info.team, at);
			newBlob.server_SetPlayer(player);
			player.server_setTeamNum(p_info.team);
			return newBlob;
		}

		return null;
	}

	CBlob@ AttemptRandomPlayerSpawn(PlayerInfo@ p_info, string blob_name)
	{
		CMap@ map = getMap();
		const u16 mapWidth = map.tilemapwidth * map.tilesize;
		const u16 mapHeight = map.tilemapheight * map.tilesize;
		
		const f32 SPAWN_MARGIN = 100.0f;
		f32 randomPosX = SPAWN_MARGIN + XORRandom(mapWidth - SPAWN_MARGIN);

		bool foundValidSpawnPos = false;

		Vec2f randSpawnPos;	// random spawn position in the sky
		u16 groundHeight;

		u16 rayStartY = 0;	// start from top of the map
		for (uint rayStartY = 0; rayStartY < mapHeight; rayStartY += map.tilesize*2)
		{
			Vec2f startPos = Vec2f(randomPosX, rayStartY);

			Tile startPosTile = map.getTile(startPos);
			if (map.isTileSolid(startPosTile))	// scan down until there is an open space in tilemap
			{
				continue;
			}
			else
			{
				HitInfo@[] hitInfos;
				if (map.getHitInfosFromRay(startPos, 90.0f, mapHeight, null, hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						HitInfo@ hi = hitInfos[i];
						CBlob@ hitBlob = hi.blob;
						if (hitBlob !is null) // hit blob
						{
							const bool isBlobGround = hitBlob.isCollidable() && hitBlob.getShape().isStatic();
							if (isBlobGround)
							{
								randSpawnPos = Vec2f(hi.hitpos.x, rayStartY);
								groundHeight = hi.hitpos.y;
								foundValidSpawnPos = true;
								break;
							}
						}
						else if (hi.hitpos.y < mapHeight)	// hit valid map pos
						{
							randSpawnPos = Vec2f(hi.hitpos.x, rayStartY);
							groundHeight = hi.hitpos.y;
							foundValidSpawnPos = true;
							break;
						}
					}

					if (foundValidSpawnPos)
					{
						break;
					}
				}
			}
		}
	
		if (foundValidSpawnPos)
		{
			CPlayer@ player = getPlayerByUsername(p_info.username);

			if (player !is null)
			{
				if (blob_name == "")
				{
					blob_name = p_info.blob_name;
				}

				int teamNum = getUniqueTeamNum();

				CBlob @newPlayerBlob = server_CreateBlob(blob_name, teamNum, randSpawnPos);
				newPlayerBlob.server_SetPlayer(player);
				
				player.server_setTeamNum(p_info.team);

				// pack player blob into a crate
				CBlob@ dropPod = server_CreateBlobNoInit("drop_pod");
				if (dropPod !is null)
				{
					dropPod.server_setTeamNum(teamNum);
					dropPod.setPosition(randSpawnPos);
					dropPod.set_u8("frame", 0);

					dropPod.Tag("unpack on land");

					dropPod.set_u16("groundHeight", groundHeight);

					dropPod.Init();

					AttachmentPoint@ containerAP = dropPod.getAttachments().getAttachmentPointByName("CONTAINER");
					if (containerAP !is null)
					{
						dropPod.server_AttachTo(newPlayerBlob, containerAP);
						containerAP.offsetZ = -10.0f;
					}
				}
				
				return newPlayerBlob;
			}
		}

		return null;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		CBlob@[] spawns;
		CBlob@[] teamspawns;

		if (getBlobsByName("ssk_spawn", @spawns))
		{
			for (uint step = 0; step < spawns.length; ++step)
			{
				if (spawns[step].getTeamNum() == s32(p_info.team))
				{
					teamspawns.push_back(spawns[step]);
				}
			}
		}

		if (teamspawns.length > 0)
		{
			int spawnindex = XORRandom(997) % teamspawns.length;
			return teamspawns[spawnindex].getPosition();
		}

		return Vec2f(0, 0);
	}

	int getUniqueTeamNum()
	{
		int[] teamNums;

		CBlob@[] playerBlobs;
		getBlobsByTag("player", @playerBlobs);
		if (getBlobsByTag("player", @playerBlobs))
		{
			for (uint i = 0; i < playerBlobs.length; i++)
			{
				CBlob@ b = playerBlobs[i];
				if (b is null || b.hasTag("dead"))
					continue;

				teamNums.push_back(b.getTeamNum());
			}
		}

		int uniqueTeamNum = 0;
		for(uint i = 0; i < teamNums.length; i++)
		{
			bool foundUniqueNum = true;
			for(uint j = 0; j < teamNums.length; j++)
			{
				if (uniqueTeamNum == teamNums[j])
				{
					foundUniqueNum = false;
					uniqueTeamNum++;
				}
			}	

			if (foundUniqueNum)
			{
				break;
			}	
		}

		return uniqueTeamNum;
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		SSKPlayerInfo@ info = cast < SSKPlayerInfo@ > (p_info);

		if (info is null) { warn("SSK LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "ssk spawn time " + info.username;

		for (uint i = 0; i < SSK_core.teams.length; i++)
		{
			SSKTeamInfo@ team = cast < SSKTeamInfo@ > (SSK_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		SSK_core.rules.set_u8(propname, 255);   //not respawning
		SSK_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		u32 tickspawndelay = u32(SSK_core.spawnTime);

//		print("ADD SPAWN FOR " + player.getUsername());
		SSKPlayerInfo@ info = cast < SSKPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("SSK LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		if (info.team < SSK_core.teams.length)
		{
			SSKTeamInfo@ team = cast < SSKTeamInfo@ > (SSK_core.teams[info.team]);

			info.can_spawn_time = tickspawndelay;
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		SSKPlayerInfo@ info = cast < SSKPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < SSK_core.teams.length; i++)
		{
			SSKTeamInfo@ team = cast < SSKTeamInfo@ > (SSK_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};
