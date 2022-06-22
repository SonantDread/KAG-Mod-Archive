
#include "EquipmentCommon.as";

///One file for all axes cause lazy

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::Axe);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "hachet")this.set_u16("equip_type",0);
	else this.Tag("sharp"); //Non-hachets are sharp
	if(this.getName() == "metal_axe")this.set_u16("equip_type",1);
	if(this.getName() == "gold_axe")this.set_u16("equip_type",2);
}