
CBlob@ getPlayerRoundData(CPlayer@p){
	CBlob @data = null;
	
	if(p is null || !isServer())return data;
	
	string name = p.getUsername();
	CBlob@[] datas;
	getBlobsByTag(name+"_round", @datas);

	if(datas.length > 0){
		@data = datas[0];
	} else {
		@data = server_CreateBlob("player_data",-1,Vec2f(0,0));
		data.Tag(name+"_round");
		print("Player round data not found for "+name+", making new one.");
	}
	
	return data;
}

CBlob@ getPlayerLifeData(CPlayer@p){
	CBlob @data = null;
	
	if(p is null || !isServer())return data;
	
	string name = p.getUsername();
	CBlob@[] datas;
	getBlobsByTag(name+"_life", @datas);

	if(datas.length > 0){
		@data = datas[0];
	} else {
		@data = server_CreateBlob("player_data",-1,Vec2f(0,0));
		data.Tag(name+"_life");
		print("Player life data not found for "+name+", making new one.");
	}
	
	return data;
}

void deletePlayerLifeData(CPlayer@p){
	CBlob @data = null;
	
	if(p is null || !isServer())return;
	
	string name = p.getUsername();
	CBlob@[] datas;
	getBlobsByTag(name+"_life", @datas);

	if(datas.length > 0){
		datas[0].server_Die();
	}
}