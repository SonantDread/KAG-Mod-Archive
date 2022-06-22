

void MagicExplosion(Vec2f pos, string filename, float damage){

	//ParticleAnimated(filename, pos, Vec2f(0,0), XORRandom(360), 1.0f, 2, 0, true);
	if(isServer()){
		CBlob @ME = server_CreateBlobNoInit("magic_explosion");
		
		ME.set_string("filename",filename);
		ME.setPosition(pos);
		ME.set_f32("damage",damage);
		
		ME.Init();
	}

}