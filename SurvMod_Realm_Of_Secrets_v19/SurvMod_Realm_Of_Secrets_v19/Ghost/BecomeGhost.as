#include "EquipmentCommon.as";
#include "AfterLife.as";

void onDie(CBlob@ this){
	
	if(this.hasTag("switch class"))return;
	if(!getNet().isServer())return;
	
	if(this.getName() == "humanoid")
	if(this.get_u16("tors_equip") == Equipment::LifeCore || this.get_u16("tors_equip") == Equipment::DeathCore){
		if(this.get_u16("tors_equip_type") > 0){
			CBlob @newBlob = server_CreateBlob("core", this.getTeamNum(), this.getPosition());
			if (newBlob !is null)
			{
				if(this.getPlayer() !is null){
					newBlob.set_string("player_name",this.getPlayer().getUsername());
					newBlob.Tag("soul_"+this.getPlayer().getUsername());
				}
				
				newBlob.set_u8("level",this.get_u16("tors_equip_type"));
				
				if(this.get_u16("tors_equip") == Equipment::LifeCore)newBlob.set_u8("infuse",1);
				else newBlob.set_u8("infuse",2);
				newBlob.set_u16("equip_id",this.get_u16("tors_equip"));
				newBlob.Tag("equippable");
				
				if(newBlob.get_u8("level") == 1)newBlob.server_SetHealth(newBlob.getInitialHealth()*5.0f);
				if(newBlob.get_u8("level") == 2)newBlob.server_SetHealth(newBlob.getInitialHealth()*25.0f);
			}
		}
		this.set_u16("tors_equip",Equipment::None);
	}

	createGhost(this);
}