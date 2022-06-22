
#include "Hitters.as";
#include "Knocked.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "HumanoidAnimCommon.as";
#include "Health.as";
#include "HandleDeath.as";

void onInit(CBlob@ this)
{
	AddMaxHealth(this,"StoneHeartHUD.png",0.0f);
	this.set_f32("natural_health",0.0f);
	
	int body = BodyType::Flesh;
	
	this.set_u8("head_type", body);
	this.set_u8("tors_type", body);
	this.set_u8("marm_type", body);
	this.set_u8("sarm_type", body);
	this.set_u8("fleg_type", body);
	this.set_u8("bleg_type", body);
	
	this.set_u8("fore_eye", EyeType::Normal);
	this.set_u8("back_eye", EyeType::Normal);
	
	this.set_u8("heart", HeartType::Beating);
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("bald"))
	if(this.get_u8("head_type") == BodyType::Golem || this.get_u8("head_type") == BodyType::Wood){
		this.Tag("bald");
	}
	
	if(getGameTime() % 129 == 0){
		int NH = getLimbHealth(this.get_u8("tors_type"));
		if(this.get_f32("natural_health") != NH){
			AddMaxHealth(this,"StoneHeartHUD.png",NH);
			this.set_f32("natural_health",NH);
		}
	}
	
	if (this.get_u8("heart") == HeartType::Beating)
	{
		if(!isLimbUsable(this,this.get_u8("head_type"))){
			this.set_u8("heart",HeartType::Stopped);
		}
	}
	if (this.get_u8("heart") != HeartType::Beating && this.hasTag("alive"))
	{
		Kill(this,null,Hitters::nothing);
	}
	
	if(getGameTime() % 30 == 5 && isServer()){
		if(this.exists("animated"))this.Sync("animated",true);
		if(!this.hasTag("alive"))this.Sync("alive",true);
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(damage >= 1.5f || (damage >= 1.0f && XORRandom(3) == 0))
	if(this.get_u8("tors_type") == BodyType::Zombie){
		
		int i = 0;
		bool GotIt = false;
		while(i < 10 && !GotIt){
			i += 1;
			GotIt = true;
			if(this.get_u8("head_type") != BodyType::None && XORRandom(4) == 0)this.set_u8("head_type", BodyType::None);
			else if(this.get_u8("bleg_type") != BodyType::None && XORRandom(4) == 0)this.set_u8("bleg_type", BodyType::None);
			else if(this.get_u8("sarm_type") != BodyType::None && XORRandom(4) == 0)this.set_u8("sarm_type", BodyType::None);
			else if(this.get_u8("fleg_type") != BodyType::None && XORRandom(4) == 0)this.set_u8("fleg_type", BodyType::None);
			else if(this.get_u8("marm_type") != BodyType::None && XORRandom(4) == 0)this.set_u8("marm_type", BodyType::None);
			else GotIt = false;
		}
		if(!GotIt){
			if(isServer())this.server_Die();
		} else {
			reloadSpriteBody(this.getSprite(),this);
		}
	
	}

	if (customData == Hitters::bite && !this.hasTag("alive") && !this.hasTag("animated") && hitterBlob.getName() == "humanoid")
	{
		return 0;
	}
	
	return damage;
}