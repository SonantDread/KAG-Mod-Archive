#include "Hitters.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
	
	this.getShape().SetGravityScale(0.0f);
	this.server_SetTimeToDie(3);
	
	this.getSprite().SetZ(5);
}

void onTick(CBlob@ this)
{
	
	Vec2f vel = this.getVelocity();
	if (Maths::Abs(vel.x) > 0.1)
	{
		f32 angle = this.get_f32("angle");
		angle += vel.x * 10;
		if (angle > 360.0f)
			angle -= 360.0f;
		else if (angle < -360.0f)
			angle += 360.0f;
		this.set_f32("angle", angle);
		this.setAngleDegrees(angle);
	}
	
	ParticleAnimated("SwitchParticle.png", this.getPosition()+Vec2f(XORRandom(16)-8,XORRandom(16)-8), this.getVelocity()/2+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 1, -0.01, true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player"));
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	{
		CPlayer@ p = blob.getPlayer();
		if(p !is null){
			if(this.getDamageOwnerPlayer() !is null){
				CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				if(b !is null){
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					b.server_SetPlayer(p);
					b.server_setTeamNum(p.getTeamNum());
				} else {
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				}
			}
		} else {
			if(this.getDamageOwnerPlayer() !is null){
				CBlob@ b = this.getDamageOwnerPlayer().getBlob();
				if(b !is null){
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
					b.server_SetPlayer(null);
				} else {
					blob.server_SetPlayer(this.getDamageOwnerPlayer());
					blob.server_setTeamNum(this.getDamageOwnerPlayer().getTeamNum());
				}
			}
		}
	}
	
	if(solid)this.server_Die();
	if(blob !is null)if(blob.getName() == "stone_door" || blob.getName() == "wooden_door")if(blob.getShape().getConsts().collidable)this.server_Die();
}