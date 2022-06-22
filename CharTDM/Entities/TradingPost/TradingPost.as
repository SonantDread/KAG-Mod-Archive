// Builder Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);
	AddIconToken("$tank$", "TankIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$zeppelin$", "ZeppelinIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$APC$", "APCIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$megatank$", "MegaTankIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$armoredt$", "ArmoredTIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_shells$", "mat_shells.png", Vec2f(16, 16), 0);
	AddIconToken("$mat_bolterarrows$", "Materials.png", Vec2f(16, 16), 27);
	AddIconToken("$mounted_cannon$", "MountedCannon.png", Vec2f(16, 16), 4);
	AddIconToken("$quarters_beer$", "Quarters.png", Vec2f(24, 24), 7);
	AddIconToken("$quarters_meal$", "Quarters.png", Vec2f(48, 24), 2);
	AddIconToken("$quarters_egg$", "Quarters.png", Vec2f(24, 24), 8);
	AddIconToken("$quarters_burger$", "Quarters.png", Vec2f(24, 24), 9);
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 2);
	AddIconToken("$musicdisc$", "MusicDisc.png", Vec2f(8, 8), 0);
	AddIconToken("$rest$", "InteractionIcons.png", Vec2f(32, 32), 29);
	AddIconToken("$megaboat$", "VehicleIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$covered_dinghy$", "VehicleIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$clusterbomb$", "ClusterBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$trap$", "Trap.png", Vec2f(16, 16), 0);
	AddIconToken("$molotov$", "Molotov.png", Vec2f(16, 16), 0);
	AddIconToken("$contactbomb$", "ContactBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$bombsatchel$", "BombSatchel.png", Vec2f(16, 16), 0);

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(9,9));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	

	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", "archer arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", "stunning arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", "good on wood structures", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", "good on stone structures", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", "small bomb", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", "stunning bomb", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "self triggered bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", "large bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "Contact Bomb", "$contactbomb$", "mat_contactbomb", "Explodes on contact", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Molotov", "$molotov$", "mat_molotov", "burns people and objects", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "self trigered bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Satchel", "$bombsatchel$", "bomb_satchel", "sticky bomb", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Cluster Bomb", "$clusterbomb$", "mat_clusterbomb", "Explodes into smaller bombs", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Trap", "$trap$", "mat_trap", "Used for weakening enemies", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
		{
		ShopItem@ s = addShopItem(this, "Beer - 1 Heart", "$quarters_beer$", "beer", "A refreshing mug of beer.", false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Meal - Full Health", "$quarters_meal$", "meal", "A hearty meal to get you back on your feet.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Egg - Full Health", "$quarters_egg$", "egg", "A suspiciously undercooked egg, maybe it will hatch.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Burger - Full Health", "$quarters_burger$", "food", "A burger to go.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + "a small boat");
		AddRequirement(s.requirements, "coin", "", "Coins", 10);

	}
	{
		ShopItem@ s = addShopItem(this, "Covered Dinghy", "$covered_dinghy$", "covered_dinghy", "$covered_dinghy$\n\n\n" + "a small boat with a mounted bow");
		AddRequirement(s.requirements, "coin", "", "Coins", 15);


		s.crate_icon = 0;
	}
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + "ramming speed", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);

		s.crate_icon = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + "a mobile war spawn", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.crate_icon = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Mega Boat", "$megaboat$", "megaboat", "$megaboat$\n\n\n" + "upgraded warboat", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 0;
	}
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + "flings stuff", false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + "A spawn vehicle with a large bow", false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "bomber", "$bomber$", "bomber", "$bomber$\n\n\n" + "light weight flight travel", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "zeppelin", "$zeppelin$", "zeppelin", "$zepplin$\n\n\n" + "heavy air vehivle made for battle" , false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "megatank", "$megatank$", "megatank", "$megatank$\n\n\n" + "A large tank", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Armored Transport", "$armoredt$", "armoredt", "$armoredtk$\n\n\n" + "A large transport", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "tank", "$tank$", "tank", "$tank$\n\n\n" + "great for cushing people", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "APC", "$APC$", "APC", "$APC$\n\n\n" + "great gun weak at the cost of speed", false, true);
		s.crate_icon = 0;
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
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
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "a light", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", "puts out fires when full", false);
				AddRequirement(s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", "soaks up water", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 10 );
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", "crush people", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 25 );
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", "bouncy", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "cuts things", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", "Storage and Stuff", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}
this.set_string("required class", "builder");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/ );
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
	
	bool isServer = (getNet().isServer());
	
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			if (name == "beer")
			{
				// TODO: gulp gulp sound
				if (isServer)
				{
					callerBlob.server_Heal(1.0f);
				}
			}
			else if (name == "meal")
			{
				this.getSprite().PlaySound("/Eat.ogg");
				if (isServer)
				{
					callerBlob.server_SetHealth(callerBlob.getInitialHealth());
				}
			}
		}
	}
}
