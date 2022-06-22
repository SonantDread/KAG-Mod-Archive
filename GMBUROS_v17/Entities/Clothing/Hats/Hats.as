#include "EquipmentCommon.as";

void onInit(CBlob @ this){
	
	this.Tag("equippable");
	this.set_u16("equip_id",Equipment::Hat);
	this.set_u8("equip_slot", EquipSlot::Head);
	if(this.getName() == "cloth_hat")this.set_u16("equip_type",0);
	if(this.getName() == "chicken_hat")this.set_u16("equip_type",1);
	if(this.getName() == "western_hat")this.set_u16("equip_type",2);
	if(this.getName() == "bison_hat")this.set_u16("equip_type",3);
	if(this.getName() == "eastern_hat")this.set_u16("equip_type",4);
	if(this.getName() == "metal_hat")this.set_u16("equip_type",5);
	if(this.getName() == "pirate_hat")this.set_u16("equip_type",6);
	if(this.getName() == "russian_hat")this.set_u16("equip_type",7);
	if(this.getName() == "santa_hat")this.set_u16("equip_type",8);
}