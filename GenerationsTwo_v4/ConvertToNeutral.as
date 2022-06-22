
#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	if(this.getTeamNum() > 10){
		this.server_setTeamNum(-1);
	}
}