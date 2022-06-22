
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("access_inv");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(this.getPlayer() is null && this.getDistanceTo(caller) < 24 && !this.isAttached())caller.CreateGenericButton(13, Vec2f(0,0), this, this.getCommandID("access_inv"), "Equipment", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("access_inv"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.getPlayer() is getLocalPlayer()){
				this.CreateInventoryMenu(Vec2f(getScreenWidth()/2.0f,getScreenHeight()/2.0f));
				createEquipMenu(this, caller, Vec2f(getScreenWidth()/2.0f,getScreenHeight()/2.0f-160));
			}
		}
	}
}