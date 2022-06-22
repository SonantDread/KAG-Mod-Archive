#include "EquipmentCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_onladder;
	this.getCurrentScript().runFlags |= Script::tick_not_onground;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (!this.isKeyPressed(key_up) || this.isKeyPressed(key_down)) { return; }

	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;

	if(equip.MainHand == Equipment::Grapple || equip.SubHand == Equipment::Grapple)
	if (this.getMap().getSectorAtPosition(this.getPosition(), "tree") !is null)
	{
		this.getShape().getVars().onladder = true;
	}
}
