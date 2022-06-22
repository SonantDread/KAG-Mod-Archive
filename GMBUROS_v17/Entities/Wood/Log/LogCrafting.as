#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "EquipmentCommon.as";


void onInit( CBlob@ this ){
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Carve");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	
	AddIconToken("$log_cage_icon$", "LogCage.png", Vec2f(13, 17), 0);
	{
		ShopItem@ s = addShopItem(this, "Cage", "$log_cage_icon$", "log_cage", "A cage to hold small animals.", false);
		s.spawnNothing = true;
	}
	AddIconToken("$core_icon$", "Core.png", Vec2f(8, 8), 0);
	{
		ShopItem@ s = addShopItem(this, "Core", "$core_icon$", "core", "An empty core used to power contructs when energy is stored inside.", false);
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
			caller.server_Pickup(server_CreateBlob(name,caller.getTeamNum(),caller.getPosition()));
			this.server_Die();
		}
	}
}