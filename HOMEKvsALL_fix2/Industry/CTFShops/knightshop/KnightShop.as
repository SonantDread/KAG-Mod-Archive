// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	int team_num = this.getTeamNum();

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::bomb);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterbomb);
	}
	AddIconToken("$teleportbomb$", "TeleportBomb.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Teleport Bomb", "$teleportbomb$", "mat_teleportbombs", "A bomb that teleports you to where it explodes.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	AddIconToken("$clustercharge$", "ClusterCharge.png",Vec2f(16, 16), 4);
	{
		ShopItem@ s = addShopItem(this, "Cluster Charge", "$clustercharge$", "clustercharge", "Explosive that sticks to walls. Once stuck, can't be picked up by enemies.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", getTeamIcon("mine", "Mine.png", team_num, Vec2f(16, 16), 1), "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::mine);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::keg);
	}
	AddIconToken("$minikeg$", "MiniKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Mini-Keg", "$minikeg$", "minikeg", "A smaller keg, can be used by anyone.\n50% weaker than a normal keg.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}	
	AddIconToken("$instakeg$", "InstaKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Instant Exploding Keg", "$instakeg$", "instakeg", "A Keg that instantly explodes.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 160);
	}
	
	AddIconToken("$bouncykeg$", "BouncyKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Bouncy Keg", "$bouncykeg$", "bouncykeg", "A Keg with springs attached.\nCareful of the backfire.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	
	AddIconToken("$rocketkeg$", "RocketKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Firework Keg", "$rocketkeg$", "rocketkeg", "A Keg with a built in thruster, can be aimed. Goes fast, but not always where you want it to", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	
	AddIconToken("$trikeg$", "TriKeg.png",Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Triple Keg", "$trikeg$", "trikeg", "Three Mini-Kegs packed into one cluster Keg.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 140);
	}
	AddIconToken("$superkeg$", "Superkeg.png", Vec2f(16, 16), 0);
	{
        ShopItem@ s = addShopItem(this, "Homek Keg", "$superkeg$", "superkeg", "A Keg infused with the magic of Homek God.\nUse against Australians.", false);
        AddRequirement(s.requirements, "coin", "", "Coins", 250);
    }
	AddIconToken("$floatkeg$", "Floatkeg.png", Vec2f(16, 16), 0);
	{
        ShopItem@ s = addShopItem(this, "Flying Keg", "$floatkeg$", "floatkeg", "Literally a flying keg.\nGrapple it for massive pepega moment.", false);
        AddRequirement(s.requirements, "coin", "", "Coins", 150);
    }
	AddIconToken("$voidkeg$", "VoidKeg.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Void Keg", "$voidkeg$", "voidkeg", "This keg's explosion creates a rift that sucks in and damages everything close to it.", false);
        AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	AddIconToken("$exploding_tick$", "Tick.png", Vec2f(16, 16), 1);
	{
		ShopItem@ s = addShopItem(this, "Exploding Tick", "$exploding_tick$", "tick", "A mine on legs. Runs into enemies and explodes, dealing 3 hearts of damage.", false);
        AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
