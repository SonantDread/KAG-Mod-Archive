#include "EquipmentCommon.as";

void createGhost(CBlob@ this){

	if(!getNet().isServer())return;

	if(this.getPlayer() is null)return;
	
	Vec2f pos = this.getPosition();
	
	if(getMap().tilemapheight*8-16 > pos.y)pos.y = getMap().tilemapheight*8-16;
	
	CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		LimbInfo@ limbs;
		if(newBlob.get("limbInfo", @limbs)){
		
			if(this.hasTag("cannibal") && limbs.Torso == BodyType::Cannibal){
				newBlob.Untag("free");
				newBlob.set_u16("soul_link",this.getNetworkID());
				this.Tag("soul_"+this.getPlayer().getUsername());
				this.set_string("player_name",this.getPlayer().getUsername());
			} else {
				int time = 20;
				newBlob.server_SetTimeToDie(time);
			}
		
		}
		
		// plug the soul
		//newBlob.server_SetPlayer(this.getPlayer());
		newBlob.set_string("force_player",this.getPlayer().getUsername());
	}
}