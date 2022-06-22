void onInit(CBlob@ this)
{
	this.addCommandID("equip");
	this.addCommandID("combine");
	this.Tag("staff");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("equip"), "Equip staff", params);
	} else 
	if(caller.getCarriedBlob() !is null)
	if(caller.getCarriedBlob().hasTag("staff")){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(16, Vec2f(0,0), this, this.getCommandID("combine"), "Combine staffs", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	CBlob@ caller = getBlobByNetworkID(params.read_u16());
	if(caller !is null)
	{
		if (cmd == this.getCommandID("equip"))
		{
			caller.DropCarried();
			caller.server_AttachTo(this, "STAFF");
		}
		if (cmd == this.getCommandID("combine"))
		if(caller.getCarriedBlob() !is null){
			if(CombineStaffs(this, this.getName(),caller.getCarriedBlob().getName())){
				caller.getCarriedBlob().server_Die();
				this.server_Die();
			}
		}
	}
}

bool CombineStaffs(CBlob@ this, string name, string name2){
	if(getNet().isServer()){
		if(name+":"+name2 == "fire_staff:life_staff" || name2+":"+name == "fire_staff:life_staff"){
			server_CreateBlob("lifefire_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "water_staff:life_staff" || name2+":"+name == "water_staff:life_staff"){
			server_CreateBlob("waterlife_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "fire_staff:stone_staff" || name2+":"+name == "fire_staff:stone_staff"){
			server_CreateBlob("firestone_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "evil_staff:plant_staff" || name2+":"+name == "evil_staff:plant_staff"){
			server_CreateBlob("evilplant_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "gold_staff:blood_staff" || name2+":"+name == "gold_staff:blood_staff"){
			server_CreateBlob("goldblood_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		//if(name+":"+name2 == "death_staff:gold_staff"){
		//	CBlob @wraithstaff = server_CreateBlob("golddeath_staff", this.getTeamNum(), this.getPosition()); 
		//	wraithstaff.set_string("ghost",this.get_string("ghost"));
		//	return true;
		//}
		
		if(name+":"+name2 == "death_staff:water_staff"){
			CBlob @wraithstaff = server_CreateBlob("waterdeath_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			return true;
		}
		
		if(name+":"+name2 == "fire_staff:blood_staff" || name2+":"+name == "fire_staff:blood_staff"){
			server_CreateBlob("fireblood_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "water_staff:plant_staff" || name2+":"+name == "water_staff:plant_staff"){
			server_CreateBlob("waterplant_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "evildeath_staff:fireblood_staff"){
			CBlob @wraithstaff = server_CreateBlob("bad_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			return true;
		}
		
		if(name+":"+name2 == "goldlife_staff:waterplant_staff" || name2+":"+name == "goldlife_staff:waterplant_staff"){
			server_CreateBlob("good_staff", this.getTeamNum(), this.getPosition()); 
			return true;
		}
		
		if(name+":"+name2 == "bad_staff:good_staff"){
			CBlob @wraithstaff = server_CreateBlob("omni_staff", this.getTeamNum(), this.getPosition()); 
			wraithstaff.set_string("ghost",this.get_string("ghost"));
			return true;
		}
	}
	return false;
}