
#include "TimeCommon.as"

void onInit(CRules@ this)
{
	this.set_string("spawn_blob","humanoid");
}

void onTick(CRules @this){
	if(!isNight())
	if(getNet().isServer()){
		if(getGameTime() % 60 == 45 && XORRandom(3) == 0){
			CBlob@[] trees;
			CBlob@[] wisps;
					
			getBlobsByName("tree_pine", trees);
			getBlobsByName("tree_bushy", trees);
			getBlobsByName("tree_large", trees);
			getBlobsByName("wisp", wisps);
			if(wisps.length < 5){
				if(trees.length > 0){
					int ran = XORRandom(trees.length);
					server_CreateBlob("wisp",-1,trees[ran].getPosition());
				}
			}
		}
	}
}