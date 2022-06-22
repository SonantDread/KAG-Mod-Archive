
#include "LimbsCommon.as";
#include "Requirements.as"
#include "ShopCommon.as";

void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	
	this.set_u8("loaded_leather",0);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Tailer");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		AddIconToken("$shirt_icon$", "Shirt_Icon.png", Vec2f(24, 24), 0);
		ShopItem@ s = addShopItem(this, "Shirt", "$shirt_icon$", "shirt", "Create a shirt from the leather");
		s.spawnNothing = true;
	}
	{
		AddIconToken("$hat_icon$", "Hat_Icon.png", Vec2f(24, 24), 2);
		ShopItem@ s = addShopItem(this, "Hat", "$hat_icon$", "hat", "Create a hat from the leather");
		s.spawnNothing = true;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(this.get_u8("loaded_leather") == 0){
		this.set_bool("shop available", false);
	
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("use"), "Convert corpse into Leather", params);
		//if(button !is null)if(!caller.hasBlob("fibre", 1))button.SetEnabled(false);
	} else {
		this.set_bool("shop available", true);
		
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,-8), this, this.getCommandID("use"), "Remove leather", params);
	}
}

void onTick(CSprite @this){

	this.SetFrame(this.getBlob().get_u8("loaded_leather"));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			if(getNet().isServer()){
				int leather = this.get_u8("loaded_leather");
				if(leather == 0){
					CBlob @held = caller.getCarriedBlob();
					if(held !is null){
						if(held.getName() == "bison_leather"){
							this.set_u8("loaded_leather",1);
							held.server_Die();
						}
						if(held.getName() == "human_leather" || held.getName() == "flesh_limb"){
							this.set_u8("loaded_leather",2);
							held.server_Die();
						}
						if(held.getName() == "chicken" || held.getName() == "chicken_leather"){
							this.set_u8("loaded_leather",3);
							held.server_Die();
						}
						if(held.getName() == "humanoid"){
							LimbInfo@ limbs;
							if(held.get("limbInfo", @limbs)){
								if(isFlesh(limbs.Torso)){
									this.set_u8("loaded_leather",2);
									held.server_Die();
								}
							}
						}
						this.Sync("loaded_leather",true);
					}
				} else {
					if(leather == 1)server_CreateBlob("bison_leather",-1,this.getPosition());
					if(leather == 2)server_CreateBlob("human_leather",-1,this.getPosition());
					if(leather == 3)server_CreateBlob("chicken_leather",-1,this.getPosition());
					
					this.set_u8("loaded_leather",0);
					this.Sync("loaded_leather",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		{
			if(!this.hasTag("shop disabled")){
				int leather = this.get_u8("loaded_leather");
				
				if(isServer() && leather > 0){
					if(name == "shirt"){
						if(leather == 1)server_CreateBlob("bison_shirt",-1,this.getPosition());
						if(leather == 2)server_CreateBlob("human_shirt",-1,this.getPosition());
						if(leather == 3)server_CreateBlob("chicken_shirt",-1,this.getPosition());
					}
					if(name == "pants"){
						if(leather == 1)server_CreateBlob("bison_pants",-1,this.getPosition());
						if(leather == 2)server_CreateBlob("human_pants",-1,this.getPosition());
						if(leather == 3)server_CreateBlob("chicken_pants",-1,this.getPosition());
					}
					if(name == "hat"){
						if(leather == 1)server_CreateBlob("bison_hat",-1,this.getPosition());
						if(leather == 2)server_CreateBlob("western_hat",-1,this.getPosition());
						if(leather == 3)server_CreateBlob("chicken_hat",-1,this.getPosition());
					}
					
					this.set_u8("loaded_leather",0);
					this.Sync("loaded_leather",true);
				}
			}
			
		}
	}
}