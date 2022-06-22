
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	this.Tag("sharp");
	this.set_u16("equip_id",Equipment::Knife);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "stone_knife")this.set_u16("equip_type",0);
	else if(this.getName() == "metal_knife")this.set_u16("equip_type",1);
	else if(this.getName() == "dirty_knife")this.set_u16("equip_type",2);
}