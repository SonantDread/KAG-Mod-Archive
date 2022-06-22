
#include "EquipmentCommon.as";
#include "HandleDeath.as";
#include "CommonParticles.as"
#include "EnchantCommon.as"

shared class LimbInfo
{
	u8 Head;
	
	u8 Torso;
	u8 Core;
	
	u8 MainArm;
	u8 SubArm;
	u8 FrontLeg;
	u8 BackLeg;
	
	f32 HeadHealth;
	f32 TorsoHealth;
	f32 MainArmHealth;
	f32 SubArmHealth;
	f32 FrontLegHealth;
	f32 BackLegHealth;
};

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
		Metal
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

namespace CoreType
{
	enum type
	{
		Missing = 0,
		Beating,
		Stopped,
		WoodSoul,
		StoneSoul,
		GoldSoul,
		WoodSpirit,
		StoneSpirit,
		GoldSpirit
	};
}

namespace LimbSlot
{
	enum type
	{
		MainArm = 0,
		SubArm,
		Torso,
		Head,
		FrontLeg,
		BackLeg,
		length
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
	if(type == BodyType::Metal)return "Metal";
	
	return "None";

}

string getCoreName(int type){

	if(type == CoreType::Missing)return "Missing";
	if(type == CoreType::Beating)return "Heart: Beating";
	if(type == CoreType::Stopped)return "Heart: Stopped";
	if(type == CoreType::WoodSoul)return "Soul Core: Wooden";
	if(type == CoreType::StoneSoul)return "Soul Core: Stone";
	if(type == CoreType::GoldSoul)return "Soul Core: Golden";
	if(type == CoreType::WoodSpirit)return "Spirit Core: Wooden";
	if(type == CoreType::StoneSpirit)return "Spirit Core: Stone";
	if(type == CoreType::GoldSpirit)return "Spirit Core: Golden";
	
	return "Unknown";

}

///////////Important stuff

f32 getLimbMaxHealth(int Slot, int type){
	
	if(type <= BodyType::None)return 0.0f;
	
	f32 amount = 10.0f;

	switch(type){
		case BodyType::Flesh: amount = 10.0f;break;
		case BodyType::PinkFlesh: amount = 8.0f;break;
		case BodyType::Fairy: amount = 6.0f;break;
		case BodyType::Gold: amount = 20.0f;break;
		case BodyType::Metal: amount = 20.0f;break;
		case BodyType::Wraith: amount = 8.0f;break;
		case BodyType::Zombie: amount = 8.0f;break;
		case BodyType::Golem: amount = 15.0f;break;
		case BodyType::Wood: amount = 8.0f;break;
	}
	
	if(Slot == LimbSlot::FrontLeg || Slot == LimbSlot::BackLeg)amount *= 1.5f;
	if(Slot == LimbSlot::Torso)amount *= 2.0f;

	return amount;
}

f32 getLimbGibHealth(int Slot, int type){
	
	f32 amount = 0.0f;
	
	switch(type){
		case BodyType::Flesh: amount = -10.0f;break;
		case BodyType::PinkFlesh: amount = -8.0f;break;
		case BodyType::Fairy: amount = -6.0f;break;
		case BodyType::Shadow: amount = -10.0f;break;
		case BodyType::Zombie: amount = -8.0f;break;
		case BodyType::Cannibal: amount = -10.0f;break;
		case BodyType::Ghoul: amount = -10.0f;break;
	}
	
	if(Slot == LimbSlot::MainArm || Slot == LimbSlot::SubArm)amount *= 1.5f;
	if(Slot == LimbSlot::Torso || Slot == LimbSlot::Head)amount *= 2.0f;

	return amount;
}

f32 getLimbSpeed(CBlob @this, int Slot, int type){

	f32 scale = 1.0f;
	u32 Enchants = this.get_u32("enchants");

	if(type == BodyType::Gold)scale = 0.5f;
	if(type == BodyType::Metal)scale = 0.75f;
	if(type == BodyType::Golem)scale = 0.75f;
	if(type == BodyType::Fairy)scale = 2.0f;
	if(type == BodyType::Wood)scale = 1.5f;
	
	f32 gemScale = 1.0f;
	
	if(hasEnchant(Enchants,Enchantment::WeakGem))gemScale += 0.25f;
	if(hasEnchant(Enchants,Enchantment::Gem))gemScale += 0.25f;
	if(hasEnchant(Enchants,Enchantment::StrongGem))gemScale += 0.5f;
	if(hasEnchant(Enchants,Enchantment::UnstableGem))gemScale += 0.5f;

	if(hasEnchant(Enchants,Enchantment::Nature))scale *= 0.75f;

	return scale*gemScale;
}

f32 getLimbStrength(CBlob @this, int Slot, int type){
	
	f32 scale = 1.0f;
	u32 Enchants = this.get_u32("enchants");

	if(type == BodyType::Gold)scale = 1.5f;
	if(type == BodyType::Metal)scale = 1.5f;
	if(type == BodyType::Fairy)scale = 0.5f;
	if(type == BodyType::Golem)scale = 1.5f;
	
	f32 gemScale = 1.0f;
	
	if(hasEnchant(Enchants,Enchantment::WeakGem))gemScale += 0.25f;
	if(hasEnchant(Enchants,Enchantment::Gem))gemScale += 0.25f;
	if(hasEnchant(Enchants,Enchantment::StrongGem))gemScale += 0.5f;
	if(hasEnchant(Enchants,Enchantment::UnstableGem))gemScale += 0.5f;
	
	if(hasEnchant(Enchants,Enchantment::Nature))scale *= 1.25f;

	return scale*gemScale;
}


///////////////Optional stuff


bool isFlesh(int limbtype){

	if(isLivingFlesh(limbtype))return true;
	if(limbtype == BodyType::Zombie)return true;
	if(limbtype == BodyType::Ghoul)return true;
	
	return false;

}

bool LimbNeedsAir(int Type, int Slot){

	if(isLivingFlesh(Type) && Slot == LimbSlot::Head)return true;
	
	return false;

}

bool isLivingFlesh(int limbtype){

	if(limbtype == BodyType::Flesh)return true;
	if(limbtype == BodyType::PinkFlesh)return true;
	if(limbtype == BodyType::Fairy)return true;
	if(limbtype == BodyType::Cannibal)return true;
	
	return false;

}


bool isLimbMovable(CBlob @this, int slot){

	LimbInfo@ limbs;
	if(!this.get("limbInfo", @limbs))return true;

	u8 limbtype = getLimb(limbs,slot);

	if(limbtype <= 0)return false;
	
	if(isLimbUsable(this,LimbSlot::Torso) || this.hasTag("animated") || LimbManipulationEnchant(this))return true;
	
	return false;

}

bool isLimbUsable(CBlob @this, int slot){

	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return true;

	u8 limbtype = getLimb(limbs,slot);
	if(limbtype <= 0)return false;

	if(getLimbHealth(limbs,slot) > 0.0f)
	if(isLivingFlesh(limbtype) && this.hasTag("alive"))return true;

	if(this.hasTag("animated"))return true;
	
	if((slot == LimbSlot::MainArm || slot == LimbSlot::SubArm) && LimbManipulationEnchant(this))return true;
	
	if(this.hasTag("pure_life") && this.hasTag("alive")){
		this.Tag("pure_life_save");
		return true;
	}
	
	return false;

}

bool canLimbAttack(CBlob @this, int slot){

	if(this.get_u8("knocked") > 0)return false;

	if(!isLimbUsable(this,slot))return false;
	
	if(this.getCarriedBlob() !is null){
		if(this.getCarriedBlob().hasTag("temp blob"))return false;
	}
	
	if(this.get_TileType("buildtile") > 0)return false;

	if(this.isAttachedToPoint("BED"))return false;
	
	return true;

}

bool canHitLimb(CBlob @this, int slot){

	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return true;

	u8 limbtype = getLimb(limbs,slot);

	if(limbtype <= 0)return false;
	
	return true;

}

string getLimbBlob(int type, int slot){

	if(type == BodyType::Wood){
		if(slot != LimbSlot::Torso)return "stick";
		else return "log";
	}
	
	//if(type == BodyType::Gold)return "gold_drop";
	if(type == BodyType::Metal)return "metal_drop";
	
	if(type == BodyType::Flesh)if(slot != LimbSlot::Head)return "flesh_limb";
	//if(type == BodyType::PinkFlesh)return "steak";
	if(type == BodyType::Zombie)if(slot != LimbSlot::Head)return "rotten_limb";
	
	return "";

}

int getTypeFromBlob(string blobname, int slot){

	if(slot == LimbSlot::Torso){
		if(blobname == "log")return BodyType::Wood;
	} else {
		if(blobname == "stick")return BodyType::Wood;
	}
	
	if(blobname == "mat_wood")return BodyType::Wood;
	if(blobname == "mat_stone")return BodyType::Golem;
	if(blobname == "gold_bar")return BodyType::Gold;
	if(blobname == "metal_bar")return BodyType::Metal;
	
	if(blobname == "flesh_limb")return BodyType::Flesh;
	if(blobname == "steak")return BodyType::PinkFlesh;
	if(blobname == "rotten_limb")return BodyType::Zombie;

	return 0;

}

//////////////Code

bool replaceLimb(CBlob @this, int slot, int new, f32 HP){
	
	LimbInfo@ limbs;
	if(!this.get("limbInfo", @limbs))return false;
	
	setLimbHealth(limbs, slot, HP);
	
	return morphLimb(this,slot,new, true);
}

bool morphLimb(CBlob @this, int slot, int new, bool ignoreHP = false){
	
	LimbInfo@ limbs;
	if(!this.get("limbInfo", @limbs))return false;
	
	if(new == BodyType::Zombie)
	if(getLimb(limbs,slot) == BodyType::Cannibal)
	new = BodyType::Ghoul;
	
	f32 hp = 1.0f;
	if(getLimbMaxHealth(slot,getLimb(limbs,slot)) > 0)hp = getLimbHealth(limbs,slot)/getLimbMaxHealth(slot,getLimb(limbs,slot));
	
	setLimb(limbs,slot,new);
	
	if(!ignoreHP)setLimbHealth(limbs, slot, getLimbMaxHealth(slot,new)*hp); //Morphing copies the hp percentage
	
	if(isServer()){
		syncLimb(this,slot);
		
		if(slot == LimbSlot::MainArm || slot == LimbSlot::SubArm){
			EquipmentInfo@ equip;
			if(this.get("equipInfo", @equip)){
				int type = checkEquipped(equip,slot);
				if(neesdUsableArm(type)){
					if(!isLimbUsable(this,slot))unequipType(this,null,slot,true);
				} else {
					if(!canHitLimb(this,slot))unequipType(this,null,slot,true);
				}
			}
		}
		if(slot == LimbSlot::Head){
			if(!canHitLimb(this,slot))unequipType(this,null,slot,true);
		}
	}
	
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

void setUpLimbs(LimbInfo@ limbs,u8 Head,u8 Torso,u8 Core,u8 MainArm,u8 SubArm,u8 FrontLeg,u8 Backleg){
	limbs.Head = Head;
	limbs.Torso = Torso;
	limbs.Core = Core;
	
	limbs.MainArm = MainArm;
	limbs.SubArm = SubArm;
	
	limbs.FrontLeg = FrontLeg;
	limbs.BackLeg = Backleg;
	
	limbs.HeadHealth = getLimbMaxHealth(LimbSlot::Head,Head);
	limbs.TorsoHealth = getLimbMaxHealth(LimbSlot::Torso,Torso);
	limbs.MainArmHealth = getLimbMaxHealth(LimbSlot::MainArm,MainArm);
	limbs.SubArmHealth = getLimbMaxHealth(LimbSlot::SubArm,SubArm);
	limbs.FrontLegHealth = getLimbMaxHealth(LimbSlot::FrontLeg,FrontLeg);
	limbs.BackLegHealth = getLimbMaxHealth(LimbSlot::BackLeg,Backleg);
}

u8 getLimb(LimbInfo@ limbs,u8 slot){
	switch(slot){
		case LimbSlot::Head:{
			return limbs.Head;}
	
		case LimbSlot::Torso:{
			return limbs.Torso;}
			
		case LimbSlot::MainArm:{
			return limbs.MainArm;}
			
		case LimbSlot::SubArm:{
			return limbs.SubArm;}
			
		case LimbSlot::FrontLeg:{
			return limbs.FrontLeg;}
			
		case LimbSlot::BackLeg:{
			return limbs.BackLeg;}
	}
	return 0;
}

void setLimb(LimbInfo@ limbs,u8 slot, u8 type){
	switch(slot){
		case LimbSlot::Head:{
			limbs.Head = type;
		break;}
	
		case LimbSlot::Torso:{
			limbs.Torso = type;
		break;}
			
		case LimbSlot::MainArm:{
			limbs.MainArm = type;
		break;}
			
		case LimbSlot::SubArm:{
			limbs.SubArm = type;
		break;}
			
		case LimbSlot::FrontLeg:{
			limbs.FrontLeg = type;
		break;}
			
		case LimbSlot::BackLeg:{
			limbs.BackLeg = type;
		break;}
	}
}

f32 getLimbHealth(LimbInfo@ limbs,u8 slot){
	switch(slot){
		case LimbSlot::Head:{
			return limbs.HeadHealth;}
	
		case LimbSlot::Torso:{
			return limbs.TorsoHealth;}
			
		case LimbSlot::MainArm:{
			return limbs.MainArmHealth;}
			
		case LimbSlot::SubArm:{
			return limbs.SubArmHealth;}
			
		case LimbSlot::FrontLeg:{
			return limbs.FrontLegHealth;}
			
		case LimbSlot::BackLeg:{
			return limbs.BackLegHealth;}
	}
	return 0.0f;
}

void setLimbHealth(LimbInfo@ limbs,u8 slot, f32 hp){
	switch(slot){
		case LimbSlot::Head:{
			limbs.HeadHealth = hp;
		break;}
		
		case LimbSlot::Torso:{
			limbs.TorsoHealth = hp;
		break;}
			
		case LimbSlot::MainArm:{
			limbs.MainArmHealth = hp;
		break;}
			
		case LimbSlot::SubArm:{
			limbs.SubArmHealth = hp;
		break;}
			
		case LimbSlot::FrontLeg:{
			limbs.FrontLegHealth = hp;
		break;}
			
		case LimbSlot::BackLeg:{
			limbs.BackLegHealth = hp;
		break;}
	}
}

void healLimb(LimbInfo@ limbs,u8 slot, f32 hp){
	switch(slot){
		case LimbSlot::Head:{
			limbs.HeadHealth = Maths::Min(limbs.HeadHealth+hp,getLimbMaxHealth(LimbSlot::Head,limbs.Head));
		break;}
		
		case LimbSlot::Torso:{
			limbs.TorsoHealth = Maths::Min(limbs.TorsoHealth+hp,getLimbMaxHealth(LimbSlot::Torso,limbs.Torso));
		break;}
			
		case LimbSlot::MainArm:{
			limbs.MainArmHealth = Maths::Min(limbs.MainArmHealth+hp,getLimbMaxHealth(LimbSlot::MainArm,limbs.MainArm));
		break;}
			
		case LimbSlot::SubArm:{
			limbs.SubArmHealth = Maths::Min(limbs.SubArmHealth+hp,getLimbMaxHealth(LimbSlot::SubArm,limbs.SubArm));
		break;}
			
		case LimbSlot::FrontLeg:{
			limbs.FrontLegHealth = Maths::Min(limbs.FrontLegHealth+hp,getLimbMaxHealth(LimbSlot::FrontLeg,limbs.FrontLeg));
		break;}
			
		case LimbSlot::BackLeg:{
			limbs.BackLegHealth = Maths::Min(limbs.BackLegHealth+hp,getLimbMaxHealth(LimbSlot::BackLeg,limbs.BackLeg));
		break;}
	}
}

void hitLimb(CBlob@ this, u8 Slot, f32 Damage, u8 DamageType){
	if(isServer()){
	
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
	
		f32 hp = getLimbHealth(limbs,Slot);
		
		hp -= Damage;
		
		//print("Hit limb for "+Damage);
		
		if(hp <= getLimbGibHealth(Slot,getLimb(limbs,Slot))){
			if(Slot == LimbSlot::Torso){
				this.server_Die();
				return;
			} else {
				replaceLimb(this,Slot,BodyType::None,0.0f);
				
				CBitStream params;
				params.write_u8(Slot);
				params.write_u8(BodyType::None);
				params.write_f32(0.0f);
				this.SendCommand(this.getCommandID("limb_hit"), params);
			}
		} else {
			CBitStream params;
			params.write_u8(Slot);
			params.write_u8(getLimb(limbs,Slot));
			params.write_f32(hp);
			this.SendCommand(this.getCommandID("limb_hit"), params);
		}
	}
}

void GibLimb(CBlob@ this, u8 Slot, u8 LimbType){
	int particleAmount = 5;
	if(Slot == LimbSlot::Torso)particleAmount = 10;
	
	if(LimbType == BodyType::Golem){
	for(int i = 0;i < particleAmount;i++)makeGibParticle("GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	if(LimbType == BodyType::Wood){
		for(int i = 0;i < particleAmount;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	if(isLivingFlesh(LimbType)){
		for(int i = 0;i < particleAmount;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),4, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	if(LimbType == BodyType::Zombie){
		for(int i = 0;i < particleAmount;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),6, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
}

void syncLimb(CBlob@ this, u8 Slot){
	if(isServer()){
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		CBitStream params;
		params.write_u8(Slot);
		params.write_u8(getLimb(limbs,Slot));
		params.write_f32(getLimbHealth(limbs,Slot));
		this.SendCommand(this.getCommandID("limb_sync"), params);
	}
}

void server_SetCore(CBlob@ this, u8 type){
	LimbInfo@ limbs;
	if(!this.get("limbInfo", @limbs))return;
	
	limbs.Core = type;
	if(isServer()){
		CBitStream params;
		params.write_u8(type);
		this.SendCommand(this.getCommandID("core_sync"), params);
	}
}

void syncBody(CBlob@ this){
	if(isServer()){
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		CBitStream params;
		params.write_u8(limbs.Head);
		params.write_u8(limbs.Torso);
		params.write_u8(limbs.Core);
		
		params.write_f32(limbs.HeadHealth);
		params.write_f32(limbs.TorsoHealth);
		params.write_u8(limbs.MainArm);
		params.write_f32(limbs.MainArmHealth);
		params.write_u8(limbs.SubArm);
		params.write_f32(limbs.SubArmHealth);
		params.write_u8(limbs.FrontLeg);
		params.write_f32(limbs.FrontLegHealth);
		params.write_u8(limbs.BackLeg);
		params.write_f32(limbs.BackLegHealth);
		this.SendCommand(this.getCommandID("body_sync"), params);
	}
}