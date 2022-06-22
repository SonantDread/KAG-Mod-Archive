
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	this.Tag("sharp");
	this.set_u16("equip_id",Equipment::Sword);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "dark_sword"){
		this.set_u16("equip_type",2);
		this.Tag("darkness_sworn");
	} else 
	if(this.getName() == "metal_sword")this.set_u16("equip_type",0);
	else if(this.getName() == "gold_sword")this.set_u16("equip_type",1);
}