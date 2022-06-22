#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 220, 151));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	this.server_SetTimeToDie(20.0f);
	
	this.set_f32("damage",0.0f);
}

void onTick(CBlob@ this)
{
	this.AddForce(Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.1);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null)return;
	
	if(blob.hasTag("flesh") && !blob.hasTag("dead"))
	{
		this.server_Hit(blob, blob.getPosition(), this.getVelocity()*-0.5f, this.get_f32("damage"), Hitters::suddengib, false);
		this.server_Die();
	}	
}