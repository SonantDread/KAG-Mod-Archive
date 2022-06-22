
#include "EnchantCommon.as";
#include "EnchantAnimCommon.as";

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();
	u32 Enchants = blob.get_u32("enchants");

	for(int i = 0;i < Enchantment::length;i++){
		if(hasEnchant(Enchants, i)){
			if(this.getSpriteLayer("enchant_"+i) is null){
				addEnchantSprite(this, i);
			} else {
				UpdateEnchantOffset(this,i);
			}
		} else {
			if(this.getSpriteLayer("enchant_"+i) !is null){
				removeEnchantSprite(this, i);
			}
		}
	}

}




