
#include "Hitters.as";
#include "Knocked.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "HumanoidAnimCommon.as";
#include "Health.as";
#include "HandleDeath.as";
#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
	int body = BodyType::Flesh;

	LimbInfo limbs;
	
	setUpLimbs(limbs,body,body,CoreType::Beating,body,body,body,body);
	this.Tag("alive");
	
	//body = BodyType::Golem;
	//setUpLimbs(limbs,body,body,CoreType::WoodSoul,body,body,body,body);
	//this.Tag("animated");
	
	this.set("limbInfo", @limbs);
	
	this.set_u8("fore_eye", EyeType::Normal);
	this.set_u8("back_eye", EyeType::Normal);
	
	this.addCommandID("limb_sync");
	this.addCommandID("limb_hit");
	this.addCommandID("body_sync");
	this.addCommandID("core_sync");
	
	if(isServer())this.Tag("sync_limbs");
	
	this.set_u32("immortality",0);
}

void onTick(CBlob@ this)
{
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	if(!this.hasTag("bald"))
	if(limbs.Head == BodyType::Golem || limbs.Head == BodyType::Wood || limbs.Head == BodyType::Metal){
		this.Tag("bald");
	}
	

	if(this.hasTag("alive")){
		if(!isLimbUsable(this,LimbSlot::Head) || !isFlesh(getLimb(limbs,LimbSlot::Head))){ //If our head isn't working or isn't flesh, commit die
			if(this.get_u32("immortality") < getGameTime()){
				if(limbs.Core == CoreType::Beating)limbs.Core = CoreType::Stopped;
				
				if(this.hasTag("animated") || this.hasTag("spirit_infested")){
					this.Untag("alive");
				} else {
					Kill(this,null,Hitters::nothing);
				}
			} else {
				this.Tag("pure_life_save");
			}
		} else {
			if(limbs.Core == CoreType::Stopped)limbs.Core = CoreType::Beating;
			
			if(limbs.Core != CoreType::Beating){ //If we're alive and working, we need to take damage if we have no heart pumping blood
				if(this.get_u32("immortality") < getGameTime()){
					if(getGameTime() % 30 == 0){
						if(isServer()){
							for(int l = 0;l < LimbSlot::length;l++)
							if(isFlesh(getLimb(limbs,l)) && getLimbHealth(limbs,l) > 0)hitLimb(this, l, 0.5f, 0);
						}
						if(isClient()){
							if(getGameTime() % 60 == 0)Sound::Play("gasp.ogg", this.getPosition(), 3.0f);
							else Sound::Play("gasp.ogg", this.getPosition(), 3.0f, 0.8f);
						}
					}
				} else {
					this.Tag("pure_life_save");
				}
			}
		}
	}
	
	
	u32 Enchants = this.get_u32("enchants");
	if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
		if(!hasEnchant(Enchants,Enchantment::Soul)){
			Enchants = addEnchant(Enchants,Enchantment::Soul);
		}
	} else {
		if(hasEnchant(Enchants,Enchantment::Soul)){
			Enchants = removeEnchant(Enchants,Enchantment::Soul);
		}
	}
	if(this.hasTag("alive"))this.Untag("spirit_infested");
	if((limbs.Core >= CoreType::WoodSpirit && limbs.Core <= CoreType::GoldSpirit) || this.hasTag("spirit_infested")){
		if(isServer() && this.hasTag("spirit_infested"))this.Sync("spirit_infested",true);
		if(!hasEnchant(Enchants,Enchantment::Spirit)){
			Enchants = addEnchant(Enchants,Enchantment::Spirit);
		}
	} else {
		if(hasEnchant(Enchants,Enchantment::Spirit)){
			Enchants = removeEnchant(Enchants,Enchantment::Spirit);
		}
	}
	
	this.set_u32("enchants",Enchants);
	
	if(AnimatedEnchant(this))this.Tag("animated");
	else {
		if(this.hasTag("animated")){
			if(this.hasTag("alive")){
				this.Untag("animated");
			} else {
				Kill(this,null,Hitters::nothing);
			}
		}
	}
	
	//addEnchant(this,Enchantment::Gem);
	//addEnchant(this,Enchantment::WeakGem);
	//addEnchant(this,Enchantment::StrongGem);
	//addEnchant(this,Enchantment::UnstableGem);
	
	RunnerMoveVars@ moveVars;
	if(this.get("moveVars", @moveVars))
	{
		if(this.hasTag("pregnant"))moveVars.walkFactor *= 0.5; //Sigh
		
		if(isLimbUsable(this,LimbSlot::FrontLeg) && isLimbUsable(this,LimbSlot::BackLeg)){ //If both legs functional
			moveVars.walkFactor *= 0.5f*getLimbSpeed(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.5f*getLimbSpeed(this,LimbSlot::BackLeg,limbs.BackLeg); //Simply multiply each half of the movespeed by it's multiplier
			moveVars.jumpFactor *= 0.5f*getLimbStrength(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.5f*getLimbStrength(this,LimbSlot::BackLeg,limbs.BackLeg);
		} else
		if(isLimbUsable(this,LimbSlot::FrontLeg) && isLimbMovable(this,LimbSlot::BackLeg)){ //If backleg hobbling
			moveVars.walkFactor *= 0.5f*getLimbSpeed(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.2f*getLimbSpeed(this,LimbSlot::BackLeg,limbs.BackLeg);
			moveVars.jumpFactor *= 0.5f*getLimbStrength(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.35f*getLimbStrength(this,LimbSlot::BackLeg,limbs.BackLeg);
		} else
		if(isLimbMovable(this,LimbSlot::FrontLeg) && isLimbUsable(this,LimbSlot::BackLeg)){ //If frontleg hobbling
			moveVars.walkFactor *= 0.2f*getLimbSpeed(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.5f*getLimbSpeed(this,LimbSlot::BackLeg,limbs.BackLeg);
			moveVars.jumpFactor *= 0.35f*getLimbStrength(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.5f*getLimbStrength(this,LimbSlot::BackLeg,limbs.BackLeg);
		} else
		if(isLimbMovable(this,LimbSlot::FrontLeg) && isLimbMovable(this,LimbSlot::BackLeg)){ //If both hobbling
			moveVars.walkFactor *= 0.2f*getLimbSpeed(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.2f*getLimbSpeed(this,LimbSlot::BackLeg,limbs.BackLeg); //Hobbling limbs are 40% efficient
			moveVars.jumpFactor *= 0.35f*getLimbStrength(this,LimbSlot::FrontLeg,limbs.FrontLeg) + 0.35f*getLimbStrength(this,LimbSlot::BackLeg,limbs.BackLeg);
		} else { //Crawling
			///Crawling is handled by Crawling.as
		}
	}
	
	if(this.isAttached()){
		moveVars.walkFactor = 1.0f;
		moveVars.jumpFactor = 1.0f;
	}
	if(moveVars.walkFactor > 1.25f)moveVars.walkFactor = 1.25f+(moveVars.walkFactor-1.25f)*0.5f;
	//if(this.getVelocity().x != 0)print("Whee"+s32(this.getVelocity().x));
	
	///Beep boop golem online
	if(isServer())
	if(getGameTime() % 32 == 0){
		if(this.getPlayer() is null && (this.hasTag("animated")||this.hasTag("alive"))){
			if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
				this.getBrain().server_SetActive(true);
			}
		}
	}
	
	if(getGameTime() % 30 == 5 && isServer()){
		if(this.exists("animated"))this.Sync("animated",true);
		if(!this.hasTag("alive"))this.Sync("alive",true);
	}
	
	if(isServer()){
		if(this.hasTag("sync_limbs") || ((getGameTime()+this.getNetworkID()) % 300) == 0){
			syncBody(this);
			this.Untag("sync_limbs");
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("limb_hit"))
	{
		u8 Slot = params.read_u8();
		u8 Type = params.read_u8();
		f32 Health = params.read_f32();
		
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		if(isClient()){
			if(Type == BodyType::None)GibLimb(this,Slot,Type);
			
			if(Slot == LimbSlot::Head)this.set_f32("head_hit",1.0f);
			else if(Slot == LimbSlot::Torso)this.set_f32("torso_hit",1.0f);
			else if(Slot == LimbSlot::FrontLeg)this.set_f32("front_leg_hit",1.0f);
			else if(Slot == LimbSlot::BackLeg)this.set_f32("back_leg_hit",1.0f);
			else if(Slot == LimbSlot::MainArm)this.set_f32("main_arm_hit",1.0f);
			else if(Slot == LimbSlot::SubArm)this.set_f32("sub_arm_hit",1.0f);
		}
		
		setLimb(limbs,Slot, Type);
		setLimbHealth(limbs,Slot, Health);
		
		if(isServer()){
			if(Slot == LimbSlot::MainArm || Slot == LimbSlot::SubArm){
				EquipmentInfo@ equip;
				if(this.get("equipInfo", @equip)){
					int type = checkEquipped(equip,Slot);
					if(neesdUsableArm(type)){
						if(!isLimbUsable(this,Slot))unequipType(this,null,Slot,true);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("limb_sync"))
	{
		u8 Slot = params.read_u8();
		u8 Type = params.read_u8();
		f32 Health = params.read_f32();
		
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		setLimb(limbs,Slot, Type);
		setLimbHealth(limbs,Slot, Health);
	}
	
	if (cmd == this.getCommandID("core_sync"))
	{
		u8 Type = params.read_u8();
		
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		limbs.Core = Type;
	}

	if (cmd == this.getCommandID("body_sync"))
	{
		u8 head = params.read_u8();
		u8 torso = params.read_u8();
		u8 core = params.read_u8();
		
		f32 headhp = params.read_f32();
		f32 torsohp = params.read_f32();
		u8 marm = params.read_u8();
		f32 marmhp = params.read_f32();
		u8 sarm = params.read_u8();
		f32 sarmhp = params.read_f32();
		u8 fleg = params.read_u8();
		f32 fleghp = params.read_f32();
		u8 bleg = params.read_u8();
		f32 bleghp = params.read_f32();
		
		
		
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		
		limbs.Head = head;
		limbs.Torso = torso;
		limbs.Core = core;
		
		limbs.MainArm = marm;
		limbs.SubArm = sarm;
		limbs.FrontLeg = fleg;
		limbs.BackLeg = bleg;
		
		limbs.HeadHealth = headhp;
		limbs.TorsoHealth = torsohp;
		limbs.MainArmHealth = marmhp;
		limbs.SubArmHealth = sarmhp;
		limbs.FrontLegHealth = fleghp;
		limbs.BackLegHealth = bleghp;
	}
}

void onDie(CBlob@ this){
	if(isServer())
	if(!this.hasTag("dropped_limbs")){
		LimbInfo@ limbs;
		if(!this.get("limbInfo", @limbs))return;
		for(int i = 0;i < LimbSlot::length;i++)
		if(i != LimbSlot::Torso)
		if(getLimbHealth(limbs,i) > 0.0f){
			if(getLimbBlob(getLimb(limbs,i),i) != ""){
				server_CreateBlob(getLimbBlob(getLimb(limbs,i),i),-1,this.getPosition());
			}
		}
		this.Tag("dropped_limbs");
	}
}