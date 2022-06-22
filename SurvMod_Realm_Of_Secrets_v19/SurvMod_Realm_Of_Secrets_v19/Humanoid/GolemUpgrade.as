
#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("upgrade");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(this.getDistanceTo(caller) < 24 && this.get_u8("tors_type") == BodyType::Wood)caller.CreateGenericButton(12, Vec2f(0,-8), this, this.getCommandID("upgrade"), "Upgrade with 100 stone.", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.hasBlob("mat_stone", 100)){
				caller.TakeBlob("mat_stone", 100);
				if(this.get_u8("tors_type") == BodyType::Wood)this.set_u8("tors_type", BodyType::Golem);
				if(this.get_u8("head_type") == BodyType::Wood)this.set_u8("head_type", BodyType::Golem);
				if(this.get_u8("marm_type") == BodyType::Wood)this.set_u8("marm_type", BodyType::Golem);
				if(this.get_u8("sarm_type") == BodyType::Wood)this.set_u8("sarm_type", BodyType::Golem);
				if(this.get_u8("fleg_type") == BodyType::Wood)this.set_u8("fleg_type", BodyType::Golem);
				if(this.get_u8("bleg_type") == BodyType::Wood)this.set_u8("bleg_type", BodyType::Golem);
				
				this.set_u16("sarm_equip",Equipment::Shield);
				this.set_u16("sarm_equip_type",1);
				this.set_u16("sarm_default",Equipment::Shield);
				this.set_u16("sarm_default_type",1);
			}
		}
	}
}