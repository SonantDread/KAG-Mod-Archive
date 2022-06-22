
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "Health.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_string("class","builder");
	
	EquipmentInfo equip;
	
	equip.MainHand = Equipment::None;
	equip.MainHandType = 0;
	
	equip.SubHand = Equipment::None;
	equip.SubHandType = 0;
	
	equip.Torso = 0;
	equip.Head = 0;
	equip.Feet = 0;
	equip.Back = 0;
	equip.Waist = 0;
	
	equip.mainSwingTimer = 0;
	equip.subSwingTimer = 0;
	
	this.set("equipInfo", @equip);
	
	//this.Tag("pregnant");
	
	//Commands
	this.addCommandID("equip");
	this.addCommandID("equip_sync");
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())return;
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;

	///////// Stunned yo
	
	if(this.get_u8("knocked") > 0){
		equip.mainSwingTimer = 0;
		equip.subSwingTimer = 0;
	}
	
	if(isServer()){
		int tep = ((getGameTime()+this.getNetworkID()) % 300);
		
		if(tep == 0)server_SyncEquipped(this, EquipSlot::Main);
		if(tep == 2)server_SyncEquipped(this, EquipSlot::Sub);
		if(tep == 4)server_SyncEquipped(this, EquipSlot::Torso);
		if(tep == 6)server_SyncEquipped(this, EquipSlot::Head);
		if(tep == 8)server_SyncEquipped(this, EquipSlot::Feet);
		if(tep == 10)server_SyncEquipped(this, EquipSlot::Back);
		if(tep == 12)server_SyncEquipped(this, EquipSlot::Waist);
	}
}


void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),// - 156.0f,
	          gridmenu.getUpperLeftPosition().y - 32 * 1 - 3 * 24 - 4);
	
	createEquipMenu(this, forBlob, pos);
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("equip"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		u8 Slot = params.read_u8();

		u8 Equip = Equipment::None;
		u8 EquipType = 0;
		
		EquipmentInfo@ equip;
		if (!this.get("equipInfo", @equip))return;
		
		Equip = checkEquipped(equip,Slot);
		EquipType = checkEquippedType(equip,Slot);
		
		if (caller !is null){
			CBlob@ carry = caller.getCarriedBlob();
			if(carry !is null && carry.getName() == "lantern" && Slot == EquipSlot::Head){
				changeEye(this,EyeType::Seared);
				if(getLocalPlayerBlob() is this){
					SetScreenFlash(255, 255, 64, 0);
					client_AddToChat("Your eye is plunged into the flame, searing it thoroughly.", SColor(255, 255, 64, 0));
				}
			} else
			if(isServer){
				if(Slot == EquipSlot::Waist){
					
					AttachmentPoint@ waistslot = this.getAttachments().getAttachmentPointByName("WAIST");
					if(waistslot !is null){
						CBlob @occu = waistslot.getOccupied();
						if(occu !is null){
							if(carry !is null){
								if(carry.hasTag("equippable"))
								if(carry.get_u8("equip_slot") == Slot){
									this.server_DetachFrom(occu);
									this.DropCarried();
									this.server_AttachTo(carry, "WAIST");
									this.server_Pickup(occu);
								}
							} else {
								this.server_DetachFrom(occu);
								this.server_Pickup(occu);
							}
						} else {
							if(carry !is null){
								if(carry.hasTag("equippable"))
								if(carry.get_u8("equip_slot") == Slot){
									this.DropCarried();
									this.server_AttachTo(carry, "WAIST");
								}
							}
						}
					}
				} else
				if(Slot == EquipSlot::Back){
					
					AttachmentPoint@ backslot = this.getAttachments().getAttachmentPointByName("BACK");
					if(backslot !is null){
						CBlob @occu = backslot.getOccupied();
						if(occu !is null){
							if(carry !is null){
								if(carry.hasTag("equippable"))
								if(carry.get_u8("equip_slot") == Slot){
									this.server_DetachFrom(occu);
									this.DropCarried();
									this.server_AttachTo(carry, "BACK");
									this.server_Pickup(occu);
								}
							} else {
								this.server_DetachFrom(occu);
								this.server_Pickup(occu);
							}
						} else {
							if(carry !is null){
								if(carry.hasTag("equippable"))
								if(carry.get_u8("equip_slot") == Slot){
									this.DropCarried();
									this.server_AttachTo(carry, "BACK");
								}
							}
						}
					}
				} else
				if(canRemoveEquipment(Equip)){
					unequipType(this, caller, Slot, true);
					if(carry !is null){
						if(carry.hasTag("equippable")){
							if(carry.get_u8("equip_slot") == Slot || (carry.get_u8("equip_slot") <= EquipSlot::Sub && Slot <= EquipSlot::Sub)){
								if(equipType(this, Slot, carry.get_u16("equip_id"), carry.get_u16("equip_type"))){
									
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
	
	if (cmd == this.getCommandID("equip_sync"))
	{
		u8 Slot = params.read_u8();
		u8 Equip = params.read_u8();
		u8 EquipType = params.read_u8();
		
		EquipmentInfo@ equip;
		if (!this.get("equipInfo", @equip))return;
		
		setEquipped(equip,Slot,Equip,EquipType);
		
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

void onDie(CBlob@ this){
	if(isServer())
	if(!this.hasTag("dropped_equipped")){
		EquipmentInfo@ equip;
		if (!this.get("equipInfo", @equip))return;
		for(int i = 0;i < EquipSlot::length;i++){
			if(getEquipmentBlob(checkEquipped(equip,i),checkEquippedType(equip,i)) != ""){
				server_CreateBlob(getEquipmentBlob(checkEquipped(equip,i),checkEquippedType(equip,i)),-1,this.getPosition());
			}
		}
		this.Tag("dropped_equipped");
	}
}