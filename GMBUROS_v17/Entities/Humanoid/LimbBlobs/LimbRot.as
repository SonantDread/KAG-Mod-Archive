
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 300;
	this.set_u32("time_spawned",getGameTime());
}

void onTick(CBlob@ this)
{
	if(isServer())
	if(getGameTime() > this.get_u32("time_spawned")+(30*60*5)){
		if(this.getName() == "flesh_limb"){
			this.server_Die();
			server_CreateBlob("rotten_limb",-1,this.getPosition());
		} else {
			this.server_Die();
		}
	}
}	