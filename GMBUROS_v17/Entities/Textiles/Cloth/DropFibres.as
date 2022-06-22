
#define SERVER_ONLY;

void onDie(CBlob@ this){
	server_CreateBlob("fibre",-1,this.getPosition());
	server_CreateBlob("fibre",-1,this.getPosition());
}