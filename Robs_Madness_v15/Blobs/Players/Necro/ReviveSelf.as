
void onInit(CBlob@ this)
{
	if(this.getPlayer() !is null){
		this.set_string("username",this.getPlayer().getUsername());
	}
	
	this.set_u16("self_raise",0);
}

void onTick(CBlob@ this)
{

	if(this.getPlayer() !is null){
		this.set_string("username",this.getPlayer().getUsername());
	}

	if(this.hasTag("dead")){
		if(this.get_u16("self_raise") > 5*30){
				if(getPlayerByUsername(this.get_string("username")) !is null)
				if(getPlayerByUsername(this.get_string("username")).getBlob() is null){
					if(getNet().isServer()){
						CBlob @ necro = server_CreateBlob(this.getName(),this.getTeamNum(),this.getPosition());
						necro.server_SetPlayer(getPlayerByUsername(this.get_string("username")));
						necro.Tag("undead");
						necro.Tag("no_breathe");
						this.server_Die();
					}
				}
		} else this.set_u16("self_raise",this.get_u16("self_raise")+1);
	}
	

}