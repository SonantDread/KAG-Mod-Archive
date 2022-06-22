#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 255, 0, 255));
	
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	
	this.getSprite().SetVisible(false);
	
	this.set_Vec2f("goal",Vec2f(0,0));
	
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.server_SetTimeToDie(3.0f);
}

void onTick(CBlob@ this)
{

	this.getSprite().SetVisible(true);
	
	
	if(this.getPosition().x < this.get_Vec2f("goal").x+5)
	if(this.getPosition().x > this.get_Vec2f("goal").x-5)
	if(this.getPosition().y < this.get_Vec2f("goal").y+5)
	if(this.getPosition().y > this.get_Vec2f("goal").y-5){
		this.server_Die();
	}
	
	
	ParticleAnimated("MindPuff.png", this.getPosition(), this.getVelocity()/10+Vec2f(XORRandom(3)-1,XORRandom(3)-1)*0.2, XORRandom(360), 1.0f, 3, -0.01, true);

}

void onDie(CBlob@ this)
{

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b !is this && !b.getShape().isStatic() && b.getName() != "princess"){
					Vec2f dir = this.getPosition()-b.getPosition();
					dir.Normalize();
					b.setVelocity(dir*15+b.getVelocity());
				}
			}
		}
	}
	
	Vec2f vec = Vec2f(64,0);
	for(int r = 0; r < 360; r += 10){
		vec.RotateBy(r);
		Vec2f dir = this.getPosition()-(this.getPosition()+vec);
		dir.Normalize();
		ParticleAnimated("MindPuff.png", this.getPosition()+vec, dir*3, XORRandom(360), 0.8f, 3, -0.01, true);
	}

}