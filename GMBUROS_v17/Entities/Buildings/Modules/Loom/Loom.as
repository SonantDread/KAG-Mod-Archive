
void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
	
	this.addCommandID("use");
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("use"), "Convert Fibre into Cloth", params);
		if(button !is null)if(!caller.hasBlob("fibre", 1))button.SetEnabled(false);
	}
}

void onInit(CSprite @this){
	this.RemoveSpriteLayer("wheel");
	CSpriteLayer@ backarm = this.addSpriteLayer("wheel", "Loom.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		backarm.SetRelativeZ(0.1);
		backarm.SetOffset(Vec2f(-0.5f,3));
	}
	
	this.RemoveSpriteLayer("front");
	@ backarm = this.addSpriteLayer("front", "Loom.png" , 16, 24, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(2);
		backarm.SetRelativeZ(0.2);
	}
}


void onTick(CSprite @this){

	if(this.getSpriteLayer("wheel") !is null){
		this.getSpriteLayer("wheel").RotateBy(5,Vec2f(0.5,-0.5f));
	}

}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{	
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				if(caller.hasBlob("fibre", 1)){
					caller.TakeBlob("fibre", 1);
					server_CreateBlob("cloth",-1,this.getPosition());
				}
			}
		}
	}
}