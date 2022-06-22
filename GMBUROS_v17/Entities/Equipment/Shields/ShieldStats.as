
#include "EquipmentCommon.as";

///One file for all shields cause lazy

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::Shield);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "metal_shield")this.set_u16("equip_type",0);
}