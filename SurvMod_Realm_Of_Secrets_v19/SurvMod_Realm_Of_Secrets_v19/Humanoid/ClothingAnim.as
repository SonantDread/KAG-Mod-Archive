
#include "EquipmentCommon.as";

void onInit(CSprite @this){

	this.RemoveSpriteLayer("front_sleeve");
	CSpriteLayer@ frontarm = this.addSpriteLayer("front_sleeve", "flax_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		frontarm.SetRelativeZ(3.1f);
	}
	
	this.RemoveSpriteLayer("back_sleeve");
	CSpriteLayer@ backarm = this.addSpriteLayer("back_sleeve", "flax_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
		backarm.SetRelativeZ(-2.9f);
	}
	
	this.RemoveSpriteLayer("shirt");
	CSpriteLayer@ body = this.addSpriteLayer("shirt", "flax_Male_Chest.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (body !is null)
	{
		Animation@ anim1 = body.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		body.SetRelativeZ(0.24f);
	}

}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();

	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("front_sleeve");
	CSpriteLayer @BArmC = this.getSpriteLayer("back_sleeve");
	
	CSpriteLayer @shirt = this.getSpriteLayer("shirt");
	
	if(FArm !is null && FArmC !is null){
		FArmC.SetOffset(FArm.getOffset());
		FArmC.SetVisible(FArm.isVisible());
	} else return;
	
	if(BArm !is null && BArmC !is null){
		BArmC.SetOffset(BArm.getOffset());
		BArmC.SetVisible(BArmC.isVisible());
	} else return;
	
	if(shirt !is null){
		shirt.SetFrameIndex(this.getFrameIndex());
		shirt.SetVisible(this.isVisible());
		shirt.SetOffset(this.getOffset());
	} else return;
	
	CBlob @shirtBlob = null;//getEquippedBlob(blob,"torso");
	string shirtequipname = getEquipmentName(blob.get_u16("tors_equip"));
	int team = Maths::Min(blob.getTeamNum(),7);
	
	string path = getFilePath(getCurrentScriptName())+"/ArmourSprites/";
	
	if(shirtequipname == "None"){
		FArmC.SetVisible(false);
		BArmC.SetVisible(false);
		shirt.SetVisible(false);
	} else {
		string sex = "_Male";
		if(blob.get_u8("sex") == 1)sex = "_Female";
		if(blob.hasTag("pregnant"))sex = "_Pregnant";
		
		if(shirt.getFilename() != path+shirtequipname+sex+"_Chest.png"){
			shirt.ReloadSprite(shirtequipname+sex+"_Chest.png", 32, 32, team, 0);
			FArmC.ReloadSprite(shirtequipname+"_Arms.png", 32, 32, team, 0);
			BArmC.ReloadSprite(shirtequipname+"_Arms.png", 32, 32, team, 0);
		}
	}

}