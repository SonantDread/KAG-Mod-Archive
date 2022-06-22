
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	
	this.set_u16("equip_id",Equipment::GreatSword);
	this.set_u8("equip_slot", EquipSlot::Main);
	
	if(this.getName() == "metal_blade")this.set_u16("equip_type",0);
	if(this.getName() == "gold_blade")this.set_u16("equip_type",1);
	if(this.getName() == "shadow_blade"){
		this.set_u16("equip_type",2);
		this.Tag("darkness_sworn");
	}
	if(this.getName() == "halberd")this.set_u16("equip_type",3);
}