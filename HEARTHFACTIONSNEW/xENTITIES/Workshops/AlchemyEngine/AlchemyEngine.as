// AlchemyEngine.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "alchemist");
	
	//{
	//	ShopItem@ s = addShopItem(this, "Cult Offering", "$cultoffering$", "cultoffering", "An offering to the Fire.", true);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 150);
	//}
	{
		ShopItem@ s = addShopItem(this, "Cataclysm Vial", "$cataclysmvial$", "cataclysmvial", "It's very hot to the touch.", true);
	//	AddRequirement(s.requirements, "blob", "minicataclysmvial", "Mini Cataclysm Vial", 1);
		AddRequirement(s.requirements, "blob", "sunstone", "Sunstone", 5);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Mini Cataclysm Vial", "$minicataclysmvial$", "minicataclysmvial", "It's very warm.", true);
	//	AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 15);
	//	AddRequirement(s.requirements, "blob", "firefountainvial", "Fire Fountain Vial", 1);
	//}
	{
		ShopItem@ s = addShopItem(this, "Fire Fountain Vial", "$firefountainvial$", "firefountainvial", "It's lukewarm.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
		AddRequirement(s.requirements, "blob", "molotov", "Molotov", 1);
		AddRequirement(s.requirements, "blob", "glassvial", "Glass Vial", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Glass Vial", "$glassvial$", "glassvial", "A pristine clear glass.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Healing Vial", "$healingvial$", "healingvial", "Capable of restoring even the deepest wounds!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
		AddRequirement(s.requirements, "blob", "glassvial", "Glass Vial", 1);
	}	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
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

		if(!getNet().isServer()) return; /////////////////////// server only past here

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