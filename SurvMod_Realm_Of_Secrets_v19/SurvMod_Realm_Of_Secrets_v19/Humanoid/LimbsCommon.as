
#include "EquipmentCommon.as";
#include "HandleDeath.as";

namespace BodyType
{
	enum type
	{
		None = 0,
		Flesh = 1,
		PinkFlesh,
		Fairy,
		Gold,
		Shadow,
		Wraith,
		Zombie,
		Golem,
		Wood,
		Cannibal,
		Ghoul,
	};
}

namespace EyeType
{
	enum type
	{
		None = 0,
		Normal = 1,
		Seared,
	};
}

namespace HeartType
{
	enum type
	{
		Missing = 0,
		Beating = 1,
		Stopped = 2,
	};
}

string getBodyTypeName(int type){

	if(type == BodyType::Flesh)return "Human";
	if(type == BodyType::Wraith)return "Wraith";
	if(type == BodyType::PinkFlesh)return "PinkFlesh";
	if(type == BodyType::Fairy)return "Fairy";
	if(type == BodyType::Gold)return "Gold";
	if(type == BodyType::Shadow)return "Shadow";
	if(type == BodyType::Zombie)return "Zombie";
	if(type == BodyType::Golem)return "Golem";
	if(type == BodyType::Wood)return "Wood";
	if(type == BodyType::Cannibal)return "Cannibal";
	if(type == BodyType::Ghoul)return "Ghoul";
	
	return "None";

}

///////////Important stuff



f32 getLimbSpeed(int type){

	if(type == BodyType::Gold)return 0.5f;

	return 1.0f;
}

f32 getLimbStrength(int type){

	return 1.0f;
}

f32 getLimbHealth(int type){

	if(type == BodyType::Gold)return 2.0f;
	
	if(type == BodyType::Golem)return 1.0f;

	return 0.0f;
}


///////////////Optional stuff


bool isFlesh(int limbtype){

	if(isLivingFlesh(limbtype))return true;
	if(limbtype == BodyType::Zombie)return true;
	if(limbtype == BodyType::Ghoul)return true;
	
	return false;

}

bool isLivingFlesh(int limbtype){

	if(limbtype == BodyType::Flesh)return true;
	if(limbtype == BodyType::PinkFlesh)return true;
	if(limbtype == BodyType::Fairy)return true;
	if(limbtype == BodyType::Cannibal)return true;
	
	return false;

}

bool isLimbUsable(CBlob @this, int limbtype){

	if(isLivingFlesh(limbtype) && this.hasTag("alive"))return true;

	if(limbtype <= 0)return false;
	
	if(!this.hasTag("animated"))return false;
	
	return true;

}

//////////////Code

bool replaceLimb(CBlob @this, string limb, int new){
	
	return morphLimb(this,limb,new);
}

bool morphLimb(CBlob @this, string limb, int new){
	
	if(new == BodyType::Zombie)
	if(this.get_u8(limb+"_type") == BodyType::Cannibal)
	new = BodyType::Ghoul;
	
	this.set_u8(limb+"_type", new);
	if(isServer()){
		this.Sync(limb+"_type", true);
	}
	
	if(!isLimbUsable(this,new))unEquipType(this,null,limb);
	
	return true;
}

int hasEye(CBlob @this, int eye){
	int eyes = 0;
	if(this.get_u8("fore_eye") == eye)eyes++;
	if(this.get_u8("back_eye") == eye)eyes++;
	return eyes;
}

bool changeEye(CBlob @this, int new){
	string[] eyes = {"fore_eye","back_eye"};
	for(int i = 0;i < eyes.length;i++){
		string eye = eyes[i];
		if(this.get_u8(eye) == new || this.get_u8(eye) == EyeType::None)continue;
		
		this.set_u8(eye,new);
		if(isServer())this.Sync(eye,true);
		return true;
	}
	return false;
}