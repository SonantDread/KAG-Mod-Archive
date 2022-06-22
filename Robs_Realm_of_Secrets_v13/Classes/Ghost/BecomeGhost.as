#include "ClassChangeDataCopy.as"

void onTick(CBlob@ this){

	if(this.getHealth() < 0.5){
		this.Tag("neardeath");
	} else {
		if(this.hasTag("neardeath")){
			this.set_s16("neardeaths",this.get_s16("neardeaths")+1);
			this.Untag("neardeath");
		}
	}

}



void onDie(CBlob@ this){
	if(!getNet().isServer())return;
	if(this.hasTag("switch class"))return;
	
	CBlob@[] Blobs;	   
	getBlobsByName("naturebeing", @Blobs);
	getBlobsByName("naturesgrave", @Blobs);
	if(Blobs.length <= 0)if(XORRandom(20) == 0){
		CBlob @newBlob = server_CreateBlob("naturebeing", -1, this.getPosition());
		if (newBlob !is null)
		{
			newBlob.server_SetPlayer(this.getPlayer());
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
		CBlob @ghost = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
		if (ghost !is null)ghost.server_SetTimeToDie(10);
		return;
	}
	
	if(this.get_s16("neardeaths") >= 2){
		string name = "wraithknight";
		if(this.getName() == "archer")name = "wraitharcher";
		if(this.getName() == "builder" && XORRandom(2) == 0)name = "wraitharcher";
		CBlob @newBlob = server_CreateBlob(name, this.getTeamNum(), this.getPosition());
		if (newBlob !is null)
		{
			// plug the soul
			newBlob.server_SetPlayer(this.getPlayer());
			
			CopyData(this,newBlob);
			newBlob.set_s16("death",this.get_s16("death")+newBlob.get_s16("life"));
			newBlob.set_s16("life",0);
			
			int time = this.get_s16("kills")*5+10;
			if(time > 300 || this.hasTag("evil"))time = 300;
			
			this.Tag("switch class");
			this.server_SetPlayer(null);
		}
		return;
	}
	
	CBlob @newBlob = server_CreateBlob("ghost", this.getTeamNum(), this.getPosition());
	if (newBlob !is null)
	{
		if(this.getPlayer() !is null)this.set_string("username",this.getPlayer().getUsername());
		// plug the soul
		newBlob.server_SetPlayer(this.getPlayer());
		
		CopyData(this,newBlob);
		newBlob.set_s16("death",this.get_s16("death")+newBlob.get_s16("life"));
		newBlob.set_s16("life",0);
		
		if(this.hasTag("goldenstatue"))newBlob.Tag("goldenstatue");
		
		int time = this.get_s16("kills")*5+10;
		if(time > 300 || this.hasTag("evil"))time = 300;
		
		newBlob.server_SetTimeToDie(time);
		
		this.Tag("switch class");
		this.server_SetPlayer(null);
	}
	return;
}