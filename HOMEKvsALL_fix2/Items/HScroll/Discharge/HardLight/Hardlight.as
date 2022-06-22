#include "Hitters.as";
#include "TeamColour.as";
#include "MakeDustParticle.as";

void onInit( CBlob@ this )
{

	this.addCommandID("aim A1");
}	

void onTick( CBlob@ this )
{     
	if(this.getCurrentScript().tickFrequency == 1)
	{
		this.getShape().SetGravityScale( 0.0f );
		this.server_SetTimeToDie(44);
		this.SetLight( true );
		this.SetLightRadius( 32.0f );
		this.SetLightColor( getTeamColor(this.getTeamNum()) );
		this.Tag("surge");	
		
		// done post init
		this.getCurrentScript().tickFrequency = 3;
	}
	
	const u32 gametime = getGameTime();
	
	Vec2f target;
	bool targetSet;
	bool vanish;
	
	CPlayer@ A1 = this.getDamageOwnerPlayer();
	if( A1 !is null)	{
		CBlob@ A2 = A1.getBlob();
		if( A2 !is null)	{
			if( A1.isMyPlayer() )
			{
				Vec2f aimPos = A2.getAimPos();
				CBitStream params;
				params.write_Vec2f(aimPos);
				this.SendCommand(this.getCommandID("aim A1"), params);
			}
			target = this.get_Vec2f("aimpos");
			targetSet = true;
			vanish = A2.isKeyPressed( key_action2 );
		}
	}
	
	if(targetSet)
	{
		if(!vanish)
		{
			this.getShape().setDrag(1.0f);
			
			Vec2f vel = this.getVelocity();
			Vec2f dir = target-this.getPosition();
			float distanceToCursor = dir.Length();
			if(distanceToCursor > 5.0f)
			{
				dir.Normalize();
				dir *= 5.0f;
			}

			vel += dir;
			
			this.setVelocity(vel);
		}
		else
		{
			this.server_Die();
		}
	}

}

bool isEnemy( CBlob@ this, CBlob@ target )
{
	CBlob@ friend = getBlobByNetworkID(target.get_netid("brain_friend_id"));
	return (( target.getTeamNum() != this.getTeamNum() )||(target.hasTag("flesh") && !target.hasTag("dead") && target.getTeamNum() != this.getTeamNum() && ( friend is null || friend.getTeamNum() != this.getTeamNum() )));
}	

bool doesCollideWithBlob( CBlob@ this, CBlob@ b )
{
	return (isEnemy(this, b) || b.hasTag("door") || (b.getPlayer() !is null && this.getDamageOwnerPlayer() !is null&& b.getPlayer() is this.getDamageOwnerPlayer()|| b.getName() == this.getName() || b.getTeamNum() == this.getTeamNum() )); 
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (solid)
	{
		if(blob !is null && (isEnemy(this, blob)))
		{
			this.server_Hit(blob, blob.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire, true); 
		} 
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("aim A1"))
    {
        this.set_Vec2f("aimpos", params.read_Vec2f());
    }
}

