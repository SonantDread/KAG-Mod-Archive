#include "Hitters.as";
#include "ModHitters.as";
#include "CommonParticles.as";
#include "DarkExplosionCommon.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().mapCollisions = false;
	
	this.getShape().SetGravityScale(0.0f);
	
	//this.set_bool("explosive_teamkill",true);
	this.set_f32("map_damage_radius",32.0f);
	
	this.set_u32("spawntime",getGameTime());
	
	this.set_u8("amount",7);
	this.set_s16("direction",XORRandom(360));
	
	///no comment
}

void onTick(CBlob@ this)
{
	if(isServer())
	if(getGameTime() > this.get_u32("spawntime") + 5){
		this.server_Die();
	}
}

void onDie(CBlob @this){
	Explode(this, 32.0f, 2.0f);
	if(this.get_u8("amount") > 0)
	if(isServer()){
		Vec2f pos = Vec2f(32,0);
		pos.RotateByDegrees(this.get_s16("direction")+XORRandom(90)-45);
		CBlob @child = server_CreateBlob("dark_explosion",this.getTeamNum(),this.getPosition()+pos);
		if(child !is null){
			child.set_u8("amount",this.get_u8("amount")-1);
			child.set_s16("direction",this.get_s16("direction"));
		}
	}
}