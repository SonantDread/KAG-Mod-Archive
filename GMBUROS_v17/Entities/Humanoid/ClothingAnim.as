
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "GetPlayerData.as";

void onInit(CSprite @this){

	this.RemoveSpriteLayer("front_sleeve");
	CSpriteLayer@ frontarm = this.addSpriteLayer("front_sleeve", "None_0_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
	CSpriteLayer@ backarm = this.addSpriteLayer("back_sleeve", "None_0_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

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
	CSpriteLayer@ body = this.addSpriteLayer("shirt", "None_0_Chest.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (body !is null)
	{
		Animation@ anim1 = body.addAnimation("male", 0, false);
		anim1.AddFrame(0);
		anim1.AddFrame(1);
		anim1.AddFrame(2);
		anim1.AddFrame(3);
		@anim1 = body.addAnimation("female", 0, false);
		anim1.AddFrame(4);
		anim1.AddFrame(5);
		anim1.AddFrame(6);
		anim1.AddFrame(7);
		@anim1 = body.addAnimation("pregnant", 0, false);
		anim1.AddFrame(8);
		anim1.AddFrame(9);
		anim1.AddFrame(10);
		anim1.AddFrame(11);
		
		body.SetRelativeZ(0.24f);
	}

}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();

	LimbInfo@ limbs;
	if(!blob.get("limbInfo", @limbs))return;
	EquipmentInfo@ equip;
	if(!blob.get("equipInfo", @equip))return;
	int team = getPlayerBlobColour(blob);
	
	CSpriteLayer @FArm = this.getSpriteLayer("frontarm");
	CSpriteLayer @BArm = this.getSpriteLayer("backarm");
	
	CSpriteLayer @FArmC = this.getSpriteLayer("front_sleeve");
	CSpriteLayer @BArmC = this.getSpriteLayer("back_sleeve");
	
	CSpriteLayer @shirt = this.getSpriteLayer("shirt");
	
	CSpriteLayer @helmet = this.getSpriteLayer("helmet");
	
	if(helmet is null){
		if(equip.Head > Equipment::None){
			@helmet = this.addSpriteLayer("helmet", "Helmet.png", 16, 16, team, 0);
			if(helmet !is null){
				//helmet.SetRelativeZ(0.24f);
			}
		}
	} else {
		helmet.SetFrame(equip.HeadType);
		if(blob.hasTag("reload_clothes")){
			helmet.ReloadSprite("Helmet.png", 16, 16, team, 0);
		}
		if(equip.Head <= Equipment::None){
			this.RemoveSpriteLayer("helmet");
		}
	}
	
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
		if(limbs.Torso == BodyType::Golem || limbs.Torso == BodyType::Metal)shirt.SetOffset(this.getOffset()+Vec2f(0,-2));
	} else return;
	
	string shirtequipname = getEquipmentName(equip.Torso)+"_"+equip.TorsoType;
	
	string path = getFilePath(getCurrentScriptName())+"/ArmourSprites/";
	
	if(getEquipmentName(equip.Torso) == "None"){
		FArmC.SetVisible(false);
		BArmC.SetVisible(false);
		shirt.SetVisible(false);
	} else {
		if(shirt.getFilename() != path+shirtequipname+"_Chest.png" || blob.hasTag("reload_clothes")){
			shirt.ReloadSprite(path+shirtequipname+"_Chest.png", 32, 32, team, 0);
			FArmC.ReloadSprite(path+shirtequipname+"_Arms.png", 32, 32, team, 0);
			BArmC.ReloadSprite(path+shirtequipname+"_Arms.png", 32, 32, team, 0);
		}
		
		if(blob.hasTag("pregnant"))shirt.SetAnimation("pregnant");
		else if(limbs.Torso == BodyType::Golem || limbs.Torso == BodyType::Metal)shirt.SetAnimation("pregnant");
		else if(blob.get_u8("sex") == 1)shirt.SetAnimation("female");
		else shirt.SetAnimation("male");
	}
	blob.Untag("reload_clothes");

}