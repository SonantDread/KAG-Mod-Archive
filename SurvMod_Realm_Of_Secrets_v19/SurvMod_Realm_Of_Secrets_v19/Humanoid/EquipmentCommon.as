
#include "LimbsCommon.as";
#include "TekCommon.as";

namespace Equipment
{
	enum Equip
	{
		None = 0,
		Pick,
		Hammer,
		Sword,
		GreatSword,
		GreatSwordAlt,
		Shield,
		Bow,
		Grapple,
		
		Shirt,
		KnightArmour,
		LifeCore,
		DeathCore,
		
		Casting,
		ZombieHands,
	};
}

string getEquipmentName(int equip){

	if(equip == Equipment::Pick)return "Pick";
	if(equip == Equipment::Hammer)return "Hammer";
	
	if(equip == Equipment::Sword)return "Sword";
	if(equip == Equipment::GreatSword)return "GreatSword";
	if(equip == Equipment::GreatSwordAlt)return "GreatSword";
	if(equip == Equipment::Shield)return "Shield";
	
	if(equip == Equipment::Bow)return "Bow";
	if(equip == Equipment::Grapple)return "Grapple";
	
	if(equip == Equipment::Shirt)return "Shirt";
	if(equip == Equipment::KnightArmour)return "Armour";
	if(equip == Equipment::LifeCore)return "LifeCore";
	if(equip == Equipment::DeathCore)return "GhostCore";
	
	if(equip == Equipment::Casting)return "Casting";
	
	return "None";

}

string getEquipmentBlob(int equip, int type){
	
	if(equip == Equipment::Sword && type == 2)return "dark_blade";
	if(equip == Equipment::GreatSword && type == 2)return "shadow_blade";
	if(equip == Equipment::GreatSword && type == 0)return "metal_blade";
	
	return "";
}

f32 getEquipmentHealth(CBlob @this, int equip, int type){

	if(equip == Equipment::KnightArmour){
		if(hasTek(this,this.getTeamNum(),"tek_armour"))return 2.0f;
		return 1.0f;
	}
	
	if(equip == Equipment::LifeCore || equip == Equipment::DeathCore){
		if(type == 2)return 2.0f;
		if(type == 1)return 1.0f;
		return 0.0f;
	}
	
	return 0.0f;

}

f32 getEquipmentDamage(int equip, int type){

	if(equip == Equipment::Pick)return 0.5f;
	
	if(equip == Equipment::Sword)return 2.0f;
	if(equip == Equipment::GreatSword)return 3.0f;
	if(equip == Equipment::GreatSwordAlt)return 3.0f;
	
	if(equip == Equipment::Bow)return 1.0f;

	return 0.0f;
}

bool canRemoveEquipment(int type){

	if(type == Equipment::LifeCore)return false;
	if(type == Equipment::DeathCore)return false;
	
	return true;

}


bool equipType(CBlob@this, string limb, int equip, int type){

	if(equip == Equipment::LifeCore || equip == Equipment::DeathCore){
		if(this.get_u8("heart") != HeartType::Missing)return false;
		
		this.set_u16(limb+"_default",equip);
		this.set_u16(limb+"_default_type",type);
		if(canRemoveEquipment(this.get_u16(limb+"_equip"))){
			unEquipType(this, this, limb);
			this.set_u16(limb+"_equip",equip);
			this.set_u16(limb+"_equip_type",type);
		}
		
		if(isServer()){
			this.Sync(limb+"_default",true);
			this.Sync(limb+"_default_type",true);
			this.Sync(limb+"_equip",true);
			this.Sync(limb+"_equip_type",true);
		}
		return true;
	}
	
	if(equip == Equipment::GreatSword){
		if(!canRemoveEquipment(this.get_u16("marm_equip")) || !canRemoveEquipment(this.get_u16("sarm_equip"))){
			return false;
		}
		unEquipType(this, this, "marm");
		unEquipType(this, this, "sarm");
		
		this.set_u16("marm_equip",Equipment::GreatSword);
		this.set_u16("marm_equip_type",type);
		this.set_u16("sarm_equip",Equipment::GreatSwordAlt);
		this.set_u16("sarm_equip_type",type);
		if(isServer()){
			this.Sync("marm_equip",true);
			this.Sync("marm_equip_type",true);
			this.Sync("sarm_equip",true);
			this.Sync("sarm_equip_type",true);
		}
		return true;
	}
	
	if(canRemoveEquipment(this.get_u16(limb+"_equip"))){
		unEquipType(this, this, limb);
		
		this.set_u16(limb+"_equip",equip);
		this.set_u16(limb+"_equip_type",type);
		if(isServer()){
			this.Sync(limb+"_equip",true);
			this.Sync(limb+"_equip_type",true);
		}
		
		return true;
	}
	
	return false;
}

string[] EquipSlots = {
	"head",
	"tors",
	"legs",
	"marm",
	"sarm",
	"back",
	"belt"
};

bool unEquipType(CBlob@this, CBlob@caller, string limb){

	if(this.get_u16(limb+"_equip") == Equipment::GreatSword || this.get_u16(limb+"_equip") == Equipment::GreatSwordAlt){
		if(isServer() && getEquipmentBlob(Equipment::GreatSword,this.get_u16(limb+"_equip_type")) != ""){
			CBlob @equip = server_CreateBlob(getEquipmentBlob(Equipment::GreatSword,this.get_u16(limb+"_equip_type")),-1,this.getPosition());
			if(caller !is null){
				if(caller.getCarriedBlob() is null)caller.server_Pickup(equip);
				else if(equip.canBePutInInventory(caller))caller.server_PutInInventory(equip);
			}
		}
		
		this.set_u16("marm_equip",this.get_u16("marm_default"));
		this.set_u16("marm_equip_type",this.get_u16("marm_default_type"));
		this.set_u16("sarm_equip",this.get_u16("sarm_default"));
		this.set_u16("sarm_equip_type",this.get_u16("sarm_default_type"));
		if(isServer()){
			this.Sync("marm_equip",true);
			this.Sync("marm_equip_type",true);
			this.Sync("sarm_equip",true);
			this.Sync("sarm_equip_type",true);
		}
		
		return true;
	}

	if(canRemoveEquipment(this.get_u16(limb+"_equip"))){
		
		if(isServer() && getEquipmentBlob(this.get_u16(limb+"_equip"),this.get_u16(limb+"_equip_type")) != ""){
			CBlob @equip = server_CreateBlob(getEquipmentBlob(this.get_u16(limb+"_equip"),this.get_u16(limb+"_equip_type")),-1,this.getPosition());
			if(caller !is null){
				if(caller.getCarriedBlob() is null)caller.server_Pickup(equip);
				else if(equip.canBePutInInventory(caller))caller.server_PutInInventory(equip);
			}
		}
		
		this.set_u16(limb+"_equip",this.get_u16(limb+"_default"));
		this.set_u16(limb+"_equip_type",this.get_u16(limb+"_default_type"));
		if(isServer()){
			this.Sync(limb+"_equip",true);
			this.Sync(limb+"_equip_type",true);
		}
		
		return true;
	}
	return false;
}

void createEquipMenu(CBlob@ this, CBlob@ forBlob, Vec2f pos)
{	  
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 3), "Equipment");
	
	this.set_Vec2f("equip_pos",pos);
	
	string HeadImage = "EquipmentGUI.png";
	string TorsoImage = "EquipmentGUI.png";
	string LegsImage = "EquipmentGUI.png";
	string MainArmImage = "EquipmentGUI.png";
	string SubArmImage = "EquipmentGUI.png";
	string BackImage = "EquipmentGUI.png";
	string BeltImage = "EquipmentGUI.png";
	int HeadFrame = 0;
	int TorsoFrame = 1;
	int LegsFrame = 2;
	int MainArmFrame = 3;
	int SubArmFrame = 4;
	int BackFrame = 5;
	int BeltFrame = 8;
	string HeadName = "Equip on Head";
	string TorsoName = "Equip on Body";
	string LegsName = "Equip on Legs";
	string MainArmName = "Equip in Main Hand";
	string SubArmName = "Equip in Sub Hand";
	string BackName = "Equip on Back";
	string BeltName = "Equip on Waist";
	
	
	if(isLimbUsable(this,this.get_u8("marm_type")))
	if(this.get_u16("marm_equip") > Equipment::None){
		MainArmImage = getEquipmentName(this.get_u16("marm_equip"))+"_Icon.png";
		MainArmFrame = this.get_u16("marm_equip_type");
		MainArmName = getEquipmentName(this.get_u16("marm_equip"));
	}
	if(isLimbUsable(this,this.get_u8("sarm_type")))
	if(this.get_u16("sarm_equip") > Equipment::None){
		SubArmImage = getEquipmentName(this.get_u16("sarm_equip"))+"_Icon.png";
		SubArmFrame = this.get_u16("sarm_equip_type");
		SubArmName = getEquipmentName(this.get_u16("sarm_equip"));
	}
	
	if(this.get_u16("tors_equip") > Equipment::None){
		TorsoImage = getEquipmentName(this.get_u16("tors_equip"))+"_Icon.png";
		TorsoFrame = this.get_u16("tors_equip_type");
		TorsoName = getEquipmentName(this.get_u16("tors_equip"));
	}
	
	if (menu !is null)
	{
		CBitStream params;
		
		int carry_id = 0;
		
		if(forBlob is null)carry_id = this.getNetworkID();
		else carry_id = forBlob.getNetworkID();
		
		params.write_u16(carry_id);
		
		menu.deleteAfterClick = false;

		menu.AddButton(BackImage, BackFrame, BackName, this.getCommandID("equip_back"),params);
		
		if(this.get_u8("head_type") <= 0)HeadName = "Missing!";
		CGridButton @head = menu.AddButton(HeadImage, HeadFrame, HeadName, this.getCommandID("equip_head"),params);
		if(this.get_u8("head_type") <= 0){
			head.SetEnabled(false);
			head.SetHoverText("Your head is missing!.");
		}
		
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip_head")).SetEnabled(false);
		
		if(!isLimbUsable(this,this.get_u8("marm_type")))MainArmName = "Cannot Equip";
		CGridButton @mainarm = menu.AddButton(MainArmImage, MainArmFrame, MainArmName, this.getCommandID("equip_marm"),params);
		if(!isLimbUsable(this,this.get_u8("marm_type"))){
			mainarm.SetEnabled(false);
			mainarm.SetHoverText("Your main arm is incapable of equipping items.");
		}
		
		menu.AddButton(TorsoImage, TorsoFrame, TorsoName, this.getCommandID("equip_tors"),params);
		
		if(!isLimbUsable(this,this.get_u8("sarm_type")))SubArmName = "Cannot Equip";
		CGridButton @subarm = menu.AddButton(SubArmImage, SubArmFrame, SubArmName, this.getCommandID("equip_sarm"),params);
		if(!isLimbUsable(this,this.get_u8("sarm_type"))){
			subarm.SetEnabled(false);
			mainarm.SetHoverText("Your sub arm is incapable of equipping items.");
		}
		
		menu.AddButton(BeltImage, BeltFrame, BeltName, this.getCommandID("equip_belt"),params);
		
		menu.AddButton(LegsImage, LegsFrame, LegsName, this.getCommandID("equip_legs"),params);
		
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip_head")).SetEnabled(false);
	}
}