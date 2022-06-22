#include "ItemsCommon.as";

f32 DamageMultiplier(CBlob @this){
	f32 Dmg = 1;
	
	Dmg *= SwordDamageMultiplier(this);
	
	return Dmg;
}