#include "EquipmentCommon.as";

void onInit(CBlob @ this){
	
	this.Tag("equippable");
	this.set_u16("equip_id",Equipment::Shirt);
	this.set_u8("equip_slot", EquipSlot::Torso);
	this.set_u16("equip_type",0);
}