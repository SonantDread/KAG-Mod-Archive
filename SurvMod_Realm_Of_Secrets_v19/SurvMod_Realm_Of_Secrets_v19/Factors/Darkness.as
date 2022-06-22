
#include "AbilityCommon.as"

void onInit(CBlob@ this)
{
	this.set_s16("darkness",0);
	
	this.getCurrentScript().tickFrequency = 31;
}

void onTick(CBlob@ this)
{
	if(this.get_s16("darkness") >= 50 && this.hasTag("darkness_sworn"))addAbility(this,Ability::SummonDarkBlade);
	if(this.get_s16("darkness") >= 50 || this.hasTag("darkness_sworn"))addAbility(this,Ability::CorruptOrb);
	if(this.get_s16("darkness") >= 100 || this.hasTag("darkness_sworn"))addAbility(this,Ability::CorruptTendril);
	
	if(isServer())this.Sync("darkness",true);
}