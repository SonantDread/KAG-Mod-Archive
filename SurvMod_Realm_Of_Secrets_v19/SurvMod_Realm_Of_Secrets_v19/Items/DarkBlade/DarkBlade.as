
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	this.set_u16("equip_type",2);
	this.set_u16("equip_id",Equipment::Sword);
	this.set_string("equip_slot","arm");
	this.Tag("darkness_sworn");
}