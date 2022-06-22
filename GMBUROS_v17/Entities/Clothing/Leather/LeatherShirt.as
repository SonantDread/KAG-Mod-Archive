#include "EquipmentCommon.as";

void onInit(CBlob @ this){
	
	this.Tag("equippable");
	this.set_u16("equip_id",Equipment::Shirt);
	this.set_u8("equip_slot", EquipSlot::Torso);
	if(this.getName() == "chicken_shirt")this.set_u16("equip_type",1);
	if(this.getName() == "human_shirt")this.set_u16("equip_type",2);
	if(this.getName() == "bison_shirt")this.set_u16("equip_type",3);
}