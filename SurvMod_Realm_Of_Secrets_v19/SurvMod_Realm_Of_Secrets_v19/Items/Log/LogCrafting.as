#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit( CBlob@ this ){
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 3));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$log_cage_icon$", "LogCage.png", Vec2f(13, 17), 0);
	{
		ShopItem@ s = addShopItem(this, "Cage", "$log_cage_icon$", "log_cage", "A cage to hold small animals.", false);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		s.spawnNothing = true;
	}
	AddIconToken("$core_icon$", "Core.png", Vec2f(8, 8), 0);
	{
		ShopItem@ s = addShopItem(this, "Core", "$core_icon$", "core", "An empty core used to power contructs when energy is stored inside.", false);
		s.spawnNothing = true;
	}
	AddIconToken("$frame_icon$", "Wood_Head.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Wooden Frame", "$frame_icon$", "humanoid", "A wooden humanoid frame.", false);
		s.spawnNothing = true;
	}
	AddIconToken("$ward_icon$", "Ward.png", Vec2f(8, 17), 0);
	{
		ShopItem@ s = addShopItem(this, "Ward", "$ward_icon$", "ward", "A strange ward that provides auras.", false);
		s.spawnNothing = true;
	}
	
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		if(isServer){
			if(name == "humanoid"){
				CBlob @frame = server_CreateBlob(name,caller.getTeamNum(),caller.getPosition());
				caller.server_Pickup(frame);
				
				int body = BodyType::Wood;
	
				frame.set_u8("head_type", body);
				frame.set_u8("tors_type", body);
				frame.set_u8("marm_type", body);
				frame.set_u8("sarm_type", body);
				frame.set_u8("fleg_type", body);
				frame.set_u8("bleg_type", body);
				
				frame.set_u16("marm_equip",Equipment::Sword);
				frame.set_u16("marm_equip_type",0);
				frame.set_u16("sarm_equip",Equipment::None);
				frame.set_u16("sarm_equip_type",0);
				frame.set_u16("tors_equip",Equipment::None);
				
				frame.Untag("alive");
				frame.set_u8("heart", HeartType::Missing);
			} else {
				caller.server_Pickup(server_CreateBlob(name,caller.getTeamNum(),caller.getPosition()));
			}
			this.server_Die();
		}
	}
}