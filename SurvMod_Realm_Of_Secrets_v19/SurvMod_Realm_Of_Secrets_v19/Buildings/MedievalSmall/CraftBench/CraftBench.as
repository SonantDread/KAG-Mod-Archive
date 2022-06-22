// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "LimbsCommon.as"
#include "EquipmentCommon.as"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);
	
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Craft");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", WARCosts::sponge_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", WARCosts::boulder_stone);
	}
	
	AddIconToken("$log_cage_icon$", "LogCage.png", Vec2f(13, 17), 0);
	{
		ShopItem@ s = addShopItem(this, "Cage", "$log_cage_icon$", "log_cage", "A cage to hold small animals.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
	}
	AddIconToken("$core_icon$", "Core.png", Vec2f(8, 8), 0);
	{
		ShopItem@ s = addShopItem(this, "Core", "$core_icon$", "core", "An empty core used to power contructs when energy is stored inside.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
	}
	AddIconToken("$frame_icon$", "Wood_Head.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Wooden Frame", "$frame_icon$", "humanoid", "A wooden humanoid frame.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 30);
	}
	AddIconToken("$medieval_hammer_icon$", "MedievalHammerIcon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Sturdy Hammer", "$medieval_hammer_icon$", "medieval_hammer", "A better hammer to create better structures.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
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
			CBlob@ itemBlob = getBlobByNetworkID(item);
			if (itemBlob is null)
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
			
			if(name == "humanoid"){
				int body = BodyType::Wood;
	
				itemBlob.set_u8("head_type", body);
				itemBlob.set_u8("tors_type", body);
				itemBlob.set_u8("marm_type", body);
				itemBlob.set_u8("sarm_type", body);
				itemBlob.set_u8("fleg_type", body);
				itemBlob.set_u8("bleg_type", body);
				
				itemBlob.set_u16("marm_equip",Equipment::Sword);
				itemBlob.set_u16("marm_equip_type",0);
				itemBlob.set_u16("sarm_equip",Equipment::None);
				itemBlob.set_u16("sarm_equip_type",0);
				itemBlob.set_u16("tors_equip",Equipment::None);
				
				itemBlob.Untag("alive");
				itemBlob.set_u8("heart", HeartType::Missing);
			}
		}
	}
}
