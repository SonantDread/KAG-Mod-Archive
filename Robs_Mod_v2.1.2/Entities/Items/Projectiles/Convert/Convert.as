#include "Hitters.as";

void onInit(CBlob@ this)
{
	//dont collide with edge of the map
	this.SetMapEdgeFlags(CBlob::map_collide_none);
	
	this.getShape().getConsts().bullet = true;
}

void onTick(CBlob@ this)
{
	if (this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale(0.0f);
		this.server_SetTimeToDie(3);

		// done post init
		this.getCurrentScript().tickFrequency = 10;
	}
	
	this.setAngleDegrees(-((this.getVelocity()).Angle()+180));
	
	{
		u16 id = this.get_u16("target");
		if (id != 0xffff && id != 0)
		{
			CBlob@ b = getBlobByNetworkID(id);
			if (b !is null)
			{
				Vec2f vel = this.getVelocity();
				if (vel.LengthSquared() < 9.0f)
				{
					Vec2f dir = b.getPosition() - this.getPosition();
					dir.Normalize();


					this.setVelocity(vel + dir);
				}
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player"));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null && blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && blob.hasTag("player"))
	{
		int Team = 2;
		if(this.getTeamNum() > 1)Team = XORRandom(6)+2;
		blob.server_setTeamNum(Team);
		this.server_Die();
	}
	
	if(solid)this.server_Die();
	if(blob !is null)if(blob.getName() == "stone_door" || blob.getName() == "wooden_door")if(blob.getShape().getConsts().collidable)this.server_Die();
}