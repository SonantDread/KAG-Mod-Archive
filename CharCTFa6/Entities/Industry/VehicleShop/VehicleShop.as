// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 200;
const s32 cost_ballista_ammo = 100;
const s32 cost_ballista_ammo_upgrade_gold = 100;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);
	AddIconToken("$tank$", "TankIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$zeppelin$", "ZeppelinIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$APC$", "APCIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$megatank$", "MegaTankIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$armoredt$", "ArmoredTIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_shells$", "mat_shells.png", Vec2f(16, 16), 0);
	AddIconToken("$mounted_cannon$", "MountedCannon.png", Vec2f(16, 16), 4);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 5));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + "flings stuff", false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + "A spawn vehicle with a large bow", false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "bomber", "$bomber$", "bomber", "$bomber$\n\n\n" + "light weight flight travel", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 175);
	}
	{
		ShopItem@ s = addShopItem(this, "zeppelin", "$zeppelin$", "zeppelin", "$zepplin$\n\n\n" + "heavy air vehivle made for battle" , false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "megatank", "$megatank$", "megatank", "$megatank$\n\n\n" + "A large tank", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Armored Transport", "$armoredt$", "armoredt", "$armoredtk$\n\n\n" + "A large transport", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "tank", "$tank$", "tank", "$tank$\n\n\n" + "great for cushing people", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "APC", "$APC$", "APC", "$APC$\n\n\n" + "great gun weak at the cost of speed", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 175);
	}
	{
		ShopItem@ s = addShopItem(this, "Mounted Bow", "$mounted_bow$", "mounted_bow", "$mounted_bow$\n\n\n" + "a mobile bow station", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Mounted Cannon", "$mounted_cannon$", "mounted_cannon", "$mounted_cannon$\n\n\n" + "fires small bombs", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 55);
	}
	{
		ShopItem@ s = addShopItem(this, "Bolter Arrows", "$mat_bolterarrows$", "mat_bolterarrows", "APC ammo", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{

		ShopItem@ s = addShopItem(this, "Cannon Ammo", "$mat_shells$", "mat_shells", "$mat_shells$\n\n\n" + "mounted gun ammo", false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", 25 );
	}
	{

		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + "ballista ammo", false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold);
		AddRequirement(s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
		}
	}
}



