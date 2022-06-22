#include "TradingCommon.as"
#include "Descriptions.as"

#define SERVER_ONLY

int coinsOnDamageAdd = 5;
int coinsOnKillAdd = 15;
int coinsOnDeathLose = 5;
int min_coins = 50;
int max_coins = 500;

//
string cost_config_file = "tdm_vars.cfg";
bool kill_traders_and_shops = false;

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "tradingpost")
	{
		if (kill_traders_and_shops)
		{
			blob.server_Die();
			KillTradingPosts();
		}
		else
		{
			MakeTradeMenu(blob);
		}
	}
}

TradeItem@ addItemForCoin(CBlob@ this, const string &in name, int cost, const bool instantShipping, const string &in iconName, const string &in configFilename, const string &in description)
{
	if(cost <= 0) {
		return null;
	}

	TradeItem@ item = addTradeItem(this, name, 0, instantShipping, iconName, configFilename, description);
	if (item !is null)
	{
		AddRequirement(item.reqs, "coin", "", "Coins", cost);
		item.buyIntoInventory = true;
	}
	return item;
}

void MakeTradeMenu(CBlob@ trader)
{
	//load config

	if (getRules().exists("tdm_costs_config"))
		cost_config_file = getRules().get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	s32 cost_bombs = cfg.read_s32("cost_bombs", 15);
	s32 cost_waterbombs = cfg.read_s32("cost_waterbombs", 25);
	s32 cost_keg = cfg.read_s32("cost_keg", 35);
	s32 cost_molotov = cfg.read_s32("cost_molotov", 25);
	s32 cost_firemine = cfg.read_s32("cost_firemine", 20);
	s32 cost_slidemine = cfg.read_s32("cost_slidemine", 25);
	s32 cost_mine = cfg.read_s32("cost_mine", 20);
	s32 cost_minimine = cfg.read_s32("cost_minimine", 7);
	s32 cost_arrows = cfg.read_s32("cost_arrows", 0);
	s32 cost_waterarrows = cfg.read_s32("cost_waterarrows", 20);
	s32 cost_firearrows = cfg.read_s32("cost_firearrows", 15);
	s32 cost_bombarrows = cfg.read_s32("cost_bombarrows", 30);
	s32 cost_burger = cfg.read_s32("cost_burger", 20);
	s32 cost_saw = cfg.read_s32("cost_saw", 35);
	s32 cost_fiks = cfg.read_s32("cost_fiks", 35);
	s32 cost_stim = cfg.read_s32("cost_stim", 40);
	s32 cost_crak = cfg.read_s32("cost_crak", 20);
	s32 cost_catapult = cfg.read_s32("cost_catapult", 50);
	s32 cost_acidjar = cfg.read_s32("cost_acidjar", 20);
	s32 cost_barricades = cfg.read_s32("cost_barricades", 20);
	s32 cost_boomerangs = cfg.read_s32("cost_boomerangs", 0);
	s32 cost_bullets = cfg.read_s32("cost_bullets", 0);
	s32 cost_firespear = cfg.read_s32("cost_firespear", 15);
	s32 cost_medkits = cfg.read_s32("cost_medkits", -1);
	s32 cost_spears = cfg.read_s32("cost_spears", 0);
	s32 cost_juggernauthammer = cfg.read_s32("cost_juggernauthammer", 500);
	s32 cost_waterjar = cfg.read_s32("cost_waterjug", -1);
	s32 cost_jumper = cfg.read_s32("cost_jumper", 35);

	s32 menu_width = cfg.read_s32("trade_menu_width", 3);
	s32 menu_height = cfg.read_s32("trade_menu_height", 5);

	// build menu
	CreateTradeMenu(trader, Vec2f(menu_width, menu_height), "Buy weapons");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	//knighty stuff
	addItemForCoin(trader, "Bomb", cost_bombs, true, "$mat_bombs$", "mat_bombs", Descriptions::bomb);
	addItemForCoin(trader, "Water Bomb", cost_waterbombs, true, "$mat_waterbombs$", "mat_waterbombs", Descriptions::bomb);
	addItemForCoin(trader, "Keg", cost_keg, true, "$keg$", "keg", Descriptions::bomb);
	addItemForCoin(trader, "Molotov", cost_molotov, true, "$molotov$", "molotov", Descriptions::bomb);
	addItemForCoin(trader, "Fire mine", cost_firemine, true, "$firemine$", "firemine", Descriptions::bomb);
	addItemForCoin(trader, "Slide mine", cost_slidemine, true, "$slidemine$", "slidemine", Descriptions::bomb);
	addItemForCoin(trader, "Mine", cost_mine, true, "$mine$", "mine", Descriptions::bomb);
	addItemForCoin(trader, "Mini Mine", cost_minimine, true, "$minimine$", "minimine", Descriptions::bomb);
	addItemForCoin(trader, "Arrows", cost_arrows, true, "$mat_arrows$", "mat_arrows", Descriptions::bomb);
	addItemForCoin(trader, "Water Arrows", cost_waterarrows, true, "$mat_waterarrows$", "mat_waterarrows", Descriptions::bomb);
	addItemForCoin(trader, "Fire Arrows", cost_firearrows, true, "$mat_firearrows$", "mat_firearrows", Descriptions::bomb);
	addItemForCoin(trader, "Bomb Arrows", cost_bombarrows, true, "$mat_bombarrows$", "mat_bombarrows", Descriptions::bomb);
	addItemForCoin(trader, "Burger", cost_burger, true, "$food$", "food", Descriptions::bomb);
	addItemForCoin(trader, "Saw", cost_saw, true, "$saw$", "saw", Descriptions::bomb);
	addItemForCoin(trader, "Fiks", cost_fiks, true, "$fiks$", "fiks", Descriptions::bomb);
	addItemForCoin(trader, "Stim", cost_stim, true, "$stim$", "stim", Descriptions::bomb);
	addItemForCoin(trader, "Barricades", cost_barricades, true, "$mat_barricades$", "mat_barricades", Descriptions::bomb);
	addItemForCoin(trader, "Boomerangs", cost_boomerangs, true, "$mat_boomerangs$", "mat_boomarangs", Descriptions::bomb);
	addItemForCoin(trader, "Bullets", cost_bullets, true, "$mat_bullets$", "mat_bullets", Descriptions::bomb);
	addItemForCoin(trader, "Jumper", cost_jumper, true, "$jumper$", "jumper", Descriptions::bomb);

}

// load coins amount

void Reset(CRules@ this)
{
	//load the coins vars now, good a time as any
	if (this.exists("tdm_costs_config"))
		cost_config_file = this.get_string("tdm_costs_config");

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(cost_config_file);

	coinsOnDamageAdd = cfg.read_s32("coinsOnDamageAdd", coinsOnDamageAdd);
	coinsOnKillAdd = cfg.read_s32("coinsOnKillAdd", coinsOnKillAdd);
	coinsOnDeathLose = cfg.read_s32("coinsOnDeathLose", coinsOnDeathLose);
	min_coins = cfg.read_s32("minCoinsOnRestart", min_coins);
	max_coins = cfg.read_s32("maxCoinsOnRestart", max_coins);

	kill_traders_and_shops = !(cfg.read_bool("spawn_traders_ever", true));

	if (kill_traders_and_shops)
	{
		KillTradingPosts();
	}

	//clamp coin vars each round
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		s32 coins = player.getCoins();
		if (min_coins >= 0) coins = Maths::Max(coins, min_coins);
		if (max_coins >= 0) coins = Maths::Min(coins, max_coins);
		player.server_setCoins(coins);
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


void KillTradingPosts()
{
	CBlob@[] tradingposts;
	bool found = false;
	if (getBlobsByName("tradingpost", @tradingposts))
	{
		for (uint i = 0; i < tradingposts.length; i++)
		{
			CBlob @b = tradingposts[i];
			b.server_Die();
		}
	}
}

// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + coinsOnKillAdd);
			}
		}

		victim.server_setCoins(victim.getCoins() - coinsOnDeathLose);
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (attacker !is null && attacker !is victim)
	{
		attacker.server_setCoins(attacker.getCoins() + DamageScale * coinsOnDamageAdd / this.attackdamage_modifier);
	}

	return DamageScale;
}
