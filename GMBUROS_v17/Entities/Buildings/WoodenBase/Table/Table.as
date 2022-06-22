// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "LimbsCommon.as";

void onInit(CBlob @ this)
{

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Table");
	this.set_u8("shop icon", 15);
	
	AddIconToken("$stone_hammer_icon$", "Hammer_Icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Stone Hammer", "$stone_hammer_icon$", "stone_hammer", "A hammer for building wooden and stone structures.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 25);
	}
	AddIconToken("$stone_knife_icon$", "Knife_Icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Stone Knife", "$stone_knife_icon$", "stone_knife", "A knife for stabbing and surgery.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	AddIconToken("$bow_icon$", "Bow_Icon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Bow", "$bow_icon$", "bow", "A bow for ranged stabbing.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 25);
		AddRequirement(s.requirements, "blob", "fibre", "Fibre", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "A lantern for keeping things visible.\nPrevents the growth of moss.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	/////////////
	{
		AddIconToken("$shirt_icon$", "Shirt_Icon.png", Vec2f(24, 24), 0);
		ShopItem@ s = addShopItem(this, "Cloth Shirt", "$shirt_icon$", "cloth_shirt", "A shirt to provide a tiny bit of defense to the torso and arms.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
	}
	{
		AddIconToken("$hat_icon$", "Hat_Icon.png", Vec2f(24, 24), 0);
		ShopItem@ s = addShopItem(this, "Beanie", "$hat_icon$", "cloth_hat", "A hat to provide a tiny bit of defense to the head.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
	}
	{
		AddIconToken("$eastern_hat_icon$", "Hat_Icon.png", Vec2f(24, 24), 4);
		ShopItem@ s = addShopItem(this, "Eastern Hat", "$eastern_hat_icon$", "eastern_hat", "A hat used by farmers to protect from the sun.", false);
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
	}
	{
		AddIconToken("$santa_hat_icon$", "Hat_Icon.png", Vec2f(24, 24), 8);
		ShopItem@ s = addShopItem(this, "Santa Hat", "$santa_hat_icon$", "santa_hat", "A hat used to show the christmas spirit in the off season.", false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
		AddRequirement(s.requirements, "blob", "chicken_leather", "Leather", 1);
	}
	/////////////////////
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "blob", "cloth", "Cloth", 1);
	}
	AddIconToken("$frame_icon$", "GolemChestIcon.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Wooden Frame", "$frame_icon$", "mannequin", "A wooden torso, for building wooden golems.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		s.spawnNothing = true;
	}
	AddIconToken("$golem_icon$", "GolemChestIcon.png", Vec2f(16, 16), 1);
	{
		ShopItem@ s = addShopItem(this, "Stone Frame", "$golem_icon$", "golem", "A stone torso, for building stone golems.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$big_door_icon$", "BigDoor.png", Vec2f(16, 16), 0);
		ShopItem@ s = addShopItem(this, "Door", "$big_door_icon$", "big_door", "A door to keep nature out.\nUse a metal bar to lock it for yourself.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	{
		AddIconToken("$log_cage_icon$", "LogCage.png", Vec2f(13, 17), 0);
		ShopItem@ s = addShopItem(this, "Cage", "$log_cage_icon$", "log_cage", "A cage to hold small animals.", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	
	
	this.getSprite().SetZ(-50.0f);
	
	this.addCommandID("lie");
	
	this.Tag("save");
}

void onTick(CBlob @ this)
{
	if(this.isAttachedToPoint("BED")){
		CAttachment@ attach = this.getAttachments();
		if(attach.getAttachedBlob("BED") !is null){
			attach.getAttachedBlob("BED").SetFacingLeft(false);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!getMap().rayCastSolid(caller.getPosition(),this.getPosition())){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		string butname = "Lie Down";
		
		if(caller.isAttachedTo(this))butname = "Get off";
		else {
			if(this.isAttachedToPoint("BED")){
				butname = "Take off";
			} else
			if(caller.getCarriedBlob() !is null){
				butname = "Place on";
			}
		}
		
		CButton@ button = caller.CreateGenericButton(29, Vec2f(0,-8), this, this.getCommandID("lie"), butname, params);
		button.enableRadius = 32;
	}
	
	this.set_bool("shop available", true);
	if(this.isAttachedToPoint("BED")){
		CAttachment@ attach = this.getAttachments();
		if(attach.getAttachedBlob("BED") !is null){
			if(attach.getAttachedBlob("BED").getName() == "humanoid")this.set_bool("shop available", false);
		}
	}
	
	if(!this.get_bool("shop available")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(10, Vec2f(0,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
		button.enableRadius = 16;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		if(isServer){
			if(name == "mannequin" || name == "golem"){
				CBlob @frame = server_CreateBlob("humanoid",-1,this.getPosition());
				this.server_AttachTo(frame, "BED");
				
				int body = BodyType::None;

				LimbInfo@ limbs;
				if(frame.get("limbInfo", @limbs)){
					if(name == "mannequin")setUpLimbs(limbs,body,BodyType::Wood,CoreType::Missing,body,body,body,body);
					if(name == "golem")setUpLimbs(limbs,body,BodyType::Golem,CoreType::Missing,body,body,body,body);
				}
				
				/*
				EquipmentInfo@ equip;
				if(frame.get("equipInfo", @equip)){
					equip.Torso = Equipment::LifeCore;
				}*/
				
				frame.Untag("alive");
			}
		}
	}
	
	if (cmd == this.getCommandID("lie"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("BED") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("BED");
						this.server_DetachFrom(attachedBlob);
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold is null){
					
						if(!this.isAttachedTo(caller)){
							this.server_AttachTo(caller, "BED");
						} else {
							this.server_DetachFrom(caller);
						}
					
					} else {
						caller.DropCarried();
						this.server_AttachTo(hold, "BED");
					}
				
				}
			}
		}
	}
}