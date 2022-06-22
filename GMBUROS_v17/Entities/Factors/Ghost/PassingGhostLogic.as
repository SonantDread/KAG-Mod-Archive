//Ghost logic

#include "TimeCommon.as"
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	
	this.getShape().getConsts().mapCollisions = false;
	
	this.SetMapEdgeFlags(CBlob::map_collide_none);

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.Tag("ghost");
	this.Tag("invincible");
	
	this.SetLight(true);
	this.SetLightColor(SColor(128,48,64,48));
	this.SetLightRadius(1.0f);
	
	this.set_u32("delay",getGameTime()+XORRandom(30*10));
}

void onTick(CBlob@ this)
{
	if(this.isInInventory() || getGameTime() < this.get_u32("delay"))
		return;
	
	if(this.hasTag("going_right")){
		this.setKeyPressed(key_right, getGameTime() % 3 == 0);
		if(isServer())if(this.getPosition().x > getMap().tilemapwidth*8+32)this.server_Die();
	} else {
		this.setKeyPressed(key_left, getGameTime() % 3 == 0);
		if(isServer())if(this.getPosition().x < -32)this.server_Die();
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid ){
	if(blob !is null){
		if(blob.getName() == "humanoid"){
			SetKnocked(blob, 60);
			if(blob is getLocalPlayerBlob())if(this.getSprite() !is null)this.getSprite().PlaySound("boo.ogg",1.0f);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("ghost");
}