#include "NecromancerCommon.as";

u8 manaRegenerateStep = 5;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 1 * getTicksASecond();
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	NecromancerInfo@ necro;
    if (!this.get("necromancerInfo", @necro)) {
        return;
    }

    s32 mana = necro.mana;
    s32 maxMana = necro.maxMana;
    if (mana < maxMana)
    {
    	if (maxMana - mana >= manaRegenerateStep)
    		necro.mana += manaRegenerateStep;
    	else
    		necro.mana = maxMana;
    }
}