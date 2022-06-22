void onTick(CRules@ this)
{
	if(getGameTime() % 5 == 0){
		CBlob@[] blobs;
		getBlobsByTag("smoke", @blobs);
		//getBlobsByName("stickfire", @blobs);
		
		CMap @ map = getMap();
		
		for (int j = 0; j < blobs.length; j++){
			CBlob @smoke = blobs[j];
			if(smoke !is null && smoke.getName() == "smoke"){
			
				if(smoke.getPosition().y < 0){
					if(isServer())smoke.server_Die();
					continue;
				}
				if(XORRandom(3) == 0)smoke.AddForce(Vec2f(0,XORRandom(20)-10));

				for (int i = 0; i < blobs.length; i++)
				if(blobs[i] !is smoke){
					Vec2f ang = blobs[i].getPosition() - smoke.getPosition();
					f32 dis = ang.Length();
					if(dis < 12.0f){
						dis = 1.0f-(dis/12.0f);
						ang.Normalize();
						smoke.AddForce(-ang*dis*100.0f);
					}
				}
				
				if(!map.rayCastSolid(smoke.getPosition(), Vec2f(smoke.getPosition().x,0)))smoke.getShape().SetGravityScale(-0.1f);
				else {
					smoke.getShape().SetGravityScale(0.00f);
					if(XORRandom(3) == 0)smoke.AddForce(Vec2f(XORRandom(20)-10,0));
				}
			}
		}
	}
}