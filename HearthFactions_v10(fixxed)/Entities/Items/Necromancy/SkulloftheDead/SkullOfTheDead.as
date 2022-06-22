#include "Help.as";
#include "Hitters.as";

//When this is created
void onInit( CBlob@ this )
{
	HelpText help;//add the help text
	this.addCommandID( "summon coin" );//add the command (used for when the button is pressed)
	SetHelp( this, "help use carried", "Help!", "Hello i am being used","ah i love being carried", 20);//create add the help text
}

void onTick( CBlob@ this )
{
	CMap@ map = this.getMap();
	map.server_DestroyTile(this.getPosition(), 0.01f, this);
}
//create the button with the command created above^
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("summon coin"), "Activate skull", params );
	//Create the button 
}
//When the button is pressed
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	//If the button is the right button (one object can have more then one button, this is why you need to check for the command)
	if (cmd == this.getCommandID("summon coin"))
	{

		//Spawn zambi or skele
		CBlob@ spawn = server_CreateBlob("skeleton",-1,this.getPosition());
		spawn.server_setTeamNum(10);
		this.server_Die();
	}
}