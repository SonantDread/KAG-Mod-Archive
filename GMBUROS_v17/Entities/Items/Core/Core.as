
#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("upgrade");
	this.addCommandID("infuse");
	
	this.set_u8("level",0);
	this.set_u8("infuse",0);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(caller.getCarriedBlob() !is null){
		if(this.get_u8("infuse") == 0){
			if(caller.getCarriedBlob().getName() == "wisp")caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("infuse"), "Charge with wisp", params);
			if(caller.getCarriedBlob().getName() == "ghost_shard")caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("infuse"), "Charge with shard", params);
		}
	} else {
		if(this.get_u8("level") == 0 && caller.hasBlob("mat_stone", 50))caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with 50 stone", params);
		else if(this.get_u8("level") == 1 && caller.hasBlob("gold_bar", 1))caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with gold bar", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(isServer()){
				if(this.get_u8("level") == 0){
					if(caller.hasBlob("mat_stone", 50)){
						caller.TakeBlob("mat_stone", 50);
						this.set_u8("level",1);
						this.Sync("level",true);
						this.server_SetHealth(this.getInitialHealth()*2.0f);
					}
				} else
				if(this.get_u8("level") == 1){
					if(caller.hasBlob("gold_bar", 1)){
						caller.TakeBlob("gold_bar", 1);
						this.set_u8("level",2);
						this.Sync("level",true);
						this.server_SetHealth(this.getInitialHealth()*3.0f);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("infuse"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(isServer()){
				if(this.get_u8("infuse") == 0 && caller.getCarriedBlob() !is null){
					if(caller.getCarriedBlob().getName() == "wisp"){
						caller.getCarriedBlob().server_Die();
						this.set_u8("infuse",1);
						this.Sync("infuse",true);
						this.set_u16("equip_id",Equipment::LifeCore);
					} else
					if(caller.getCarriedBlob().getName() == "ghost_shard"){
						this.set_string("player_name",caller.getCarriedBlob().get_string("player_name"));
						this.Tag("soul_"+caller.getCarriedBlob().get_string("player_name"));
						this.Sync("player_name",true);
						this.Sync("soul_"+caller.getCarriedBlob().get_string("player_name"),true);
						caller.getCarriedBlob().server_Die();
						this.set_u8("infuse",2);
						this.Sync("infuse",true);
						this.set_u16("equip_id",Equipment::DeathCore);
					}
				}
			}
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();

	blob.inventoryIconFrame = blob.get_u8("level")*3+blob.get_u8("infuse");
	this.SetFrame(blob.inventoryIconFrame);
}

void onDie(CBlob@ this)
{
	if(isServer() && !this.hasTag("used")){
		if(this.get_u8("infuse") == 1){
			CBlob@item = server_CreateBlob("wisp", -1, this.getPosition());

			if (item !is null){
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				item.setVelocity(vel);
			}
		}
	}
}