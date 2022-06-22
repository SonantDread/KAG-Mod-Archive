//This file should be included in any blob that suffers status effects (animals too, TODO)

#include "EnergyCommon.as";

void onInit(CBlob @this){

	this.set_u8("MaxEnergy", 1); //Why is energy control by this file? Too lazy to make another file that goes in every blob <.<

	this.set_u8("Energy", 0);
	this.set_u8("MaxEnergy", getMaxEnergy(this.getName()));
}

void onTick(CBlob @this){

	if(getGameTime() % (30) == 0)
	if(this.getPlayer() !is null){
		this.set_string("username",this.getPlayer().getUsername());
	}

	if(!this.hasTag("flying"))
	if(getGameTime() % (30*5) == 0){
		if(getEnergy(this) < this.get_u8("MaxEnergy"))
			addEnergy(this, 1);
		else
			setEnergy(this, this.get_u8("MaxEnergy"));
	}

	this.set_u8("MaxEnergy", getMaxEnergy(this.getName()));
}


//For some odd reason, onHit doesn't work properly when AddScripted(), so most of the defense buffs won't work
//This is a work around obviously

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	
	if(this.hasTag("StoneShield"))damage -= 0.5f;
	
	if(this.hasTag("Protected")){
		damage *= 0.5f;
		
		if(this.getName() == "paladin")damage *= 0.5f;
	}
	
	if(this.hasTag("Barrier")){
		damage = 0.0f;
		this.Untag("Barrier");
		this.RemoveScript("Barrier.as");
		
		CSprite@ sprite = this.getSprite();
		if(sprite !is null){
			sprite.RemoveSpriteLayer("barrier");
			sprite.RemoveSpriteLayer("barrieroutter");
		}
	}
	
	if(damage < 0)damage = 0;
	
	return damage;
}

void Useless(){
	return;
}

