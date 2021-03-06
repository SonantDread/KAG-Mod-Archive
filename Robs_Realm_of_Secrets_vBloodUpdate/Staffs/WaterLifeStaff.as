#include "ElementalControl.as";

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	
	this.set_u16("timer",0);
	this.set_u16("super_timer",300);
	
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(16.0f);
}

void onTick(CBlob@ this)
{

	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();

		if (holder is null){
			@point = this.getAttachments().getAttachmentPointByName("STAFF");
			@holder = point.getOccupied();
			AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("STAFF");
			if (ap !is null)
			{
				ap.SetKeysToTake(key_action1 | key_action3);
			}
		}
		
		if (holder is null) return;

		this.getSprite().SetOffset(Vec2f(7,1));
		
		this.getShape().SetRotationsAllowed(false);

		if (holder.get_u8("knocked") <= 0)
		{
			if(this.get_u16("timer") < 90)this.set_u16("timer",this.get_u16("timer")+1);
			else
			if(point.isKeyPressed(key_action1))if(getNet().isServer()){
				CBlob @blob = server_CreateBlob("fishy", holder.getTeamNum(), this.getPosition());
				if (blob !is null)
				{
					Vec2f shootVel = holder.getAimPos()-this.getPosition();
					shootVel.Normalize();
					blob.setVelocity(shootVel*8);
					blob.SetDamageOwnerPlayer(holder.getPlayer());
				}
				this.set_u16("timer",0);
			}
			
			if(point.isKeyPressed(key_action2)){
				ControlElements(holder.getAimPos(),false,true,false,false,false,false,true,false,false,false,false);
			}
			
			if(this.get_u16("super_timer") < 300)this.set_u16("super_timer",this.get_u16("super_timer")+1);
			else
			if(point.isKeyPressed(key_action3))if(getNet().isServer()){
				for(uint i = 0; i < 10; i += 1){
					CBlob @blob = server_CreateBlob("fishy", holder.getTeamNum(), Vec2f(holder.getAimPos().x-40+i*8,0));
					if (blob !is null)
					{
						blob.setVelocity(Vec2f(0,XORRandom(5)));
						blob.SetDamageOwnerPlayer(holder.getPlayer());
						blob.set_u8("launch team", holder.getTeamNum());
					}
				}
				this.set_u16("super_timer",0);
			}
		}
	}
	else
	{
		this.getSprite().SetOffset(Vec2f(0,0));
		this.getShape().SetRotationsAllowed(true);
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
}

void onDie(CBlob@ this){
	if(getNet().isServer())server_CreateBlob("derangedwisp", -1, this.getPosition()+Vec2f(0,-8)); 
}