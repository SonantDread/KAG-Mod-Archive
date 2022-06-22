
#include "EnchantCommon.as";

void UpdateEnchantArm(CSprite @this, bool main, bool visible, f32 angle, Vec2f around, string anim){
	CBlob @blob = this.getBlob();
	u32 Enchants = blob.get_u32("enchants");

	for(int i = 0;i < Enchantment::length;i++){
		if(hasEnchant(Enchants, i)){
			CSpriteLayer @Arm = this.getSpriteLayer("enchant_marm_"+i);
			if(!main)@Arm = this.getSpriteLayer("enchant_sarm_"+i);
			if(Arm !is null){
				Arm.SetVisible(visible);
				if (visible){
					if (!Arm.isAnimation(anim)){
						Arm.SetAnimation(anim);
					}
					Arm.ResetTransform();
					Arm.RotateBy(angle, around);
				}
			}
		}
	}

}

void UpdateEnchantOffset(CSprite @this, int Enchant){
	
	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("enchant_marm_"+Enchant);
	CSpriteLayer @BArmC = this.getSpriteLayer("enchant_sarm_"+Enchant);
	
	CSpriteLayer @shirt = this.getSpriteLayer("enchant_"+Enchant);
	
	if(FArm !is null && FArmC !is null){
		FArmC.SetOffset(FArm.getOffset());
		FArmC.SetVisible(FArm.isVisible());
	}
	
	if(BArm !is null && BArmC !is null){
		BArmC.SetOffset(BArm.getOffset());
		BArmC.SetVisible(BArmC.isVisible());
	}
	
	if(shirt !is null){
		shirt.SetFrameIndex(this.getFrameIndex());
		shirt.SetVisible(this.isVisible());
		shirt.SetOffset(this.getOffset());
	}
}

void addEnchantSprite(CSprite @this, int Enchant){
	this.RemoveSpriteLayer("enchant_marm_"+Enchant);
	CSpriteLayer@ frontarm = this.addSpriteLayer("enchant_marm_"+Enchant, EnchantName(Enchant)+"_Enchant_Arms.png" , 32, 32, 0, 0);

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		Animation@ anim2 = frontarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(4);
		Animation@ anim3 = frontarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(2);
		Animation@ anim4 = frontarm.addAnimation("point", 0, false);
		anim4.AddFrame(6);
		frontarm.SetRelativeZ(3.1f-f32(Enchantment::length-Enchant)/100.0f);
		frontarm.SetLighting(false);
	}
	
	this.RemoveSpriteLayer("enchant_sarm_"+Enchant);
	CSpriteLayer@ backarm = this.addSpriteLayer("enchant_sarm_"+Enchant, EnchantName(Enchant)+"_Enchant_Arms.png" , 32, 32, 0, 0);

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		Animation@ anim2 = backarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(5);
		Animation@ anim3 = backarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(3);
		Animation@ anim4 = backarm.addAnimation("point", 0, false);
		anim4.AddFrame(7);
		backarm.SetRelativeZ(-2.9f-f32(Enchantment::length-Enchant)/100.0f);
		backarm.SetLighting(false);
	}
	
	this.RemoveSpriteLayer("enchant_"+Enchant);
	CSpriteLayer@ body = this.addSpriteLayer("enchant_"+Enchant,EnchantName(Enchant)+"_Enchant_Chest.png" , 32, 32, 0, 0);

	if (body !is null)
	{
		Animation@ anim1 = body.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		
		body.SetRelativeZ(0.24f-f32(Enchantment::length-Enchant)/100.0f);
		body.SetLighting(false);
	}
}

void removeEnchantSprite(CSprite @this, int Enchant){

	this.RemoveSpriteLayer("enchant_marm_"+Enchant);
	this.RemoveSpriteLayer("enchant_sarm_"+Enchant);
	this.RemoveSpriteLayer("enchant_"+Enchant);

}















