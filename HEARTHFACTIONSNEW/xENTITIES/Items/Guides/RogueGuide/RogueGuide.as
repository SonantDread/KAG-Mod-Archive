void onInit(CBlob@ this)
{
	this.set_string("required class", "rogue");
	this.set_Vec2f("class offset", Vec2f(0, 0));
	
	this.Tag("kill on use");
	this.Tag("dangerous");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	bool canChangeClass = caller.getConfig() != "rogue";

	if(canChangeClass)
	{
		this.Untag("class button disabled");
	}
	else
	{
		this.Tag("class button disabled");
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	this.server_Die();
}