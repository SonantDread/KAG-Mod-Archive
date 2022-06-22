
#include "Hitters.as";
#include "LimbsCommon.as";
#include "TekCommon.as";

shared class EquipmentInfo
{
	u8 MainHand;
	u8 MainHandType;
	
	u8 SubHand;
	u8 SubHandType;
	
	u8 Head;
	u8 HeadType;
	
	u8 Torso;
	u8 TorsoType;
	
	u8 Feet;
	u8 Back;
	u8 Waist;
	
	f32 mainSwingTimer;
	f32 subSwingTimer;
};

namespace EquipSlot
{
	enum type
	{
		Main = 0,
		Sub,
		Torso,
		Head,
		Feet,
		Waist,
		Back,
		length
	};
}

namespace Equipment
{
	enum Equip
	{
		None = 0,
		Pick,
		Hammer,
		Axe,
		
		Sword,
		Pole,
		GreatSword,
		GreatSwordAlt,
		Bow,
		Knife,
		
		Shield,
		Grapple,
		
		Shirt,
		KnightArmour,
		GoldArmour,
		Hat,
		
		LifeCore,
		DeathCore,
		
		Casting,
		ZombieHands,
	};
}

string getEquipmentName(int equip){

	if(equip == Equipment::Pick)return "Pick";
	if(equip == Equipment::Hammer)return "Hammer";
	if(equip == Equipment::Axe)return "Axe";
	
	if(equip == Equipment::Sword)return "Sword";
	if(equip == Equipment::Pole)return "Pole";
	if(equip == Equipment::GreatSword)return "GreatSword";
	if(equip == Equipment::GreatSwordAlt)return "GreatSword";
	if(equip == Equipment::Bow)return "Bow";
	if(equip == Equipment::Knife)return "Knife";
	
	if(equip == Equipment::Shield)return "Shield";
	if(equip == Equipment::Grapple)return "Grapple";
	
	if(equip == Equipment::Shirt)return "Shirt";
	if(equip == Equipment::KnightArmour)return "Metal_Armour";
	if(equip == Equipment::GoldArmour)return "Gold_Armour";
	if(equip == Equipment::Hat)return "Hat";
	
	if(equip == Equipment::LifeCore)return "LifeCore";
	if(equip == Equipment::DeathCore)return "GhostCore";
	
	if(equip == Equipment::Casting)return "Casting";
	
	return "None";

}

string getEquipmentBlob(int equip, int type){

	switch(equip){
	
		case Equipment::Pole:{
			if(type == 0)return "stick";
			if(type == 1)return "spade";
			if(type == 2)return "spear";
			if(type == 3)return "pike";
		break;}
		
		case Equipment::Sword:{
			if(type == 0)return "metal_sword";
			if(type == 1)return "gold_sword";
			if(type == 2)return "dark_sword";
		break;}
		
		case Equipment::Shield:{
			if(type == 0)return "metal_shield";
		break;}
		
		case Equipment::Bow:{
			if(type == 0)return "bow";
		break;}
		
		case Equipment::GreatSword:{
			if(type == 0)return "metal_blade";
			if(type == 1)return "gold_blade";
			if(type == 2)return "shadow_blade";
			if(type == 3)return "halberd";
		break;}
		
		case Equipment::Hammer:{
			if(type == 0)return "stone_hammer";
			if(type == 1)return "metal_hammer";
			if(type == 2)return "gold_hammer";
			if(type == 3)return "mallet";
		break;}
		
		case Equipment::Pick:{
			if(type == 0)return "metal_pick";
			if(type == 1)return "gold_pick";
		break;}
		
		case Equipment::Axe:{
			if(type == 0)return "hachet";
			if(type == 1)return "metal_axe";
			if(type == 2)return "gold_axe";
		break;}
		
		case Equipment::Knife:{
			if(type == 0)return "stone_knife";
			if(type == 1)return "metal_knife";
			if(type == 2)return "dirty_knife";
		break;}
		
		case Equipment::Hat:{
			if(type == 0)return "cloth_hat";
			if(type == 1)return "chicken_hat";
			if(type == 2)return "western_hat";
			if(type == 3)return "bison_hat";
			if(type == 4)return "eastern_hat";
			if(type == 5)return "metal_hat";
			if(type == 6)return "pirate_hat";
			if(type == 7)return "russian_hat";
			if(type == 8)return "santa_hat";
		break;}
		
		case Equipment::Shirt:{
			if(type == 0)return "cloth_shirt";
			if(type == 1)return "chicken_shirt";
			if(type == 2)return "human_shirt";
			if(type == 3)return "bison_shirt";
		break;}
		
		case Equipment::KnightArmour:return "metal_armour";
		case Equipment::GoldArmour:return "gold_armour";
	}
	
	return "";
}

f32 getEquipmentDamage(int equip, int type){

	switch(equip){
	
		case Equipment::Pole:{
			if(type == 0)return 0.5f;
			if(type == 1)return 1.0f;
			if(type == 2)return 1.0f;
			if(type == 3)return 2.0f;
		break;}
		
		case Equipment::Sword:{
			if(type == 0)return 4.0f;
			if(type == 1)return 5.0f;
			if(type == 2)return 4.0f;
		break;}
		
		case Equipment::Shield:{
			if(type == 0)return 4.0f;
		break;}
		
		case Equipment::GreatSword:{
			if(type == 0)return 6.0f;
			if(type == 1)return 8.0f;
			if(type == 2)return 6.0f;
			if(type == 3)return 3.0f;
		break;}
		
		case Equipment::Hammer:{
			if(type == 0)return 2.0f;
			if(type == 1)return 3.0f;
			if(type == 2)return 4.0f;
			if(type == 3)return 1.0f;
		break;}
		
		case Equipment::Pick:{
			if(type == 0)return 3.0f;
			if(type == 1)return 4.0f;
		break;}
		
		case Equipment::Axe:{
			if(type == 0)return 2.0f;
			if(type == 1)return 3.0f;
			if(type == 2)return 4.0f;
		break;}
		
		case Equipment::Knife:{
			if(type == 0)return 2.0f;
			if(type == 1)return 3.0f;
			if(type == 2)return 3.0f;
		break;}
	}

	return 0.0f;
}

int getEquipmentDamageType(int equip, int type){

	switch(equip){
	
		case Equipment::Pole:{
			if(type == 0)return Hitters::muscles;
			if(type == 1)return Hitters::builder;
			if(type == 2)return Hitters::stab;
			if(type == 3)return Hitters::stab;
		break;}
		
		case Equipment::GreatSword:{
			if(type == 0)return Hitters::sword;
			if(type == 1)return Hitters::sword;
			if(type == 2)return Hitters::sword;
			if(type == 3)return Hitters::saw;
		break;}
	}

	return Hitters::nothing;
}

f32 getEquipmentSpeed(int equip, int type, f32 strength){

	f32 amount = 1.0f;
	
	switch(equip){
		
		case Equipment::GreatSword:{
			if(type == 0)amount = 0.5f;
			if(type == 1)amount = 0.25f;
			if(type == 2)amount = 0.5f;
			if(type == 3)amount = 1.0f;
		break;}
		
		case Equipment::Sword:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 0.5f;
			if(type == 2)amount = 1.0f;
		break;}
		
		case Equipment::Hammer:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 1.0f;
			if(type == 2)amount = 0.5f;
			if(type == 3)amount = 2.0f;
		break;}
		
		case Equipment::Pick:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 0.5f;
		break;}
		
		case Equipment::Axe:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 1.0f;
			if(type == 2)amount = 0.5f;
		break;}
		
		case Equipment::Knife:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 1.0f;
			if(type == 2)amount = 2.0f;
		break;}
	}
	
	if(amount < 1.0f){
		amount = Maths::Min(amount*strength,1.0f);
	}

	return amount;
}

f32 getEquipmentRange(CBlob @this, int Slot, int equip, int type){

	f32 amount = 10.0f; //Base fist range, in the future grab this from some limb value so large limbs have more reach
	
	switch(equip){
		
		case Equipment::GreatSword:{
			if(type == 0)amount += 4.0f;
			if(type == 1)amount += 4.0f;
			if(type == 2)amount += 4.0f;
			if(type == 3)amount += 6.0f;
		break;}
		
		case Equipment::Pole:{
			if(type == 0)amount += 14.0f;
			if(type == 1)amount += 12.0f;
			if(type == 2)amount += 14.0f;
			if(type == 3)amount += 15.0f;
		break;}
	}

	return amount;
}

bool damageIsBlunt(u8 DamageType){

	if(DamageType == Hitters::crush)return true;
	if(DamageType == Hitters::fall)return true;
	if(DamageType == Hitters::stomp)return true;
	if(DamageType == Hitters::bite)return true;
	if(DamageType == Hitters::shield)return true;
	if(DamageType == Hitters::cata_stones)return true;
	if(DamageType == Hitters::cata_boulder)return true;
	if(DamageType == Hitters::boulder)return true;
	if(DamageType == Hitters::ram)return true;
	if(DamageType == Hitters::muscles)return true;

	return false;
}

bool damageIsSlash(u8 DamageType){

	if(DamageType == Hitters::sword)return true;
	if(DamageType == Hitters::bite)return true;

	return false;
}

bool damageIsHack(u8 DamageType){

	if(DamageType == Hitters::saw)return true;

	return false;
}

bool damageIsPierce(u8 DamageType){

	if(DamageType == Hitters::bite)return true;
	if(DamageType == Hitters::stab)return true;
	if(DamageType == Hitters::arrow)return true;
	if(DamageType == Hitters::ballista)return true;
	if(DamageType == Hitters::bomb_arrow)return true;
	if(DamageType == Hitters::spikes)return true;
	if(DamageType == Hitters::builder)return true;

	return false;
}

f32 getEquipmentArmour(int equip, int type){
	
	f32 amount = 0.0f;
	
	switch(equip){
		
		case Equipment::Shirt:{
			if(type == 0)amount = 0.5f;
			if(type == 1)amount = 0.5f;
			if(type == 2)amount = 1.0f;
			if(type == 3)amount = 1.5f;
		break;}
		
		case Equipment::KnightArmour:{
			amount = 2.0f;
		break;}
		
		case Equipment::GoldArmour:{
			amount = 2.0f;
		break;}
		
		case Equipment::Shield:{
			amount = 1.0f;
		break;}
		
		case Equipment::Hat:{
			if(type == 0)amount = 1.0f;
			if(type == 1)amount = 1.0f;
			if(type == 2)amount = 2.0f;
			if(type == 3)amount = 3.0f;
			if(type == 4)amount = 1.0f;
			if(type == 5)amount = 4.0f;
			if(type == 6)amount = 0.5f;
			if(type == 7)amount = 3.5f;
			if(type == 8)amount = 0.5f;
		break;}
	}

	return amount;
}

bool canRemoveEquipment(int type){

	if(type == Equipment::LifeCore)return false;
	if(type == Equipment::DeathCore)return false;
	
	return true;

}

bool neesdUsableArm(int type){

	if(type == Equipment::Shield)return false;
	
	return true;

}

u8 checkEquipped(EquipmentInfo@ equip, u8 Slot){
	switch(Slot){
		case EquipSlot::Main:{
			return equip.MainHand;}
	
		case EquipSlot::Sub:{
			return equip.SubHand;}
		
		case EquipSlot::Torso:{
			return equip.Torso;}
		
		case EquipSlot::Head:{
			return equip.Head;}
		
		case EquipSlot::Feet:{
			return equip.Feet;}
		
		case EquipSlot::Back:{
			return equip.Back;}
		
		case EquipSlot::Waist:{
			return equip.Waist;}
	}
	return 0;
}

u8 checkEquippedType(EquipmentInfo@ equip, u8 Slot){
	switch(Slot){
		case EquipSlot::Main:{
			return equip.MainHandType;}
	
		case EquipSlot::Sub:{
			return equip.SubHandType;}
		
		case EquipSlot::Torso:{
			return equip.TorsoType;}
		
		case EquipSlot::Head:{
			return equip.HeadType;}		
	}
	return 0;
}

void setEquipped(EquipmentInfo@ equip, u8 Slot, int Equip, int EquipType){
	switch(Slot){
		case EquipSlot::Main:{
			equip.MainHand = Equip;
			equip.MainHandType = EquipType;
		break;}
	
		case EquipSlot::Sub:{
			equip.SubHand = Equip;
			equip.SubHandType = EquipType;
		break;}
		
		case EquipSlot::Torso:{
			equip.Torso = Equip;
			equip.TorsoType = EquipType;
		break;}
		
		case EquipSlot::Head:{
			equip.Head = Equip;
			equip.HeadType = EquipType;
		break;}
		
		case EquipSlot::Feet:{
			equip.Feet = Equip;
		break;}
		
		case EquipSlot::Back:{
			equip.Back = Equip;
		break;}
		
		case EquipSlot::Waist:{
			equip.Waist = Equip;
		break;}
	}
}

void server_SyncEquipped(CBlob@ this, u8 Slot){
	if(isServer()){
		EquipmentInfo@ equip;
		if(!this.get("equipInfo", @equip))return;
		
		CBitStream params;
		params.write_u8(Slot);
		params.write_u8(checkEquipped(equip,Slot));
		params.write_u8(checkEquippedType(equip,Slot));
		this.SendCommand(this.getCommandID("equip_sync"), params);
	}
}
void server_SetEquipped(CBlob@ this, u8 Slot, u8 Equip, u8 EquipType){
	if(isServer()){
		EquipmentInfo@ equip;
		if(this.get("equipInfo", @equip)){
			setEquipped(equip,Slot, Equip, EquipType);
		}
		
		CBitStream params;
		params.write_u8(Slot);
		params.write_u8(Equip);
		params.write_u8(EquipType);
		this.SendCommand(this.getCommandID("equip_sync"), params);
	}
}

bool equipType(CBlob@this, u8 Slot, int Equip, int type){

	EquipmentInfo@ equip;
	if(!this.get("equipInfo", @equip))return false;

	if(Equip == Equipment::LifeCore || Equip == Equipment::DeathCore){
		return false;
	}
	
	if(neesdUsableArm(Equip)){
		if(!isLimbUsable(this,Slot))return false;
	} else {
		if(!canHitLimb(this,Slot))return false;
	}
	
	if(Equip == Equipment::GreatSword){
		if(!canRemoveEquipment(equip.MainHand) || !canRemoveEquipment(equip.SubHand)){
			return false;
		}
		unequipType(this, this, EquipSlot::Main,false);
		unequipType(this, this, EquipSlot::Sub,false);
		
		server_SetEquipped(this,EquipSlot::Main,Equipment::GreatSword,type);
		server_SetEquipped(this,EquipSlot::Sub,Equipment::GreatSwordAlt,type);

		return true;
	}
	
	if(canRemoveEquipment(checkEquipped(equip,Slot))){
		unequipType(this, this, Slot,false);
		
		server_SetEquipped(this,Slot,Equip,type);
		
		return true;
	}
	
	return false;
}

bool unequipType(CBlob@this, CBlob@caller, u8 Slot, bool Sync){
	if(isServer()){
		EquipmentInfo@ equip;
		if(!this.get("equipInfo", @equip))return false;
		u8 Equip = checkEquipped(equip,Slot);
		u8 EquipType = checkEquippedType(equip,Slot);
		
		if((Slot == EquipSlot::Main || Slot == EquipSlot::Sub)
		&& equip.MainHand == Equipment::GreatSword){
			if(getEquipmentBlob(Equipment::GreatSword,equip.MainHandType) != ""){
				CBlob @item = server_CreateBlob(getEquipmentBlob(Equipment::GreatSword,equip.MainHandType),-1,this.getPosition());
				if(caller !is null){
					if(caller.getCarriedBlob() is null)caller.server_Pickup(item);
					else if(item.canBePutInInventory(caller))caller.server_PutInInventory(item);
				}
			}
			
			if(!Sync){
				setEquipped(equip, EquipSlot::Main, Equipment::None, 0);
				setEquipped(equip, EquipSlot::Sub, Equipment::None, 0);
			} else {
				server_SetEquipped(this, EquipSlot::Main, Equipment::None, 0);
				server_SetEquipped(this, EquipSlot::Sub, Equipment::None, 0);
			}
			
			return true;
		}

		if(canRemoveEquipment(Equip)){
			
			if(isServer() && getEquipmentBlob(Equip,EquipType) != ""){
				CBlob @item = server_CreateBlob(getEquipmentBlob(Equip,EquipType),-1,this.getPosition());
				if(caller !is null){
					if(caller.getCarriedBlob() is null)caller.server_Pickup(item);
					else if(item.canBePutInInventory(caller))caller.server_PutInInventory(item);
				}
			}
			
			if(!Sync){
				setEquipped(equip, Slot, Equipment::None, 0);
			} else {
				server_SetEquipped(this, Slot, Equipment::None, 0);
			}
			
			return true;
		}
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
	Vec2f BeltDimension = Vec2f(24,24);
	Vec2f BackDimension = Vec2f(24,24);
	
	EquipmentInfo@ equip;
	if(!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	
	
	if(equip.MainHand > Equipment::None){
		MainArmImage = getEquipmentName(equip.MainHand)+"_Icon.png";
		MainArmFrame = equip.MainHandType;
		MainArmName = getEquipmentName(equip.MainHand);
	} else {
		if(!isLimbUsable(this,LimbSlot::MainArm)){
			MainArmFrame = 6;
		}
	}
	
	if(equip.SubHand > Equipment::None){
		SubArmImage = getEquipmentName(equip.SubHand)+"_Icon.png";
		SubArmFrame = equip.SubHandType;
		SubArmName = getEquipmentName(equip.SubHand);
	} else {
		if(!isLimbUsable(this,LimbSlot::SubArm)){
			SubArmFrame = 7;
		}
	}
	
	if(equip.Torso > Equipment::None){
		TorsoImage = getEquipmentName(equip.Torso)+"_Icon.png";
		TorsoFrame = equip.TorsoType;
		TorsoName = getEquipmentName(equip.Torso);
	}
	
	if(equip.Head > Equipment::None){
		HeadImage = getEquipmentName(equip.Head)+"_Icon.png";
		HeadFrame = equip.HeadType;
		HeadName = getEquipmentName(equip.Head);
	}
	
	AttachmentPoint@ waistslot = this.getAttachments().getAttachmentPointByName("WAIST");
	if(waistslot !is null){
		CBlob @occu = waistslot.getOccupied();
		if(occu !is null){
			BeltImage = occu.inventoryIconName;
			BeltFrame = occu.inventoryIconFrame;
			BeltDimension = occu.inventoryFrameDimension;
		}
	}
	
	AttachmentPoint@ backslot = this.getAttachments().getAttachmentPointByName("BACK");
	if(backslot !is null){
		CBlob @occu = backslot.getOccupied();
		if(occu !is null){
			BackImage = occu.inventoryIconName;
			BackFrame = occu.inventoryIconFrame;
			BackDimension = occu.inventoryFrameDimension;
		}
	}
	
	if (menu !is null)
	{
		CBitStream params;
		
		int carry_id = 0;
		
		if(forBlob is null)carry_id = this.getNetworkID();
		else carry_id = forBlob.getNetworkID();
		
		
		
		menu.deleteAfterClick = false;


		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Back);
		menu.AddButton(BackImage, BackFrame, BackDimension, BackName, this.getCommandID("equip"), Vec2f(1,1), params);
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Head);
		if(limbs.Head <= 0)HeadName = "Missing!";
		CGridButton @head = menu.AddButton(HeadImage, HeadFrame, HeadName, this.getCommandID("equip"),params);
		if(limbs.Head <= 0){
			head.SetEnabled(false);
			head.SetHoverText("Head missing!!!");
		}
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Head);
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip")).SetEnabled(false);
		params.Clear();
		
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Main);
		if(!isLimbUsable(this,LimbSlot::MainArm))MainArmName = "Cannot Equip";
		CGridButton @mainarm = menu.AddButton(MainArmImage, MainArmFrame, MainArmName, this.getCommandID("equip"),params);
		if(!isLimbUsable(this,LimbSlot::MainArm)){
			if(!canHitLimb(this,LimbSlot::MainArm))mainarm.SetEnabled(false);
			else mainarm.SetHoverText("Handless; Can't equip non-armour.");
		}
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Torso);
		menu.AddButton(TorsoImage, TorsoFrame, TorsoName, this.getCommandID("equip"),params);
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Sub);
		if(!isLimbUsable(this,LimbSlot::SubArm))SubArmName = "Cannot Equip";
		CGridButton @subarm = menu.AddButton(SubArmImage, SubArmFrame, SubArmName, this.getCommandID("equip"),params);
		if(!isLimbUsable(this,LimbSlot::SubArm)){
			if(!canHitLimb(this,LimbSlot::SubArm))subarm.SetEnabled(false);
			else subarm.SetHoverText("Handless; Can't equip non-armour.");
		}
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Waist);
		menu.AddButton(BeltImage, BeltFrame, BeltDimension, BeltName, this.getCommandID("equip"), Vec2f(1,1), params);
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Feet);
		if(limbs.FrontLeg <= 0 && limbs.BackLeg <= 0)LegsName = "Legless";
		CGridButton @legbutton = menu.AddButton(LegsImage, LegsFrame, LegsName, this.getCommandID("equip"),params);
		if(limbs.FrontLeg <= 0 && limbs.BackLeg <= 0){
			legbutton.SetEnabled(false);
		}
		params.Clear();
		
		params.write_u16(carry_id);
		params.write_u8(EquipSlot::Head);
		menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("equip")).SetEnabled(false);
		params.Clear();
	}
}

f32 getAimAngle(CBlob @this){
	Vec2f vec = this.getAimPos() - this.getPosition();
	return vec.Angle();

}

bool canHit(CBlob@ this, CBlob@ b){

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached()){

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob") || b.hasTag("building")))
				return false;

	}

	if(b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}