
void onInit(CRules@ this)
{
	this.set_string("spawn_blob","humanoid");
}

void onTick(CRules @this){
	if(getNet().isServer()){
		if(getGameTime() % 60 == 45 && XORRandom(3) == 0){
			CBlob@[] trees;
			CBlob@[] wisps;
					
			getBlobsByName("tree_pine", trees);
			getBlobsByName("tree_bushy", trees);
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

f32 calculatePowerLevel(CBlob@ this){
	f32 power = 1;
	
	if(this.exists("PowerLevel"))power = this.get_f32("PowerLevel");
	
	if(power <= 0.1f)power = 0.1f;
	
	return power;
}


/*
f32 onPlayerTakeDamage( CRules@ this, CPlayer@ victim , CPlayer@ attacker, f32 DamageScale){
	
	if(attacker is null || victim is attacker)return DamageScale;
	
	CBlob @v = victim.getBlob();
	CBlob @a = attacker.getBlob();
	
	print("DS"+DamageScale);
	
	if(v !is null && a !is null){
	
		f32 vpower = calculatePowerLevel(v);
		f32 apower = calculatePowerLevel(a);
		
		DamageScale = (DamageScale/vpower)*apower;
		
		print("hit with power:"+apower+", defending with:"+vpower+", result:"+DamageScale);
	
	} else 
	if(v !is null){
		DamageScale = DamageScale/calculatePowerLevel(v);
	}
	
	return DamageScale;
}*/