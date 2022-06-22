
bool hasTek(CBlob @this, int team, string tek){
	
	if(this !is null && this.hasBlob(tek,1))return true;
	
	if(team > 50)return false;
	
	bool has = false;
	CBlob@[] shelves;
	getBlobsByTag("bookshelf", @shelves);
	for(int i = 0;i < shelves.length;i++){
		if(shelves[i].getTeamNum() == team){
			if(shelves[i].hasBlob(tek,1))has = true;
		}
	}
	
	return has;
}