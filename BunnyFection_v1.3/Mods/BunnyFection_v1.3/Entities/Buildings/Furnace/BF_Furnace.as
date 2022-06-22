// BF_Workbench script

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";
#include "MakeMat.as";
void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("Smelt");
    // ICONS
    AddIconToken( "$custom_carrot$", "BF_CarrotCooked.png", Vec2f(8,16), 6);
    AddIconToken( "$custom_fishy$", "Fishy.png", Vec2f(16,16), 8);  
	AddIconToken( "$custom_piggy$", "BF_PigCooked.png", Vec2f(16,16), 8); 
    // SHOP
	this.inventoryButtonPos = Vec2f(-20.0f, 1.0f);
	this.set_bool( "Smelting" , false);
	this.set_u8("Smelt_time", 0);
	this.set_u8("Smelt_bar", 0);
	this.getCurrentScript().tickFrequency = 30;
	this.SetLightRadius( 50.0f );
	this.SetLightColor( SColor(255, 255, 240, 171 ) );
	this.SetLight(false);
	this.set_string("blob tag", "ore");
}
void onTick( CBlob@ this )
{
	if(this.get_bool( "Smelting") && this.get_u8("Smelt_time") <= 30)
	{
		TickSmelt(this);
		
	}
	if(this.get_u8("Smelt_time") >= 30)
	{
	
		MakeMat(this, this.getPosition(), findBar(this.get_u8("Smelt_bar")), 1);
		this.set_u8("Smelt_time", 0);
		this.set_bool( "Smelting" , false);
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("default");
		this.SetLight(false);
	}
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	print("button call");
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ Fire_on = caller.CreateGenericButton( "$mat_wood$", Vec2f(10.0f,1.0f), this, this.getCommandID("Smelt"), "Smelt", params);
	if(caller.getDistanceTo(this) < 20.0f && HasOre(this) && !this.get_bool( "Smelting"))
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
    if(cmd == this.getCommandID("Smelt") && !this.get_bool( "Smelting") && caller != null)
	{
		if(this.getBlobCount("bf_angelite") >= 10)
		{
		this.TakeBlob("bf_angelite", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 0);
		this.set_bool( "Smelting" , true);
		}
		else if(this.getBlobCount("bf_cobalt") >= 10)
		{
		this.TakeBlob("bf_cobalt", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 1);
		this.set_bool( "Smelting" , true);
		}
		else if(this.getBlobCount("bf_scandium") >= 10)
		{
		this.TakeBlob("bf_scandium", 10);
		this.TakeBlob("bf_coal", 5);
		this.set_u8("Smelt_bar", 2);
		this.set_bool( "Smelting" , true);
		}
		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("fire");
		this.SetLight(true);
	}
}
bool HasOre(CBlob@ this)
{
	return (this.getBlobCount("bf_cobalt") >= 10 || this.getBlobCount("bf_scandium") >= 10 || this.getBlobCount("bf_angelite") >= 10) && this.getBlobCount("bf_coal") >= 5;
}
void TickSmelt( CBlob@ this )
{
    this.set_u8("Smelt_time", this.get_u8("Smelt_time") + 1);
	
}
string findBar(u8 bar)
{	
	if(bar == 0)
	{
		return "bf_angelitemedallions";
	}
	else if(bar == 1)
	{
		return "bf_cobaltbar";
	}
	else if(bar == 2)
	{
		return "bf_scandiumbar";
	}
	else
	{
		return "";
	}
}

