

int getNextClanID(){
	CBlob@[] clans;
	getBlobsByName("clan", clans);
	int ID = 1;
	for (uint i = 0; i < clans.length; i++){
		CBlob@ b = clans[i];
		if(b !is null){
			if(b.get_u16("ClanID") >= ID){
				ID = b.get_u16("ClanID")+1;
			}
		}
	}
	return ID;
}

string getClanName(int ID){
	CBlob@ clan = getClan(ID);
	if(clan !is null)return clan.get_string("name");
	return "Nameless";
}

string getClanLeader(int ID){
	CBlob@ clan = getClan(ID);
	if(clan !is null)return clan.get_string("leader");
	return "";
}

int getClanLevel(int ID){
	CBlob@ clan = getClan(ID);
	if(clan !is null)return clan.get_u8("Level");
	return 1;
}

int getClanMaxMembers(int ID){
	CBlob@ clan = getClan(ID);
	if(clan !is null)return clan.get_u8("Level")*2+1;
	return 3;
}


string[]@ getClanMembers(int ID){
	CBlob@ clan = getClan(ID);
	string[]@ members;
	if(clan !is null)clan.get("members",@members);
	return @members;
}

void addClanMember(int ID, string username){
	CBlob@ clan = getClan(ID);
	string[]@ members;
	if(clan !is null){
		if(clan.get("members",@members)){
			bool found = false;
			bool full = false;
			for(int i = 0;i < members.length;i++){
				if(members[i] == username)found = true;
			}
			if(getClanMaxMembers(ID) <= members.length)full = true;
			if(full){
				if(getPlayerByUsername(username) is getLocalPlayer())client_AddToChat("Can't join "+clan.get_string("name")+", they have too many members!", SColor(255,200,64,96));
			}else
			if(!found){
				members.push_back(username);
				clan.set("members",@members);
				client_AddToChat(username+" has joined "+clan.get_string("name")+"!", SColor(255,96,64,200));
			}
		}
	}
}

CBlob@ getClan(int ID){
	CBlob@[] clans;
	getBlobsByName("clan", clans);
	for(int i = 0;i < clans.length;i++)
	if(clans[i] !is null){
		if(clans[i].get_u16("ClanID") == ID)return clans[i];
	}
	return null;
}

u16 getBlobClan(CBlob @this){
	if(this.getPlayer() !is null){
		CBlob@[] clans;
		getBlobsByName("clan", clans);
		string username = this.getPlayer().getUsername();
		for(int i = 0;i < clans.length;i++){
			CBlob @clan = clans[i];
			
			if(clan !is null){
				string[]@ members;
				if(clan.get("members",@members)){
					for(int j = 0;j < members.length;j++){
						if(username == members[j])return clan.get_u16("ClanID");
					}
				}
			}
		}
	}
	return this.get_u16("ClanID");
}

u16 getPlayerClan(CPlayer @this){
	if(this !is null){
		CBlob@[] clans;
		getBlobsByName("clan", clans);
		string username = this.getUsername();
		for(int i = 0;i < clans.length;i++){
			CBlob @clan = clans[i];
			
			if(clan !is null){
				string[]@ members;
				if(clan.get("members",@members)){
					for(int j = 0;j < members.length;j++){
						if(username == members[j])return clan.get_u16("ClanID");
					}
				}
			}
		}
	}
	return 0;
}

void SaveClans(string file_name){
	CBlob@[] clans;
	getBlobsByName("clan", clans);
	
	ConfigFile cfg = ConfigFile(file_name);
	
	int clansSaved = 0;
	
	for(int i = 0;i < clans.length;i++){
		CBlob @clan = clans[i];
		
		if(clan !is null){

			string[]@ members;
			if(clan.get("members",@members)){

				if(members.length >= 3){
					cfg.add_string("clan"+clansSaved+"_name", clan.get_string("name"));
					cfg.add_string("clan"+clansSaved+"_leader", clan.get_string("leader"));
					cfg.add_u16("clan"+clansSaved+"_ID", clan.get_u16("ClanID"));
					cfg.add_u16("clan"+clansSaved+"_level", clan.get_u8("Level"));
					cfg.add_u32("clan"+clansSaved+"_bloodlust", clan.get_u32("Bloodlust"));
				
				
					cfg.add_u16("clan"+clansSaved+"_members", members.length);
					for(int j = 0;j < members.length;j++){
						cfg.add_string("clan"+clansSaved+"_member"+j, members[j]);
					}
					
					clansSaved++;
				}
			}
		}
	}

	cfg.add_u32("clans_saved", clansSaved);
	
	cfg.saveFile(file_name);
	print("Saved clans to Cache/"+file_name);
}

void LoadClans(string file_name){
	
	ConfigFile cfg = ConfigFile("../Cache/"+file_name);
	
	if(cfg.exists("clans_saved")){
		int clansSaved = cfg.read_u32("clans_saved");
		
		for(int i = 0;i < clansSaved;i++){
			CBlob @clan = server_CreateBlobNoInit("clan");
			if(clan !is null){
				clan.set_string("name",cfg.read_string("clan"+i+"_name"));
				clan.set_string("leader",cfg.read_string("clan"+i+"_leader",""));
				clan.set_u16("ClanID",cfg.read_u16("clan"+i+"_ID"));
				clan.set_u8("Level",cfg.read_u16("clan"+i+"_level",1));
				clan.set_u32("Bloodlust",cfg.read_u32("clan"+i+"_bloodlust",0));
				
				string[] members;
				
				if(cfg.exists("clan"+i+"_members")){
					
					int ms = cfg.read_u16("clan"+i+"_members",0);
					for(int j = 0;j < ms;j++){
						members.push_back(cfg.read_string("clan"+i+"_member"+j));
					}
				}
				
				clan.set("members",members);
				
				clan.Init();
			}
		}
	} else {
		print("Invalid or non-existant saved clans file.");
	}
}