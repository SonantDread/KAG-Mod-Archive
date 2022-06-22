

void onTick(CBlob@ this){
	if((getGameTime()+this.getNetworkID()) % 150 == 0){
	
		CBlob@[] blobs;
		CMap @map = getMap();
		map.getBlobsAtPosition(this.getPosition()+Vec2f(12,0), @blobs);
		map.getBlobsAtPosition(this.getPosition()-Vec2f(12,0), @blobs);

		bool found = false;

		if(blobs !is null)
		for(int i = 0;i < blobs.length;i++){
			if(blobs[i] !is null)
			if(blobs[i].hasTag("furniture")){
				found = true;
				break;
			}
		}
		
		if(!found){
			this.server_Hit(this, this.getPosition(), Vec2f(0,0), 50.0f, 0, true);
		}
	
	}
}