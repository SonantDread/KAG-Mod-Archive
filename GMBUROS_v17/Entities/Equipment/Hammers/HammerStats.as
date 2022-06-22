
#include "EquipmentCommon.as";

///One file for all hammers cause lazy

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::Hammer);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "stone_hammer")this.set_u16("equip_type",0);
	if(this.getName() == "metal_hammer")this.set_u16("equip_type",1);
	if(this.getName() == "gold_hammer")this.set_u16("equip_type",2);
	if(this.getName() == "mallet")this.set_u16("equip_type",3);
}