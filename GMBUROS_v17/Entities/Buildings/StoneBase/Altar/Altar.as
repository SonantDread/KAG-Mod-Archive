// Genreic building

#include "ClanCommon.as";

void onInit(CBlob@ this){
	this.SetLight(true);
	this.SetLightRadius(12.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.addCommandID("infuse");
	this.addCommandID("lie");
	
	this.Tag("save");
	this.set_u8("InfuseType",0);
}

void onTick(CBlob @this){
	if(getGameTime() % 20 ==0){
		if(!this.hasAttached())ParticleAnimated("SmallFire"+(XORRandom(1)+1)+".png", this.getPosition()+Vec2f(7,-3), Vec2f(0, 0), 0.0f, 1.0f, 5, -0.01, true);
	} else 
	if(getGameTime() % 20 ==10){
		if(!this.hasAttached())ParticleAnimated("SmallFire"+(XORRandom(1)+1)+".png", this.getPosition()+Vec2f(-7.5f,-3), Vec2f(0, 0), 0.0f, 0.75f, 5, -0.01, true);
	} else {
		if(getGameTime() % 123 == 0){
			if(this.get_u16("ClanID") != 0)this.set_u8("InfuseType",1);
			
			this.getSprite().SetFrame(this.get_u8("InfuseType"));
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.hasAttached()){
		if(this.isOverlapping(caller)){
			if(this.get_u8("InfuseType") == 0 && getBlobClan(caller) != 0){
				CBitStream params;
				params.write_u16(caller.getNetworkID());

				if(caller.getCarriedBlob() is null){
					CButton @but = caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("infuse"), "Place cloth to claim for clan", params);
					if(but !is null){
						but.SetEnabled(false);
					}
				} else {
					caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("infuse"), "Claim for Clan", params);
				}
			}
		}
	} else {
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(10, Vec2f(0,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
		button.enableRadius = 16;
	}
	if(!getMap().rayCastSolid(caller.getPosition(),this.getPosition())){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		string butname = "Lie Down";
		
		if(caller.isAttachedTo(this))butname = "Get off";
		else {
			if(this.isAttachedToPoint("BED")){
				butname = "Take off";
			} else
			if(caller.getCarriedBlob() !is null){
				butname = "Place on";
			}
		}
		
		CButton@ button = caller.CreateGenericButton(29, Vec2f(0,-8), this, this.getCommandID("lie"), butname, params);
		button.enableRadius = 32;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("infuse"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			if(isServer() && this.get_u16("ClanID") == 0){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null)
				if(hold.getName() == "cloth")
				if(caller.getPlayer() !is null){
					hold.server_Die();
					this.set_u16("ClanID",getBlobClan(caller));
					this.set_u8("InfuseType",1);
					this.Sync("ClanID",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("lie"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("BED")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("BED") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("BED");
						this.server_DetachFrom(attachedBlob);
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold is null){
					
						if(!this.isAttachedTo(caller)){
							this.server_AttachTo(caller, "BED");
						} else {
							this.server_DetachFrom(caller);
						}
					
					} else {
						caller.DropCarried();
						this.server_AttachTo(hold, "BED");
					}
				
				}
			}
		}
	}
}