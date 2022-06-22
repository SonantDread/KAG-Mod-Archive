
#include "ClanCommon.as";

void onInit(CBlob @this){
	client_AddToChat("The clan '"+this.get_string("name")+"' has been created!", SColor(255,96,64,200));
	this.Tag("force_update_listing");
	this.addCommandID("clan_sync");
	this.addCommandID("elect_new_leader");
	this.addCommandID("disband");
	this.set_u32("wealth",0);
}

void onTick(CBlob @this){
	if(isServer()){
		u32 g = ((getGameTime()+this.getNetworkID()) % 343);
		if(g == 0 || this.hasTag("force_update_listing")){
			this.Untag("force_update_listing");
			
			CBitStream params;
			string[]@ Members;
			this.get("members",@Members);
			params.write_u8(Members.length);
			for(int i = 0;i < Members.length;i++){
				params.write_string(Members[i]);
			}
			this.SendCommand(this.getCommandID("clan_sync"), params);
		}
		if(g == 2){
			bool found = false;
			
			string[]@ Members;
			this.get("members",@Members);
			
			if(Members.length > 0){
				for(int i = 0;i < Members.length;i++){
					if(this.get_string("leader") == Members[i]){
						found = true;
					}
				}
				
				if(!found){
					this.SendCommand(this.getCommandID("elect_new_leader"));
				}
			} else { //Everyone left the clan, time to disband.
				this.SendCommand(this.getCommandID("disband"));
			}
		}
		if(g == 4)this.Sync("Level",true);
		if(g == 6){
			int gold = 0;
			CBlob@[] chests;
			getBlobsByName("wooden_chest", @chests);
			int cid = this.get_u16("ClanID");
			for(uint i = 0; i < chests.length; i++){
				CBlob@ chest = chests[i];
				if(chest !is null && getBlobClan(chest) == cid){
					gold += chest.getBlobCount("gold_drop_small");
					gold += chest.getBlobCount("gold_drop")*2;
					gold += chest.getBlobCount("gold_bar")*2;
					gold += chest.getBlobCount("weak_gem")*20;
					gold += chest.getBlobCount("gem")*40;
					gold += chest.getBlobCount("strong_gem")*80;
					gold += chest.getBlobCount("unstable_gem")*80;
				}
			}
			this.set_u32("wealth",gold);
			this.Sync("wealth",true);
		}
		if(g == 8)this.Sync("Bloodlust",true);
		if(g == 10){
			int industry = 0;
			int slag = 0;
			CBlob@[] chests;
			getBlobsByName("wooden_chest", @chests);
			int cid = this.get_u16("ClanID");
			for(uint i = 0; i < chests.length; i++){
				CBlob@ chest = chests[i];
				if(chest !is null && getBlobClan(chest) == cid){
					industry += chest.getBlobCount("metal_drop_small");
					industry += chest.getBlobCount("metal_drop")*2;
					industry += chest.getBlobCount("metal_drop_large")*4;
					industry += chest.getBlobCount("metal_bar")*2;
					industry += chest.getBlobCount("metal_bar_large")*4;
					industry += chest.getBlobCount("metal_pick")*4;
					industry += chest.getBlobCount("metal_axe")*4;
					industry += chest.getBlobCount("gold_pick")*2;
					industry += chest.getBlobCount("gold_axe")*2;
					slag += chest.getBlobCount("metal_drop_dirty");
				}
			}
			if(industry > slag)industry -= slag;
			else industry = 0;
			this.set_u32("industry",industry);
			this.Sync("industry",true);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("clan_sync"))
	{
		u8 ms = params.read_u8();
		
		string[] Members;
		for(int j = 0;j < ms;j++){
			Members.push_back(params.read_string());
		}
		this.set("members",Members);
	}
	
	if (cmd == this.getCommandID("elect_new_leader"))
	{
		string[]@ Members;
		this.get("members",@Members);
			
		if(Members.length > 0){
			this.set_string("leader",Members[0]);
			client_AddToChat(Members[0]+" has become the new leader of "+this.get_string("name")+"!", SColor(255,96,64,200));
		}
	}
	
	if (cmd == this.getCommandID("disband"))
	{
		string[]@ Members;
		this.get("members",@Members);
			
		if(Members.length <= 0){
			client_AddToChat(this.get_string("name")+" has disbanded!", SColor(255,200,64,96));
			if(isServer())this.server_Die();
		}
	}
	
}