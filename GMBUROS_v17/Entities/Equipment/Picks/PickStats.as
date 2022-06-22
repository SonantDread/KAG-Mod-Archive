
#include "EquipmentCommon.as";

///One file for all picks cause lazy

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::Pick);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "metal_pick")this.set_u16("equip_type",0);
	if(this.getName() == "gold_pick")this.set_u16("equip_type",1);
}