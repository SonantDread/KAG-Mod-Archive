#include "TradingCommon.as"
#include "Descriptions.as"

#define SERVER_ONLY

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob.getName() == "tradingpost")
	{
		MakeTradeMenu(blob);
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
		if(cost == 1)AddRequirement(item.reqs, "blob", "coin", "Coin", cost);
		else AddRequirement(item.reqs, "blob", "coin", "Coins", cost);
		item.buyIntoInventory = true;
	}
	return item;
}

void MakeTradeMenu(CBlob@ trader)
{

	// build menu
	CreateTradeMenu(trader, Vec2f(4, 3), "Trader");

	//
	//addTradeSeparatorItem(trader, "$MENU_GENERIC$", Vec2f(3, 1));

	//utility stuff
	addItemForCoin(trader, "Burger", 1, true, "$food$", "food", Descriptions::food);
	addItemForCoin(trader, "Drill", 2, true, "$drill$", "drill", Descriptions::drill);
	addItemForCoin(trader, "Mounted Bow", 3, true, "$mounted_bow$", "mounted_bow", Descriptions::mounted_bow);
	//knighty stuff
	addItemForCoin(trader, "Bomb", 1, true, "$mat_bombs$", "mat_bombs", Descriptions::bomb);
	addItemForCoin(trader, "Water Bomb", 1, true, "$mat_waterbombs$", "mat_waterbombs", Descriptions::waterbomb);
	addItemForCoin(trader, "Mine", 2, true, "$mine$", "mine", Descriptions::mine);
	addItemForCoin(trader, "Keg", 5, true, "$keg$", "keg", Descriptions::keg);
	//archery stuff
	addItemForCoin(trader, "Arrows", 1, true, "$mat_arrows$", "mat_arrows", Descriptions::arrows);
	addItemForCoin(trader, "Water Arrows", 1, true, "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows);
	addItemForCoin(trader, "Fire Arrows", 1, true, "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows);
	addItemForCoin(trader, "Bomb Arrow", 2, true, "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows);
	
	
	

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