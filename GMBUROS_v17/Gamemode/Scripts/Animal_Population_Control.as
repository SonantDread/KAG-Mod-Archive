
void onTick(CRules @this){
	if(getNet().isServer()){
		if(getGameTime() % 60 == 0){
			CBlob@[] chickens;
			CBlob@[] eggs;
			CBlob@[] bushes;
					
			getBlobsByName("chicken", chickens);
			getBlobsByName("egg", eggs);
			getBlobsByName("bush", bushes);
			
			if(chickens.length < 10 && eggs.length < 20){
				if(bushes.length > 0){
					int ran = XORRandom(bushes.length);
					server_CreateBlob("egg",-1,bushes[ran].getPosition());
				} else {
					server_CreateBlob("chicken",-1,Vec2f(XORRandom(getMap().tilemapwidth*8),0));
				}
			}
		}
		if(getGameTime() % 60 == 30 && XORRandom(5) == 0){
			CBlob@[] trees;
			CBlob@[] bison;
					
			getBlobsByName("tree_pine", trees);
			getBlobsByName("tree_bushy", trees);
			getBlobsByName("bison", bison);
			if(bison.length < 1){
				if(trees.length > 0){
					int ran = XORRandom(trees.length);
					server_CreateBlob("bison",-1,trees[ran].getPosition());
				}
			}
		}
	}
}