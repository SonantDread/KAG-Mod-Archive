
CBlob@ getPlayerRoundData(CPlayer@p){
	CBlob @data = null;
	
	if(p is null)return data;
	
	string name = p.getUsername();
	CBlob@[] datas;
	getBlobsByTag(name+"_data", @datas);

	if(datas.length > 0){
		@data = datas[0];
	} else 
	if(isServer()){
		@data = LoadPlayerData("PlayerData.cfg",name);
		print("Player round data not found for "+name+", making new one.");
	}
	
	return data;
}

u8 getPlayerBlobColour(CBlob @this){
	CBlob @data = getPlayerRoundData(this.getPlayer());
	if(data !is null){
		if(!data.exists("clothing_colour"))return 7;
		return data.get_u8("clothing_colour");
	}
	return 7;
}

void SavePlayerData(string file_name){
	CBlob@[] players;
	getBlobsByName("player_data",@players);
	
	ConfigFile cfg = ConfigFile(file_name);

	for(int i = 0;i < getPlayerCount();i++){
		CPlayer @p = getPlayer(i);
		if(p !is null){
			CBlob @data = getPlayerRoundData(p);
		
			if(data !is null){
				
				
				string name = p.getUsername();
				
				cfg.add_u16(name+"_colour", data.get_u8("clothing_colour"));
				cfg.add_u16(name+"_clan", data.get_u16("ClanID"));
				
			}
		}
	}

	cfg.saveFile(file_name);
	print("Saved player data to Cache/"+file_name);
}

CBlob@ LoadPlayerData(string file_name, string username){
	
	ConfigFile cfg = ConfigFile("../Cache/"+file_name);
	
	CBlob@[] datas;
	getBlobsByTag(username+"_data", @datas);

	CBlob @data = null;

	if(datas.length <= 0){
	
		@data = server_CreateBlob("player_data",-1,Vec2f(0,0));
		
		if(data !is null){
			data.Tag(username+"_data");
			data.Sync(username+"_data",true);
		
			data.set_u8("clothing_colour",cfg.read_u16(username+"_colour",7));
			data.Sync("clothing_colour",true);
			
			data.set_u16("ClanID",cfg.read_u16(username+"_clan",0));
			data.Sync("ClanID",true);
		}
	
	}
	
	return data;
}