#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	this.getShape().getConsts().bullet = true;
	
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 0, 255, 0));
	
	this.getShape().SetGravityScale(0.0f);
	//this.getShape().getConsts().mapCollisions = false;
	this.server_SetTimeToDie(5.0f);
}

void onTick(CBlob@ this)
{
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 96.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(!b.hasTag("dead"))
			if(b.hasTag("flesh") && b.getTeamNum() != this.getTeamNum() && !b.hasTag("Plagued") && b.getName() != "migrant")
			{
				Vec2f Vel = b.getPosition()-this.getPosition();
				Vel.Normalize();
				this.AddForce(Vel*0.1);
			}
		}
	}

}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob is null)return;
	
	if(!blob.hasTag("dead"))
	if(blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && !blob.hasTag("Plagued") && blob.getName() != "migrant")
	{
		blob.AddScript("Plague.as");
		this.server_Die();
	}
	
}