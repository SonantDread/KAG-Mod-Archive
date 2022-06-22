
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("equippable");
	this.set_u16("equip_type",0);
	this.set_u16("equip_id",Equipment::GreatSword);
	this.set_string("equip_slot","arm");
}