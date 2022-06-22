#include "BrainBotCommon"

void onInit(CBlob@ this)
{			 
    this.addCommandID("archer_standground");
	this.addCommandID("allow_flee");

    AddIconToken("$stop_archer$", "Orders.png", Vec2f(32,32), 3);
    AddIconToken("$start_archer$", "Orders.png", Vec2f(32,32), 5);
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
		caller.CreateGenericButton("$stop_archer$", Vec2f(0, 0), this,  this.getCommandID("archer_standground"), "Tell archer to standground", params);
	}
	else
	{
		standground = false;
		params.write_bool(standground);
		caller.CreateGenericButton("$start_archer$", Vec2f(0, 0), this,  this.getCommandID("allow_flee"), "Allow archer to flee if needed", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool standground = false;
    if (cmd == this.getCommandID("archer_standground"))
    {	
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    }
    else if (cmd == this.getCommandID("allow_flee"))
    {
    	standground = params.read_bool();
    	this.set_bool("standground", standground);
    }
}