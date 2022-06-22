
#include "Hitters.as";

void onInit(CBlob@ this)
{
	if(isClient())ParticleAnimated(this.get_string("filename"), this.getPosition(), Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
	
	if(isServer()){
		
		CBlob@[] blobs;
		getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobs);
		
		for(int i = 0;i < blobs.length;i++){
			CBlob @blob = blobs[i];
			Vec2f pos = blob.getPosition();
			
			if(blob.hasTag("flesh")){
				this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), this.get_f32("damage"), Hitters::burn);
			}
		}
	
		this.server_Die();
	}
}