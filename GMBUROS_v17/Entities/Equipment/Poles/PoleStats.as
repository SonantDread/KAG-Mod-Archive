
#include "EquipmentCommon.as";

///One file for all hammers cause lazy

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::Pole);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "stick")this.set_u16("equip_type",0);
	if(this.getName() == "spade")this.set_u16("equip_type",1);
	if(this.getName() == "spear")this.set_u16("equip_type",2);
	if(this.getName() == "pike")this.set_u16("equip_type",3);
}