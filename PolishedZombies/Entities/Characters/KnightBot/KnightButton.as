#include "BrainBotCommon"

void onInit(CBlob@ this)
{			 
    this.addCommandID("knight_standground");
	this.addCommandID("allow_chase");

    AddIconToken("$stop_knight$", "Orders.png", Vec2f(32,32), 3);
    AddIconToken("$start_knight$", "Orders.png", Vec2f(32,32), 0);
	this.getCurrentScript().tickFrequency = 31;
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("dead"))
		return;

	bool standground = this.get_bool("standground");

	CBitStream params;
	const string name = this.getName();
	if (!standground)
	{
		standground = true;
		params.write_bool(standground);
		caller.CreateGenericButton("$stop_knight$", Vec2f(0, 0), this,  this.getCommandID("knight_standground"), "Tell knight to standground", params);
	}
	else
	{
		standground = false;
		params.write_bool(standground);
		caller.CreateGenericButton("$start_knight$", Vec2f(0, 0), this,  this.getCommandID("allow_chase"), "Allow knight to chase target", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool standground = false;
	if (cmd == this.getCommandID("knight_standground"))
	{	
		standground = params.read_bool();
		this.set_bool("standground", standground);
	}
	else if (cmd == this.getCommandID("allow_chase"))
	{
		standground = params.read_bool();
		this.set_bool("standground", standground);
	}
}