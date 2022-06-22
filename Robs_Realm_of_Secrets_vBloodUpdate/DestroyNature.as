void DestroyNature()
{
	if(getNet().isClient())
	{
		Sound::Play("mysterious_perc_05.ogg");
		Sound::Play("ambient_cavern.ogg");
		
		SetScreenFlash(255, 255, 255, 255);
		ShakeScreen(15, 200, Vec2f(0, 0));
	}
	
	if(getNet().isServer()){
		CBlob@[] Blobs;	   
		getBlobsByName("tree_bushy", @Blobs);
		getBlobsByName("tree_pine", @Blobs);
		getBlobsByName("bush", @Blobs);
		getBlobsByName("flowers", @Blobs);
		getBlobsByName("grain_plant", @Blobs);
		
		for (uint i = 0; i < Blobs.length; i++)
		{
			CBlob@ b = Blobs[i];
			if(b.getName() == "tree_bushy" || b.getName() == "tree_pine" || b.getName() == "bush" || b.getName() == "grain_plant")
			{
				server_CreateBlob("thorns", -1, b.getPosition());
			}
			
			b.server_Die();
		}
	}
}