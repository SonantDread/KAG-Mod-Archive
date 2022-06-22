#include "Help.as";
#include "Hitters.as";

s32 variance = 300;

void onInit( CBlob@ this )
{
	HelpText help;//add the help text
	this.addCommandID( "summon" );
	SetHelp( this, "help use carried", "Help!", "Hello i am being used","ah i love being carried", 20);
}

//create the button with the command created above^
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("summon"), "Initiate the rain.", params );
	//Create the button 
}

//When the button is pressed
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	for (s32 vtime = 0; vtime < 8; vtime++)
	{
		CBlob@ b = server_CreateBlob("keg");
	 	if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	 	{b.SendCommand(b.getCommandID("activate"));
	 	}
	 	if (vtime == 7)
		{
			this.server_Die();
		}
	}
}