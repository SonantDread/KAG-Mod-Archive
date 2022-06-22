
f32 getHealthMax(CBlob@ this)
{
	f32 Max = this.getInitialHealth()*2.0f;
	
	if(this.getTeamNum() <= 7)Max += 2.0f;
	
	int type = 0;
	while(true){
		if(this.exists("hp_extra_"+type)){
			Max += this.get_f32("hp_extra_"+type);
		} else {
			break;
		}
		type += 1;
	}
	
	return Max;
}

string getHealthContainer(CBlob@ this, int Num)
{
	f32 Max = this.getInitialHealth()*2.0f;
	
	if(Num <= Max)return this.get_string("default_hp_sprite");
	
	if(this.getTeamNum() <= 7)Max += 2.0f;
	
	if(Num <= Max)return "FlagHeartHUD.png";
	
	int type = 0;
	while(true){
		if(this.exists("hp_sprite_"+type)){
			Max += this.get_f32("hp_extra_"+type);
			if(Num <= Max)return this.get_string("hp_sprite_"+type);
		} else {
			break;
		}
		type += 1;
	}
	
	return this.get_string("default_hp_sprite");
}

void AddMaxHealth(CBlob@ this, string sprite, f32 amount){
	f32 HealthRatio = getHealth(this)/getHealthMax(this);
	
	int type = 0;
	while(true){
		if(this.exists("hp_sprite_"+type)){
			if(sprite == this.get_string("hp_sprite_"+type)){
				this.set_f32("hp_extra_"+type,amount);
				//print("already has health type, just adjusting");
				break;
			}
		} else {
			this.set_string("hp_sprite_"+type,sprite);
			this.set_f32("hp_extra_"+type,amount);
			//print("doesn't have health type, adding");
			break;
		}
		type += 1;
	}

	if(isServer())this.server_SetHealth(HealthRatio*getHealthMax(this)*0.5);
}

f32 getHealth(CBlob@ this)
{
	f32 Health = this.getHealth()*2.0f;
	
	return Health;
}

f32 server_Heal(CBlob@ this, f32 Amount){
	
	if(isServer()){
	
		f32 max = Maths::Max(getHealth(this),getHealthMax(this));
	
		this.server_SetHealth((Maths::Min(getHealth(this)+Amount,max))/2.0f);
		
		return Maths::Min(Amount,max-getHealth(this));
		
	}
	
	return Amount;

}

void server_OverHeal(CBlob@ this, f32 Amount, f32 MaxOverHeal){
	
	if(isServer()){

		f32 max = Maths::Max(getHealth(this),getHealthMax(this)+MaxOverHeal);
	
		this.server_SetHealth((Maths::Min(getHealth(this)+Amount,max))/2.0f);

	}
}