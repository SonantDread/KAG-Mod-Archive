
#include "LimbsCommon.as"
#include "EnchantCommon.as"
#include "Magic.as";

void onInit(CBlob @ this)
{
	this.addCommandID("surgery");
	
	this.addCommandID("operate");
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("surgery"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null && caller.getPlayer() is getLocalPlayer())
		{
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					CBlob@ patient = attach.getAttachedBlob("BED");
					if(patient !is null){
					
						CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 3), "Surgery");
						if (menu !is null)
						{
							LimbInfo@ limbs;
							if(!patient.get("limbInfo", @limbs))return;
							
							CBitStream params;
							string status = "";

							menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							////Head
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::Head);
							status = "\nHealth:"+limbs.HeadHealth;
							if(!canHitLimb(this,LimbSlot::Head))status = "\nMissing";
							CGridButton@ head = menu.AddButton("Surgery_Head.png", limbs.Head, "Head"+status, this.getCommandID("operate"),params);
							params.Clear();

							menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							///Main arm
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::MainArm);
							status = "\nHealth:"+limbs.MainArmHealth;
							if(!canHitLimb(this,LimbSlot::MainArm))status = "\nMissing";
							CGridButton@ main_arm = menu.AddButton("Surgery_Main_Arm.png", limbs.MainArm, "Main Arm"+status, this.getCommandID("operate"),params); //Main arm
							params.Clear();
							
							////Torso/Core
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::Torso);
							status = "\nTorso Health:"+limbs.TorsoHealth;
							CGridButton@ torso = menu.AddButton("Surgery_Core.png", limbs.Core, getCoreName(limbs.Core)+status, this.getCommandID("operate"),params); //Torso/Core
							params.Clear();
							
							/////Sub Arm
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::SubArm);
							status = "\nHealth:"+limbs.SubArmHealth;
							if(!canHitLimb(this,LimbSlot::SubArm))status = "\nMissing";
							CGridButton@ sub_arm = menu.AddButton("Surgery_Sub_Arm.png", limbs.SubArm, "Sub Arm"+status, this.getCommandID("operate"),params); //Sub arm
							params.Clear();
							
							/////Front leg
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::FrontLeg);
							status = "\nHealth:"+limbs.FrontLegHealth;
							if(!canHitLimb(this,LimbSlot::FrontLeg))status = "\nMissing";
							CGridButton@ front_leg = menu.AddButton("Surgery_Front_Leg.png", limbs.FrontLeg, "Front Leg"+status, this.getCommandID("operate"),params); //Front leg
							params.Clear();
							
							menu.AddButton("EquipmentGUI.png", 9, "", this.getCommandID("surgery"),params).SetEnabled(false); //Blank
							
							/////BackLeg
							params.write_u16(caller.getNetworkID());
							params.write_u8(LimbSlot::BackLeg);
							status = "\nHealth:"+limbs.BackLegHealth;
							if(!canHitLimb(this,LimbSlot::BackLeg))status = "\nMissing";
							CGridButton@ back_leg = menu.AddButton("Surgery_Back_Leg.png", limbs.BackLeg, "Back Leg"+status, this.getCommandID("operate"),params); //Back Leg
							params.Clear();
						}
				
					}
				} 
		}
	}
	
	if (cmd == this.getCommandID("operate"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		int limb = params.read_u8();
		if(getNet().isServer()){
			if(caller !is null){
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					CBlob@ patient = attach.getAttachedBlob("BED");
					if(patient !is null && patient.getName() == "humanoid"){
						LimbInfo@ limbs;
						if (!patient.get("limbInfo", @limbs))return;
						CBlob @item = caller.getCarriedBlob();
						if(item !is null){
							if(limb != LimbSlot::Torso){ ///Torso has unique code for core
								f32 hp_multi = 2.0f;
								if(limb == LimbSlot::FrontLeg || limb == LimbSlot::BackLeg)hp_multi = 3.0f;
								if(!canHitLimb(patient,limb)){ //If limb doesn't exist
									int type = getTypeFromBlob(item.getName(),limb);
									print("hp:"+item.getHealth());
									if(type > 0){
										if(item.hasTag("material")){
											if(caller.hasBlob(item.getName(), 50)){
												caller.TakeBlob(item.getName(), 50);
												replaceLimb(patient,limb,type,getLimbMaxHealth(limb,type));
											}
										} else {
											replaceLimb(patient,limb,type,item.getHealth()*hp_multi);
											item.server_Die();
										}
									}
								} else {
									if(item.hasTag("sharp")){
										if(getLimbHealth(limbs,limb) > 0.0f){
											CBlob @limb_item = server_CreateBlob(getLimbBlob(getLimb(limbs,limb),limb), patient.getTeamNum(), caller.getPosition());
											if(limb_item !is null){
												limb_item.server_SetHealth(getLimbHealth(limbs,limb)/hp_multi);
											}
										}
										replaceLimb(patient,limb,BodyType::None,0.0f);
									}
								}
							} else {
								///Core special case
								if(item.hasTag("sharp")){
									if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSpirit){
										CBlob @core = server_CreateBlob("core", patient.getTeamNum(), caller.getPosition());
										if (core !is null)
										{
											if(patient.getPlayer() !is null){
												core.set_string("player_name",patient.getPlayer().getUsername());
												core.Tag("soul_"+patient.getPlayer().getUsername());
											}

											if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
												core.set_u8("infuse",1);
												core.set_u8("level",limbs.Core-CoreType::WoodSoul);
												core.set_u16("equip_id",Equipment::LifeCore);
											} else {
												core.set_u8("infuse",2);
												core.set_u8("level",limbs.Core-CoreType::WoodSpirit);
												core.set_u16("equip_id",Equipment::DeathCore);
											}
											
											
											if(core.get_u8("level") == 1)core.server_SetHealth(item.getInitialHealth()*2.0f);
											if(core.get_u8("level") == 2)core.server_SetHealth(item.getInitialHealth()*3.0f);
										}
									}
									if(limbs.Core == CoreType::Beating || limbs.Core == CoreType::Stopped){
										server_CreateBlob("heart", patient.getTeamNum(), caller.getPosition());
									}
									server_SetCore(patient, CoreType::Missing);
								} else 
								if(limbs.Core == CoreType::Missing){
									if(item.get_u16("equip_id") == Equipment::LifeCore || item.get_u16("equip_id") == Equipment::DeathCore){
										print("inserted core");
										if(patient.getPlayer() is null){
											CPlayer @ghost_player = getPlayerByUsername(item.get_string("player_name"));
											
											if(ghost_player !is null){
												patient.server_setTeamNum(ghost_player.getTeamNum());
												if(ghost_player.getBlob() !is null){
													ghost_player.getBlob().server_Die();
												}
												patient.server_SetPlayer(ghost_player);
											}
										}
										
										if(item.get_u16("equip_id") == Equipment::LifeCore)server_SetCore(patient, CoreType::WoodSoul+item.get_u8("level"));
										if(item.get_u16("equip_id") == Equipment::DeathCore)server_SetCore(patient, CoreType::WoodSpirit+item.get_u8("level"));
										
										item.Tag("used");
										item.server_Die();
									}
									
									if(item.getName() == "heart"){
										print("inserted heart");
										
										server_SetCore(patient, CoreType::Stopped);
										
										item.server_Die();
									}
									
									if(item.getName() == "gem"){
										if(!hasEnchant(patient,Enchantment::Gem)){
											addEnchant(patient,Enchantment::Gem);
											item.server_Die();
										} else
										if(!hasEnchant(patient,Enchantment::StrongGem)){
											addEnchant(patient,Enchantment::StrongGem);
											removeEnchant(patient,Enchantment::Gem);
											item.server_Die();
										} else {
											if(!hasEnchant(patient,Enchantment::UnstableGem)){
												removeEnchant(patient,Enchantment::Gem);
												addEnchant(patient,Enchantment::UnstableGem);
												item.server_Die();
											}
											MagicExplosion(patient.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 2.0f);
										}
										
										
										patient.Sync("enchants",true);
									}
									
									if(item.getName() == "weak_gem"){
										if(!hasEnchant(patient,Enchantment::WeakGem)){
											addEnchant(patient,Enchantment::WeakGem);
											item.server_Die();
										} else
										if(!hasEnchant(patient,Enchantment::Gem)){
											addEnchant(patient,Enchantment::Gem);
											removeEnchant(patient,Enchantment::WeakGem);
											item.server_Die();
										}
										/*else
										if(!hasEnchant(patient,Enchantment::StrongGem)){
											addEnchant(patient,Enchantment::StrongGem);
											removeEnchant(patient,Enchantment::Gem);
											removeEnchant(patient,Enchantment::WeakGem);
											item.server_Die();
										} else {
											if(!hasEnchant(patient,Enchantment::UnstableGem)){
												removeEnchant(patient,Enchantment::Gem);
												removeEnchant(patient,Enchantment::WeakGem);
												addEnchant(patient,Enchantment::UnstableGem);
												item.server_Die();
											}
											MagicExplosion(patient.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 2.0f);
										}*/
										
										
										patient.Sync("enchants",true);
									}
									
									if(item.getName() == "strong_gem"){
										if(!hasEnchant(patient,Enchantment::StrongGem)){
											addEnchant(patient,Enchantment::StrongGem);
											item.server_Die();
										} else {
											if(!hasEnchant(patient,Enchantment::UnstableGem)){
												removeEnchant(patient,Enchantment::StrongGem);
												addEnchant(patient,Enchantment::UnstableGem);
											}
											MagicExplosion(patient.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 2.0f);
										}
										patient.Sync("enchants",true);
									}
									
									if(item.getName() == "unstable_gem"){
										
										if(!hasEnchant(patient,Enchantment::UnstableGem)){
											addEnchant(patient,Enchantment::UnstableGem);
											MagicExplosion(patient.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 2.0f);
											patient.Sync("enchants",true);
											item.server_Die();
										} else {
											MagicExplosion(patient.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 3.0f);
										}
										
										
									}
								}
							}
						}
					}
				}
			}
		}
	}
}