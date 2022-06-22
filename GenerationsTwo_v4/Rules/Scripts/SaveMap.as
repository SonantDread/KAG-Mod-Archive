
void SaveSpecialBlobs(string file_name){

	CBlob@[] blobs;
	getBlobs(@blobs);
	
	for(int i = 0;i < blobs.length;i++){
		CBlob @blob = blobs[i];
		Vec2f pos = blob.getPosition();
		
	}

}