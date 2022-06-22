

void SummonDarkBlade(CBlob @this){
	if(this.get_s16("darkness") >= 40){
		server_CreateBlob("dark_blade", this.getTeamNum(), this.getPosition());
		
		this.sub_s16("darkness",39);
	}
}

void SummonDarkGreatBlade(CBlob @this){
	CBlob@[] blobsInRadius;
	getBlobsByName("shadow_blade",@blobsInRadius);
	getBlobsByTag("has_shadow_sword",@blobsInRadius);
	if(blobsInRadius.length <= 0)
	if(this.get_s16("darkness") >= 200){
		server_CreateBlob("shadow_blade", this.getTeamNum(), this.getPosition());
		
		this.sub_s16("darkness",199);
	}
}

void SummonGreaterDarkStaff(CBlob @this){
	if(this.get_s16("darkness") >= 200){
		server_CreateBlob("greater_dark_staff", this.getTeamNum(), this.getPosition());
		
		this.sub_s16("darkness",199);
	}
}