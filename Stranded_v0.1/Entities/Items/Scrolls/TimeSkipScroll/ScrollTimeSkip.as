

#include "Hitters.as";

void onInit( CBlob@ this )
{
	this.addCommandID( "TimeSkip" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("TimeSkip"), "Use this a random amount of time in to the future.", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("TimeSkip"))
	{
		ParticleZombieLightning( this.getPosition() );

		bool hit = false;
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null)
		{
			if (getNet().isServer())
			{
				getRules().add_s32("days_offset", 3+XORRandom(9));
				getMap().SetDayTime(0.5);
				hit = true;
			}
		}

		if (hit)
		{
			this.server_Die();
			Sound::Play( "TimeSkip.ogg" );
		}
	}
}