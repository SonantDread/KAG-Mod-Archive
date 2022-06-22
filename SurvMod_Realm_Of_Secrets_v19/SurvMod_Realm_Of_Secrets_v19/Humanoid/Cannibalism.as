
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "Health.as";

void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	this.set_u8("cannibalism",0);
	this.set_u8("cannibalism_max",XORRandom(6)+1);
	
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	if(this.hasTag("cannibal") && isServer() && getHealth(this) > 0){
		if(getHealth(this) < 4)this.server_Hit(this, this.getPosition(), Vec2f(0,0),0.25f, Hitters::nothing, true);
		else server_Heal(this,-0.25f);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(this.getDistanceTo(caller) < 24 && isLivingFlesh(this.get_u8("tors_type")) && isLivingFlesh(caller.get_u8("tors_type")) && !this.hasTag("cannibal") && !this.hasTag("alive")  && !this.hasTag("animated"))
	caller.CreateGenericButton(22, Vec2f(0,-8), this, this.getCommandID("consume"), "Consume this body to gain 1 max health", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("consume"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			caller.add_u8("cannibalism",1);
			AddMaxHealth(caller,"GhoulHeartHUD.png",caller.get_u8("cannibalism"));
			server_Heal(caller,1.0f);
			
			if(caller.get_u8("cannibalism") >= this.get_u8("cannibalism_max") && isLivingFlesh(caller.get_u8("tors_type"))){
				if(caller.get_u8("tors_type") == BodyType::Flesh)caller.set_u8("tors_type", BodyType::Cannibal);
				if(caller.get_u8("head_type") == BodyType::Flesh)caller.set_u8("head_type", BodyType::Cannibal);
				if(caller.get_u8("marm_type") == BodyType::Flesh)caller.set_u8("marm_type", BodyType::Cannibal);
				if(caller.get_u8("sarm_type") == BodyType::Flesh)caller.set_u8("sarm_type", BodyType::Cannibal);
				if(caller.get_u8("fleg_type") == BodyType::Flesh)caller.set_u8("fleg_type", BodyType::Cannibal);
				if(caller.get_u8("bleg_type") == BodyType::Flesh)caller.set_u8("bleg_type", BodyType::Cannibal);
				caller.Tag("cannibal");
				if(isServer()){
					caller.server_setTeamNum(11);
					this.server_SetHealth(getHealthMax(this)*0.5);
				}
			}
			
			if(isServer())this.server_Die();
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if(isFlesh(hitBlob.get_u8("tors_type")) && !hitBlob.hasTag("alive")  && !hitBlob.hasTag("animated")){
		if(this.hasTag("cannibal") && !hitBlob.hasTag("cannibal")){
			this.add_u8("cannibalism",1);
			AddMaxHealth(this,"GhoulHeartHUD.png",this.get_u8("cannibalism"));
			server_Heal(this,4.0f);
			
			if(isServer())hitBlob.server_Die();
		}
	}
}