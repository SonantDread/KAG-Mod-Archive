// BuilderShop.as
#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{

AddIconToken( "$dirtdrill$", "dirtdrill.png", Vec2f(16,16), 0 );
AddIconToken( "$gaslantern$", "gaslantern.png", Vec2f(16,16), 0 );
AddIconToken( "$handsaw$", "handsaw.png", Vec2f(16,16), 0 );
AddIconToken( "$drill$", "drill.png", Vec2f(16,16), 0 );
AddIconToken( "$statue1$", "statue1.png", Vec2f(16,16), 0 );
AddIconToken( "$statue2$", "statue2.png", Vec2f(16,16), 0 );
AddIconToken( "$statue3$", "statue3.png", Vec2f(16,16), 0 );
AddIconToken( "$statue4$", "BatIcon.png", Vec2f(16,16), 0 );

	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Gas Lantern", "$gaslantern$", "gaslantern", "Gas lantern to light the darkness", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", "Bucket to fill with water that puts out fire", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", "Sponge to drain the water that spills over the ground", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", "Boulder, get close and personal crushing zombie heads", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", "Trampoline, to access higher levels, not reachable before", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "Saw used to cut logs into wood, save for humans", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "Drill, used to drill the ground", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	//{
		//ShopItem@ s = addShopItem(this, "Dirt Drill", "$dirtdrill$", "dirtdrill", "Drills longer and cools faster, but drills only dirt.", false);
		//AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 300);
	//}

	//{
	//	ShopItem@ s = addShopItem(this, "Hand Saw", "$handsaw$", "handsaw", "Mobile saw for cutting wood", false);
	//	AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	//}
	{
		ShopItem@ s = addShopItem(this, "Praying Statue", "$statue1$", "statue1", "Praying Statue", false, true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Angel Statue", "$statue2$", "statue2", "Angel Statue", false, true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Gollum Statue", "$statue3$", "statue3", "Gollum Statue", false, true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Bat Statue", "$statue4$", "statue4", "Bat Statue", false, true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
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

		if (!getNet().isServer()) return; /////////////////////// server only past here

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

			if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
			}
		}
	}
}

