// Genreic building

#include "LimbsCommon.as";

void onInit(CBlob @ this)
{
	
	this.getSprite().SetZ(-50.0f);
	
	this.addCommandID("lie");
	
	this.Tag("save");
}

void onTick(CBlob @ this)
{
	if(this.isAttachedToPoint("BED")){
		CAttachment@ attach = this.getAttachments();
		CBlob @patient = attach.getAttachedBlob("BED");
		if(patient !is null){
			patient.SetFacingLeft(false);
			
			if(getGameTime() % 60 == 0 && patient.hasTag("alive")){
				
				Sound::Play("Heart.ogg", patient.getPosition(), 0.5);
				
				if(isServer()){
					LimbInfo@ limbs;
					if(!patient.get("limbInfo", @limbs))return;
					
					if(isLivingFlesh(limbs.Head))healLimb(limbs,LimbSlot::Head,0.25f);
					if(isLivingFlesh(limbs.Torso))healLimb(limbs,LimbSlot::Torso,0.25f);
					if(isLivingFlesh(limbs.MainArm))healLimb(limbs,LimbSlot::MainArm,0.25f);
					if(isLivingFlesh(limbs.SubArm))healLimb(limbs,LimbSlot::SubArm,0.25f);
					if(isLivingFlesh(limbs.FrontLeg))healLimb(limbs,LimbSlot::FrontLeg,0.25f);
					if(isLivingFlesh(limbs.BackLeg))healLimb(limbs,LimbSlot::BackLeg,0.25f);
					
					
					
					syncBody(patient);
				}
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
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

/*
	if(this.isAttachedToPoint("BED")){
		CAttachment@ attach = this.getAttachments();
		if(attach.getAttachedBlob("BED") !is null)
		if(attach.getAttachedBlob("BED").getName() == "humanoid"){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(10, Vec2f(0,0), this, this.getCommandID("surgery"), "Perform Surgery", params);
		}
	}*/
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
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