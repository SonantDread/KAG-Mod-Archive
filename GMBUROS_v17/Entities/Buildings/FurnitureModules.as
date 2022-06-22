
void onInit(CBlob @this){
	this.addCommandID("build_module");
	this.Tag("furniture");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{

	if(!checkSideBlocked(this,true))
	if(caller.getPosition().x > this.getPosition().x+8){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_bool(true);
		
		CButton@ button = caller.CreateGenericButton(17, Vec2f(8,4), this, this.getCommandID("build_module"), "Build Module", params);
		button.enableRadius = 16;
	}
	
	if(!checkSideBlocked(this,false))
	if(caller.getPosition().x < this.getPosition().x-8){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_bool(false);
		
		CButton@ button = caller.CreateGenericButton(18, Vec2f(-8,4), this, this.getCommandID("build_module"), "Build Module", params);
		button.enableRadius = 16;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	
	if (cmd == this.getCommandID("build_module"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		bool right_side = params.read_bool();
		if(caller !is null)
		{
			if(getNet().isServer()){
				if(!checkSideBlocked(this,right_side)){
				
					if(right_side){
						CBlob @module = server_CreateBlob("module",-1,this.getPosition()+Vec2f(20.0f,0));
						if(module !is null){
							module.set_u16("owner",this.getNetworkID());
						}
					} else {
						CBlob @module = server_CreateBlob("module",-1,this.getPosition()-Vec2f(20.0f,0));
						if(module !is null){
							module.set_u16("owner",this.getNetworkID());
						}
					}
				}
			}
		}
	}
}

bool checkSideBlocked(CBlob @this, bool right){
	
	Vec2f pos = this.getPosition();
	
	if(right){
		if(CheckPosBlocked(pos+Vec2f(16,-8))
		|| CheckPosBlocked(pos+Vec2f(16,0))
		|| CheckPosBlocked(pos+Vec2f(16,8))
		
		|| CheckPosBlocked(pos+Vec2f(24,-8))
		|| CheckPosBlocked(pos+Vec2f(24,0))
		|| CheckPosBlocked(pos+Vec2f(24,8))
		) return true;
	} else {
		if(CheckPosBlocked(pos+Vec2f(-16,-8))
		|| CheckPosBlocked(pos+Vec2f(-16,0))
		|| CheckPosBlocked(pos+Vec2f(-16,8))
		
		|| CheckPosBlocked(pos+Vec2f(-24,-8))
		|| CheckPosBlocked(pos+Vec2f(-24,0))
		|| CheckPosBlocked(pos+Vec2f(-24,8))
		) return true;
	}
	
	return false;
}

bool CheckPosBlocked(Vec2f middle){
	
	CMap @map = getMap();
	
	if(map.getSectorAtPosition(middle, "no build") !is null)return true;
	
	CBlob@[] blobs;
	
	map.getBlobsAtPosition(middle, @blobs);

	if(blobs !is null)
	for(int i = 0;i < blobs.length;i++){
		if(blobs[i] !is null)
		if(blobs[i].getShape() !is null)
		if(blobs[i].getShape().isStatic()){
			
			return true;
		}
	}
	
	/*
	CBlob @blocking = map.getBlobAtPosition(middle+Vec2f(4,4));
	if(blocking !is null){
		if(blocking.getShape().isStatic())return true;
	}*/
	
	if(map.isTileSolid(middle))return true;
		
	
	return false;
}