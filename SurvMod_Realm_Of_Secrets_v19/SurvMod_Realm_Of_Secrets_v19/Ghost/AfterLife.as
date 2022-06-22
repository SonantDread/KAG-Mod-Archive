#include "EquipmentCommon.as";

void createGhost(CBlob@ this){

	if(!getNet().isServer())return;

	if(this.getPlayer() is null)return;
	
	Vec2f pos = this.getPosition();
	
	if(getMap().tilemapheight*8-16 > pos.y)pos.y = getMap().tilemapheight*8-16;
	
	CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		if(this.hasTag("cannibal") && this.get_u8("tors_type") == BodyType::Cannibal){
			newBlob.Untag("free");
			newBlob.set_u16("soul_link",this.getNetworkID());
			this.Tag("soul_"+this.getPlayer().getUsername());
			this.set_string("player_name",this.getPlayer().getUsername());
		} else {
			int time = 20;
			newBlob.server_SetTimeToDie(time);
		}
		
		// plug the soul
		newBlob.server_SetPlayer(this.getPlayer());
		
		this.Tag("switch class");
		this.server_SetPlayer(null);
	}
}