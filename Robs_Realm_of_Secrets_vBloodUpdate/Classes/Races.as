#include "RunnerCommon.as";
#include "ItemsCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("race",0);
	this.set_u8("race_sprite",-1);
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("checkedfaceless")){
		if(XORRandom(2000) == 0)if(this.getTeamNum() < 20)this.Tag("faceless");
		this.Tag("checkedfaceless");
	}
	
	int Race = this.get_u8("race");
	
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars)){
		if(Race == 2){
			moveVars.jumpFactor *= 0.9f;
			moveVars.walkFactor *= 0.9f;
		}
		if(Race == 3){
			moveVars.walkFactor *= 1.5f;
		}
		if(Race == 6){
			moveVars.jumpFactor *= 1.5f;
			moveVars.walkFactor *= 0.5f;
		}
		if(Race == 7){
			moveVars.jumpFactor *= 1.1f;
			moveVars.walkFactor *= 1.1f;
		}
		if(Race == 8){
			moveVars.jumpFactor *= 1.5f;
			moveVars.walkFactor *= 1.5f;
		}
		if(Race == 9){
			moveVars.jumpFactor *= 2.0f;
			moveVars.walkFactor *= 2.0f;
		}
	}
	
	this.Untag("flying");
	
	if(Race == 1){
		this.Tag("evil");
		this.Tag("pure_corruption");
	} else {
		this.Untag("pure_corruption");
	}

	if(Race == 3){
		this.Tag("flying");
		this.set_s16("blood",500);
	}
	
	if(Race == 5){
		this.Tag("onewithnature");
	}
	
	if(Race == 6){
		this.Tag("gold");
	}
	
	if(Race == 7){
		this.Tag("holy");
	}
	
	if(Race == 8){
		this.Tag("holy");
	}
	
	if(getNet().isServer()){
		if(this.get_u8("race_sprite") != Race || XORRandom(1000) == 0)this.Sync("race", true);
	}
}


void onTick(CSprite@ this)
{
	int Race = this.getBlob().get_u8("race");
	int RaceSpr = this.getBlob().get_u8("race_sprite");
	if(Race != RaceSpr){
		string modpath = getFilePath(getCurrentScriptName())+"/Sprites/";
		
		string classname = "Builder";
		if(this.getBlob().getName() == "knight")classname = "Knight";
		if(this.getBlob().getName() == "archer")classname = "Archer";
		
		string racename = "Human";
		if(Race == 0)racename = "Human";
		if(Race == 1)racename = "Shadow";
		if(Race == 2)racename = "Risen";
		if(Race == 3)racename = "Faceless";
		if(Race == 4)racename = "Lifeless";
		if(Race == 5)racename = "Druid";
		if(Race == 6)racename = "Golden";
		if(Race == 7)racename = "Holy";
		if(Race == 8)racename = "Ascended";
		if(Race == 9)racename = "Husk";
		
		string texname = modpath+racename+"_"+classname+".png";
		
		print(getFilePath(getCurrentScriptName()));
		
		this.ReloadSprite(texname);
		
		CSpriteLayer@ head = this.getSpriteLayer("head");
		if(head !is null)head.ReloadSprite(modpath+racename+"_Heads.png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		
		if(this.getBlob().getName() == "archer"){
			if(this.getSpriteLayer("frontarm") !is null)
			this.getSpriteLayer("frontarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("backarm") !is null)
			this.getSpriteLayer("backarm").ReloadSprite(modpath+racename+"_"+classname+".png",32,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("quiver") !is null)
			this.getSpriteLayer("quiver").ReloadSprite(modpath+racename+"_"+classname+".png",16,16,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("hook") !is null)
			this.getSpriteLayer("hook").ReloadSprite(modpath+racename+"_"+classname+".png",16,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			if(this.getSpriteLayer("rope") !is null)
			this.getSpriteLayer("rope").ReloadSprite(modpath+racename+"_"+classname+".png",32,8,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(this.getBlob().getName() == "knight" && DetectSword(this.getBlob()) != 0){
			if(this.getSpriteLayer("chop") !is null)
			this.getSpriteLayer("chop").ReloadSprite(modpath+racename+"_"+classname+".png",32,32,this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
		
		if(Race == 3){
			this.RemoveSpriteLayer("cape");
			CSpriteLayer@ cape = this.addSpriteLayer("cape", modpath+racename+"_Cape.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			cape.SetRelativeZ(-1.0f);
		} else {
			this.RemoveSpriteLayer("cape");
		}
		
		this.getBlob().set_u8("race_sprite",Race);
	}
	

}