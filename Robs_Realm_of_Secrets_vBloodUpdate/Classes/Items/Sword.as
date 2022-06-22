void onInit( CBlob@ this )
{
	this.Tag("sword");
	this.addCommandID("equip");
	
	this.set_u8("sword_id",0);
	this.set_f32("sword_damage_multi",1);
}


void onTick( CBlob@ this )
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("SWORD");
	if(point !is null){
		CBlob@ holder = point.getOccupied();
		
		if (holder !is null){
			if(holder.getName() == "knight")this.getSprite().SetVisible(false);
			else this.getSprite().SetVisible(true);
		} else {
			this.getSprite().SetVisible(true);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() is this && caller.getName() == "knight"){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("equip"), "Equip sword", params);
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
			caller.server_AttachTo(this, "SWORD");
		}
	}
}