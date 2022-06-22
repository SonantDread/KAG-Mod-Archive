
//SSK gamemode logic script

#define SERVER_ONLY

#include "SSK_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";

//edit the variables in the config file below to change the basics
// no scripting required!
string cost_config_file = "ssk_vars.cfg";

void Config(SSKCore@ this)
{
	CRules@ rules = getRules();

	//load cfg
	if (rules.exists("ssk_costs_config"))
		cost_config_file = rules.get_string("ssk_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	//game type
	this.gameType = cfg.read_u8("gameType", 0);

	this.starting_stocks = cfg.read_s32("starting_stocks", 3);

	//how long to wait for everyone to spawn in?
	s32 warmUpTimeSeconds = cfg.read_s32("warmUpTimeSeconds", 5);
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
	this.gametime = getGameTime() + this.warmUpTime;

	//how many kills needed to win the match, per player on the smallest team
	this.kills_to_win_per_player = cfg.read_s32("killsPerPlayer", 2);
	this.sudden_death = this.kills_to_win_per_player <= 0;

	//how long for the game to play out?
	f32 gameDurationMinutes = cfg.read_f32("gameDurationMinutes", 5.0f);
	this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes) + this.warmUpTime;

	//spawn after death time - set in gamemode.cfg, or override here
	f32 spawnTimeSeconds = cfg.read_f32("spawnTimeSeconds", rules.playerrespawn_seconds);
	this.spawnTime = (getTicksASecond() * spawnTimeSeconds);

	//how many players have to be in for the game to start
	this.minimum_players_in_team = 1;

	//whether to scramble each game or not
	this.scramble_teams = cfg.read_bool("scramble_teams", true);
	this.all_death_counts_as_kill = cfg.read_bool("dying_counts", true);

	s32 scramble_maps = cfg.read_s32("scramble_maps", -1);
	if(scramble_maps != -1) {
		sv_mapcycle_shuffle = (scramble_maps != 0);
	}

	// modifies if the fall damage velocity is higher or lower - SSK has lower velocity
	rules.set_f32("fall vel modifier", cfg.read_f32("fall_dmg_nerf", 1.3f));
}

//pass stuff to the core from each of the hooks

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	SSKSpawns spawns();
	SSKCore core(this, spawns);
	Config(core);
	core.SetupBases();
	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	this.set_s32("restart_rules_after_game_time", (core.spawnTime < 0 ? 5 : 10) * 30 );

	this.set_bool("warmup ended", false);

	this.set_u16("spawn cooldown", 0);

	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			if (player.getTeamNum() != this.getSpectatorTeamNum())
			{
				string playerName = player.getUsername();
				this.set_u8("playerStocks"+playerName, core.starting_stocks);
				this.Sync("playerStocks"+playerName, true);
			}
		}
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )
{
	if (newteam == this.getSpectatorTeamNum())
	{
		string playerName = player.getUsername();
		this.set_u8("playerStocks"+playerName, 0);
		this.Sync("playerStocks"+playerName, true);
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	if (player !is null)
	{	
		string playerName = player.getUsername();
		if (this.isMatchRunning())
		{
			this.set_u8("playerStocks"+playerName, 0);
		}
		else
		{
			SSKCore@ core;
			if (this.get("core", @core))
				this.set_u8("playerStocks"+playerName, core.starting_stocks);
		}

		this.Sync("playerStocks"+playerName, true);

		// sync stocks to player who just joined
		for (int i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p !is null)
			{
				string pName = player.getUsername();
				this.SyncToPlayer("playerStocks"+pName, player);
			}
		}
	}	
}