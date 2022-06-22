
#include "AbilityCommon.as"

void onInit(CBlob@ this)
{
	this.set_s16("memories",0);
	
	this.getCurrentScript().tickFrequency = 31;
}

void onTick(CBlob@ this)
{
	if(this.get_s16("memories") >= 1)addAbility(this,Ability::ImbueCorpse);
	
	if(isServer())this.Sync("memories",true);
}