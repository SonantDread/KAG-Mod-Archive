#include "Hitters.as"

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onInit(CBlob @this){

	this.set_u8("heat",0);
	this.Tag("save");
}

void onTick(CBlob @this){

	if(!this.hasTag("melted") && !this.hasTag("washed"))
	
	if(this.get_u8("heat") > 10){
		
		if(getNet().isServer()){
			
			{CBlob @blob = server_CreateBlob("molten_metal_small",-1,this.getPosition()+Vec2f(-4,0));
			blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));}
			
			if(XORRandom(3) == 0){
				CBlob @blob = server_CreateBlob("molten_metal_small",-1,this.getPosition()+Vec2f(4,0));
				blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			}
			
			if(XORRandom(2) == 0){
				CBlob @blob = server_CreateBlob("molten_metal_dirty",-1,this.getPosition()+Vec2f(0,0));
				blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			}
			if(XORRandom(2) == 0){
				CBlob @blob = server_CreateBlob("molten_metal_dirty",-1,this.getPosition()+Vec2f(0,0));
				blob.setVelocity(this.getVelocity()+Vec2f((XORRandom(11)-5.0f)*0.5f,(XORRandom(11)-5.0f)*0.5f));
			}
			
			this.server_Die();
		}
		
		this.Tag("melted");
	}

	if(!this.hasTag("melted") && !this.hasTag("washed"))
	if(this.isInWater()){
	
		if(getNet().isServer()){
			if(XORRandom(2) == 0){
				server_CreateBlob("metal_drop",-1,this.getPosition()+Vec2f(0,0));
			} else {
				server_CreateBlob("metal_drop_small",-1,this.getPosition()+Vec2f(0,0));
			}
		}
		
		this.server_Die();
		this.Tag("washed");
	}

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::burn)
	{
		this.set_u8("heat",this.get_u8("heat")+1);
		damage = 0;
	}

	if (customData == Hitters::water)
	{
		this.set_u8("heat",0);
	}

	return damage;
}