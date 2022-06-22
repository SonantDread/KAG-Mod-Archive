#include "ProductionCommon.as";
#include "Requirements.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	
	if(this.get_u16("wood_amount") > 0){
		this.set_u16("wood_amount", this.get_u16("wood_amount")-1);
	}
	
	f32 radius = this.get_u16("wood_amount")/50*16;
	if(this.get_u16("wood_amount") < 50)radius = 0;
	this.SetLightRadius(radius);

	CBlob@[] blobsInRadius;	 
	if(getNet().isServer()){
		this.Sync("wood_amount",true);
		
		if(this.get_u16("wood_amount") > 300)
		if (this.getMap().getBlobsInRadius(this.getPosition(), 4.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(isServer()){
					if(b !is this)
					if(!b.hasTag("flesh") || this.get_u16("wood_amount") >= 300){
						f32 burn = f32(this.get_u16("wood_amount"))/50.0f*0.25f;
						this.server_Hit(b, b.getPosition(), Vec2f(), burn, Hitters::burn, true);
					}
				}
				
				if(b.hasTag("liquid_blob")){
					b.set_u32("last_heated",getGameTime());
				}
				
				if(b.hasTag("metaldrop") || b.hasTag("hard_liquid_blob")){
					b.Tag("heated");
				}
			}
		}
	}
}	