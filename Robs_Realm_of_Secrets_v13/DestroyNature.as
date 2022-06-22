void DestroyNature()
{
	if(getNet().isClient())
	{
		string world_sprite = "world_ded.png";
		getMap().CreateTileMap(0, 0, 8.0f, world_sprite);

		getMap().CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "cloud", 0);
		getMap().CreateSkyGradient("skygradient_ded.png");

		getMap().AddBackground("BackgroundPlains_ded.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		getMap().AddBackground("BackgroundTrees_ded.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		getMap().AddBackground("BackgroundCastle_ded.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);
		
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