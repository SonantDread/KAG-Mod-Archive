#include "Health.as";

void ShardSelf(CBlob @this){
	if(this.hasTag("switch class"))return;
	if(this.getPlayer() is null)return;
	if(!this.hasTag("free"))return;

	if(!getNet().isServer())return;
	
	CBlob @newBlob = server_CreateBlob("ghost_shard", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		this.Untag("free");
		this.set_u16("soul_link",newBlob.getNetworkID());
		newBlob.Tag("soul_"+this.getPlayer().getUsername());
		newBlob.set_string("player_name",this.getPlayer().getUsername());
		this.Sync("soul_link",true);
		this.server_SetTimeToDie(0);
	}
}

void ImbueCorpse(CBlob @this){
	CBlob @held = this.getCarriedBlob();
	if(held !is null)
	if(held.getName() == "humanoid"){
		
		held.Tag("animated");
		if(held.getPlayer() is null){
			held.getBrain().server_SetActive(true);
		}
		if(isServer()){
			held.Sync("animated",true);
			held.server_setTeamNum(this.getTeamNum());
			held.server_SetHealth(0.0f);
			server_Heal(held,10.0f);
		}
	
	}
}

void GuardianSwitch(CBlob @this){
	CBlob @link = getBlobByNetworkID(this.get_u16("soul_link"));
	if(link !is null){
		link.setPosition(this.getPosition());
	}
}