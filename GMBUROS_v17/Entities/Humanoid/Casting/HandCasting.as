

void Cast(CBlob @this, int type, keys key){

	switch(type){
	
	
		case 1:{
			if(this.isKeyPressed(key)){
				FlameWave(this);
			}
		break;}
		
		case 2:{
			if(this.isKeyPressed(key)){
				DarkSphere(this);
			}
		break;}
		
		case 3:{
			if(this.isKeyJustPressed(key)){
				ShadowTendril(this);
			}
		break;}
	
	
	}

}

void FlameWave(CBlob @this){

	if(this.get_s8("temperature") > 0){

		int neg = 1;
		if(this.isFacingLeft())neg = -1;
		
		Vec2f arrowVel = (this.getAimPos()+Vec2f(float(XORRandom(65)-32),float(XORRandom(65)-32)))-(this.getPosition());
		arrowVel.Normalize();
		
		if(getNet().isServer()){
			CBlob @fire = server_CreateBlob("firebolt",this.getTeamNum(),this.getPosition()+arrowVel*8.0f);
			fire.setVelocity(arrowVel*5.0f);
			fire.SetDamageOwnerPlayer(this.getPlayer());
		}
	
		this.sub_s8("temperature",1);
	}

}

void DarkSphere(CBlob @this){

	if(isServer() && (getGameTime() % 5) == 0 && this.get_s16("darkness") >= 5){
		Vec2f vec = this.getAimPos()-this.getPosition();
		vec.Normalize();
		this.sub_s16("darkness",5);
		Vec2f start = Vec2f(8.0f,0);
		start.RotateByDegrees(-vec.AngleDegrees());
		CBlob @eco = server_CreateBlob("eco",this.getTeamNum(),this.getPosition()+start);
		if(eco !is null){
			eco.setVelocity(vec*4.0f);
		}
	}

}

void ShadowTendril(CBlob @this){

	if(this.get_s16("darkness") >= 50){
		Vec2f vec = this.getAimPos()-this.getPosition();
		vec.Normalize();
		CBlob @child = server_CreateBlob("dark_explosion",this.getTeamNum(),this.getPosition());
		if(child !is null){
			child.set_u8("amount",6);
			child.set_s16("direction",-vec.AngleDegrees());
		}
		this.sub_s16("darkness",50);
	}

}