// BF_Storage script

#include "Requirements.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";
#include "MakeMat.as";
void onInit( CBlob@ this )
{
    
    this.getSprite().SetZ(-50);
	this.getCurrentScript().tickFrequency = 30;
    this.getShape().getConsts().mapCollisions = false;
	this.set_bool( "Heal" , false);
	this.addCommandID("Roast");
	
	this.set_bool( "Roaston", false);
	
	this.SetLightRadius( 64.0f );
	
	this.SetLightColor( SColor(255, 255, 240, 171 ) );
	
	this.SetLight(false);
	
}
void onTick( CBlob@ this )
{
	Vec2f hPos = this.getPosition();
	Vec2f boxTL = Vec2f( hPos.x - 10.0f, hPos.y - 10.0f );
	Vec2f boxBR = Vec2f( hPos.x + 10.0f, hPos.y + 10.0f );
	
	CBlob@[] targets;
	getMap().getBlobsInBox( boxTL, boxBR, @targets );
	int tNumber = targets.length();
	
	for( int i = 0; i < tNumber; i++ )
	{
		if ( targets[i] !is null && this.get_bool( "heal"))
		{
			if (targets[i].getTeamNum() == 0  && targets[i].getHealth() < targets[i].getInitialHealth() )
			{
				targets[i].server_Heal( 0.2f );
				if (targets[i].getName() != "bf_roast")
				{
					//Vec2f tPos = targets[i].getPosition();
					//ParticleAnimated("BF_EffectHeal.png", tPos, Vec2f(0,0), 0.0f, 1.0f, 5, 0.0f, true );
					ParticleAnimated("BF_EffectHeal.png", targets[i].getPosition() + Vec2f(0.0f, -3.0f), Vec2f(0,0), 0.0f, 1.0f, 5, -0.01f, true );
					
				}
			}
		}
	}
}

string isRoaston(CBlob@ this)
{
   if(this.get_bool("Roaston"))
   {
		return "Turn Roast off";
   }
   else
   {
		return "Turn Roast on";
   }
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	print("button call");
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ Fire_on = caller.CreateGenericButton( "$mat_wood$", Vec2f(0.0f,1.0f), this, this.getCommandID("Roast"), "", params);
	if((caller.getDistanceTo(this) < 10.0f && this.get_bool("Roaston")) || (caller.getBlobCount("pigcooked") >= 1 && caller.getDistanceTo(this) < 10.0f))
	{
		if(Fire_on != null)
		{
			Fire_on.SetEnabled(true);
		}
	}
	else
	{
			Fire_on.SetEnabled(false);
	}
	
	
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{	
		u16 netID;
		print("1");
		if(!params.saferead_netid(netID))
		{
		    return;
		}
		print("2");
        CBlob@ caller = getBlobByNetworkID(netID);
		
	CSprite@ sprite = this.getSprite();
	print("3");
	if(cmd == this.getCommandID("Roast") && !this.get_bool( "Roaston") && caller != null)
	{
	print("4");
		this.set_bool( "Roaston" , true);
		this.set_bool( "Heal" , true);
		sprite.SetAnimation("cook");
		caller.TakeBlob("pigcooked", 1);
		this.SetLight(true);
	}
	else if(cmd == this.getCommandID("Roast") && this.get_bool( "Roaston"))
	{
		this.set_bool( "Roaston" , false);
		this.set_bool( "Heal" , false);
		sprite.SetAnimation("default");
		this.SetLight(false);
		MakeMat(caller, this.getPosition(), "pigcooked", 1);
		
	}
}


