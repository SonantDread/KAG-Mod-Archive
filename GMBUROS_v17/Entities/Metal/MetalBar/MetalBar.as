
void onInit(CBlob @this){
	this.Tag("hard_liquid_blob");
	this.Tag("save");
}

void onTick(CBlob @this){

	if(this.hasTag("heated"))
	if(!this.hasTag("melted")){
		this.Tag("melted");
		if(getNet().isServer()){
		
			if(this.getName() == "metal_bar")server_CreateBlob("molten_metal",-1,this.getPosition());
			if(this.getName() == "metal_bar_large")server_CreateBlob("molten_metal_large",-1,this.getPosition());
			
			if(this.getName() == "gold_bar")server_CreateBlob("molten_gold",-1,this.getPosition());
			
			this.server_Die();
		}
	}

}