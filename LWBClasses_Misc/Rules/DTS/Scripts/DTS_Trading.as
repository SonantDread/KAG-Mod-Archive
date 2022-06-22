#include "TradingCommon.as"
#include "Descriptions.as"
#include "GameplayEvents.as"
#include "DTSConfig.as"

#define SERVER_ONLY

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
	// build menu
	CreateTradeMenu(trader, Vec2f(DTSConfig::menu_width, DTSConfig::menu_height), "Buy weapons");

	//
	addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	addItemForCoin(trader, "Bomb", DTSConfig::cost_bombs, true, "$mat_bombs$", "mat_bombs", Descriptions::bomb);
	addItemForCoin(trader, "Water Bomb", DTSConfig::cost_waterbombs, true, "$mat_waterbombs$", "mat_waterbombs", Descriptions::waterbomb);
	addItemForCoin(trader, "Keg", DTSConfig::cost_keg, true, "$keg$", "keg", Descriptions::keg);
	addItemForCoin(trader, "Spears", DTSConfig::cost_spears, true, "$mat_spears$", "mat_spears", "Spare Spears for Spearman. Throw them to enemies.");
	addItemForCoin(trader, "Fire Spear", DTSConfig::cost_firespears, true, "$mat_firespears$", "mat_firespears", "Fire Spear for Spearman. Make spear attacking or thrown spear ignitable once.");
	addItemForCoin(trader, "Poison Spears", DTSConfig::cost_poisonspears, true, "$mat_poisonspears$", "mat_poisonspears", "Poison Spears for Spearman. Make spear attacking or thrown spear poisonable twice.");
	addItemForCoin(trader, "Smoke Ball", DTSConfig::cost_smokeball, true, "$mat_smokeball$", "mat_smokeball", "Smoke Ball for Assassin. Can stun nearly enemies.");
	addItemForCoin(trader, "Mine", DTSConfig::cost_mine, true, "$mine$", "mine", Descriptions::mine);
	//archery stuff
	addItemForCoin(trader, "Arrows", DTSConfig::cost_arrows, true, "$mat_arrows$", "mat_arrows", Descriptions::arrows);
	addItemForCoin(trader, "Water Arrows", DTSConfig::cost_waterarrows, true, "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows);
	addItemForCoin(trader, "Fire Arrows", DTSConfig::cost_firearrows, true, "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows);
	addItemForCoin(trader, "Bomb Arrow", DTSConfig::cost_bombarrows, true, "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows);
	addItemForCoin(trader, "Poison Arrows", DTSConfig::cost_poisonarrows, true, "$mat_poisonarrows$", "mat_poisonarrows", "Poison arrows for Archer and Crossbowman.");
	addItemForCoin(trader, "Bullets", DTSConfig::cost_bullets, true, "$mat_bullets$", "mat_bullets", "Lead ball and gunpowder in a paper for Musketman.");
	addItemForCoin(trader, "Barricade ", DTSConfig::cost_barricades, true, "$mat_barricades$", "mat_barricades", "Ballicade frames for Musketman.");
	//utility stuff
	addItemForCoin(trader, "Wood", DTSConfig::cost_wood, true, "$mat_wood$", "mat_wood", Descriptions::wood);
	addItemForCoin(trader, "Stone", DTSConfig::cost_stone, true, "$mat_stone$", "mat_stone", Descriptions::stone);
	addItemForCoin(trader, "Med Kit", DTSConfig::cost_medkit, true, "$mat_medkits$", "mat_medkits", "Med kit for Medic. Can be used 10 times.");
	addItemForCoin(trader, "Water in a Jar", DTSConfig::cost_waterjar, true, "$mat_waterjar$", "mat_waterjar", "Water for Medic Spray.");
	addItemForCoin(trader, "Poison in a Jar", DTSConfig::cost_poisonjar, true, "$mat_poisonjar$", "mat_poisonjar", "Poison for Medic Spray.");
	addItemForCoin(trader, "Acid in a Jar", DTSConfig::cost_acidjar, true, "$mat_acidjar$", "mat_acidjar", "Acid for Medic Spray.\nCan damage blocks and enemies.");
	addItemForCoin(trader, "Sponge", DTSConfig::cost_sponge, true, "$sponge$", "sponge", Descriptions::sponge);
	addItemForCoin(trader, "Mounted Bow", DTSConfig::cost_mountedbow, true, "$mounted_bow$", "mounted_bow", Descriptions::mounted_bow);
	addItemForCoin(trader, "Drill", DTSConfig::cost_drill, true, "$drill$", "drill", Descriptions::drill);
	addItemForCoin(trader, "Boulder", DTSConfig::cost_boulder, true, "$boulder$", "boulder", Descriptions::boulder);
	addItemForCoin(trader, "Burger", DTSConfig::cost_burger, true, "$food$", "food", Descriptions::food);
	//vehicles
	addItemForCoin(trader, "Catapult", DTSConfig::cost_catapult, false, "$catapult$", "catapult", Descriptions::catapult);
	addItemForCoin(trader, "Ballista", DTSConfig::cost_ballista, false, "$ballista$", "ballista", Descriptions::ballista);

}

// load coins amount

void Reset(CRules@ this)
{
	kill_traders_and_shops = !(DTSConfig::spawn_traders_ever);

	if (kill_traders_and_shops)
	{
		KillTradingPosts();
	}

	//reset coins
	for (int i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		player.server_setCoins(0);
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
				killer.server_setCoins(killer.getCoins() + DTSConfig::coinsOnKillAdd);
			}
		}

		victim.server_setCoins(victim.getCoins() - DTSConfig::coinsOnDeathLose);
		CBlob@ blob = victim.getBlob();
		if (blob !is null)
			server_DropCoins(blob.getPosition(), XORRandom(DTSConfig::coinsOnDeathLose));
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (attacker !is null && attacker !is victim)
	{
		attacker.server_setCoins(attacker.getCoins() + DamageScale * DTSConfig::coinsOnDamageAdd / this.attackdamage_modifier);
	}

	return DamageScale;
}

// from CTF
// coins for various game events
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	//only important on server
	if (!getNet().isServer())
		return;

	if (cmd == getGameplayEventID(this))
	{
		GameplayEvent g(params);

		CPlayer@ p = g.getPlayer();
		if (p !is null)
		{
			u32 coins = 0;

			switch (g.getType())
			{
				case GE_hit_vehicle:

				{
					g.params.ResetBitIndex();
					f32 damage = g.params.read_f32();
					coins = DTSConfig::coinsOnHitSiege * damage;
				}

				break;

				case GE_kill_vehicle:
					coins = DTSConfig::coinsOnKillSiege;
					break;
					
				case GE_hit_statue:

				{
					g.params.ResetBitIndex();
					f32 damage = g.params.read_f32();
					coins = DTSConfig::coinsOnHitStatue * damage;
				}

				break;

				case GE_kill_statue:
					coins = DTSConfig::coinsOnKillStatue;
					break;
				//////////////////////////////////////////////////
				case GE_medic_heal:

				{
					g.params.ResetBitIndex();
					f32 heal = g.params.read_f32();
					coins = DTSConfig::coinsOnMedicHeal * heal;
				}

				break;
				//////////////////////////////////////////////////
			}

			if (coins > 0)
			{
				p.server_setCoins(p.getCoins() + coins);
			}
		}
	}
}
