
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "Health.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_string("class","builder");

	//Hands
	this.set_u16("marm_equip",Equipment::Hammer);
	this.set_u16("marm_equip_type",0);
	this.set_u16("sarm_equip",Equipment::Pick);
	this.set_u16("sarm_equip_type",0);
	
	this.set_u16("marm_default",Equipment::Hammer);
	this.set_u16("marm_default_type",0);
	this.set_u16("sarm_default",Equipment::Pick);
	this.set_u16("sarm_default_type",0);
	
	//Armour
	AddMaxHealth(this,"ShieldHeartHUD.png",0.0f);
	this.set_f32("armour_health",0.0f);
	this.set_u16("tors_equip",Equipment::Shirt);
	this.set_u16("tors_equip_type",0);
	this.set_u16("tors_default",Equipment::None);
	this.set_u16("tors_default_type",0);
	//this.Tag("pregnant");
	
	//Commands
	this.addCommandID("equip_head");
	this.addCommandID("equip_tors");
	this.addCommandID("equip_legs");
	this.addCommandID("equip_marm");
	this.addCommandID("equip_sarm");
	this.addCommandID("equip_back");
	this.addCommandID("equip_belt");
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())return;
	
	if(getGameTime() % 60 == 0){
		CPlayer@ p = this.getPlayer();
		if(p !is null) //Golden tool upgrade script, so f2p players know who's boss
		{
			if (p.getArmourSet() == PLAYER_ARMOUR_GOLD){
				if(this.get_u16("marm_equip_type") == 0)if(this.get_u16("marm_equip") == Equipment::Pick)this.set_u16("marm_equip_type",1);
				if(this.get_u16("sarm_equip_type") == 0)if(this.get_u16("sarm_equip") == Equipment::Pick)this.set_u16("sarm_equip_type",1);
				if(this.get_u16("marm_equip_type") % 2 == 0)if(this.get_u16("marm_equip") == Equipment::Hammer)this.add_u16("marm_equip_type",1);
				if(this.get_u16("sarm_equip_type") % 2 == 0)if(this.get_u16("sarm_equip") == Equipment::Hammer)this.add_u16("sarm_equip_type",1);
				if(this.get_u16("marm_equip_type") == 0)if(this.get_u16("marm_equip") == Equipment::Sword)this.set_u16("marm_equip_type",1);
				if(this.get_u16("sarm_equip_type") == 0)if(this.get_u16("sarm_equip") == Equipment::Sword)this.set_u16("sarm_equip_type",1);
			}
		}
		if(this.get_u16("tors_equip") == Equipment::Shirt)this.set_u16("tors_equip_type",Maths::Min(this.getTeamNum(),7));
	}
	
	if(getGameTime() % 31 == 0){
		int EH = getEquipmentHealth(this, this.get_u16("tors_equip"),this.get_u16("tors_equip_type"));
		if(this.get_f32("armour_health") != EH){
			AddMaxHealth(this,"ShieldHeartHUD.png",EH);
			this.set_f32("armour_health",EH);
		}
	}
	if(isServer())
	if(getGameTime() % 32 == 0){
		if(this.getPlayer() is null && (this.hasTag("animated")||this.hasTag("alive"))){
			if(this.get_u16("tors_equip") == Equipment::LifeCore){
				this.getBrain().server_SetActive(true);
			}
		}
	}
}


void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x) - 156.0f,
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24 - 4);
	
	createEquipMenu(this, forBlob, pos);
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	for(int i = 0;i < EquipSlots.length;i++)
	if (cmd == this.getCommandID("equip_"+EquipSlots[i]))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null){
			CBlob@ carry = caller.getCarriedBlob();
			if(carry !is null && carry.getName() == "lantern" && EquipSlots[i] == "head"){
				changeEye(this,EyeType::Seared);
				if(getLocalPlayerBlob() is this){
					SetScreenFlash(255, 255, 64, 0);
					client_AddToChat("Your eye is plunged into the flame, searing it thoroughly.", SColor(255, 255, 64, 0));
				}
			} else
			if(isServer){
				if(canRemoveEquipment(this.get_u16(EquipSlots[i]+"_equip"))){
					unEquipType(this, caller, EquipSlots[i]);
					if(carry !is null){
						if(carry.getName() == "knife"){
							if(EquipSlots[i] == "sarm" || EquipSlots[i] == "marm" || EquipSlots[i] == "head")replaceLimb(this, EquipSlots[i], BodyType::None);
							if(EquipSlots[i] == "legs"){
								replaceLimb(this, "bleg", BodyType::None);
							}
							if(EquipSlots[i] == "belt"){
								replaceLimb(this, "fleg", BodyType::None);
							}
							if(EquipSlots[i] == "tors"){
								if (this.get_u8("heart") != HeartType::Missing) //double check
								{
									this.set_u8("heart",HeartType::Missing);

									CBlob@ heart = server_CreateBlob("heart", -1, this.getPosition());

									if (heart !is null)
									{
										Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
										heart.setVelocity(vel);
									}
								}
							}
						} else
						if(carry.hasTag("equippable")){
							if(carry.get_string("equip_slot") == EquipSlots[i] || (carry.get_string("equip_slot") == "arm" && (EquipSlots[i] == "sarm" || EquipSlots[i] == "marm"))){
								if(equipType(this, EquipSlots[i], carry.get_u16("equip_id"), carry.get_u16("equip_type"))){
									
									
									///Core special case
									if(carry.get_u16("equip_id") == Equipment::LifeCore || carry.get_u16("equip_id") == Equipment::DeathCore){
										if(this.getPlayer() is null){
											CPlayer @ghost_player = getPlayerByUsername(carry.get_string("player_name"));
											
											if(ghost_player !is null){
												this.server_setTeamNum(ghost_player.getTeamNum());
												if(ghost_player.getTeamNum() >= 50)this.server_setTeamNum(caller.getTeamNum());
												if(ghost_player.getBlob() !is null){
													ghost_player.getBlob().server_Die();
												}
												this.server_SetPlayer(ghost_player);
											} else this.server_setTeamNum(caller.getTeamNum());
										}
										this.Tag("animated");
										this.Sync("animated",true);
										if(getHealth(this) <= 0)this.server_SetHealth(0.25f);
									}
									
									if(carry.hasTag("darkness_sworn")){
										this.Tag("darkness_sworn");
									}
									
									
									carry.server_Die();
								}
							}
						}
					}
				}
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::sword)
	if(hitBlob !is null)
	if((this.get_u16("marm_equip")==Equipment::Sword&&this.get_u16("marm_equip_type")==2) ||
	(this.get_u16("sarm_equip")==Equipment::Sword&&this.get_u16("sarm_equip_type")==2))
	{
		if(hitBlob.get_s16("darkness") < 20)hitBlob.set_s16("darkness",20);
	}
}