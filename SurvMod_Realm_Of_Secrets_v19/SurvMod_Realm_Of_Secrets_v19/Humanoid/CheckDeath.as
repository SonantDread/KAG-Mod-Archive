#include "Hitters.as"
#include "LimbsCommon.as"
#include "EquipmentCommon.as"
#include "Health.as"
#include "AfterLife.as"
#include "CommonParticles.as"

f32 getGibHealth(CBlob@ this)
{
	if(isFlesh(this.get_u8("tors_type")))return -5.0f;
	
	return 0.0f;
}

void onInit(CBlob@ this)
{
	this.set_f32("hit dmg modifier", 0.0f);
	this.getCurrentScript().tickFrequency = 28;
	
	//if(XORRandom(4) == 0)
		this.Tag("living_dead");
	
	this.set_u32("death time", getGameTime());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.Damage(damage, hitterBlob);
	if (this.getHealth() <= getGibHealth(this))
	{
		if(!this.hasTag("gibbed")){
			if(this.get_u8("tors_type") == BodyType::Golem){
			for(int i = 0;i < 10;i++)makeGibParticle("GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(this.get_u8("tors_type") == BodyType::Wood){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(isLivingFlesh(this.get_u8("tors_type"))){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),4, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(this.get_u8("tors_type") == BodyType::Zombie){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),6, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			
			this.Tag("gibbed");
		}
		
		this.server_Die();
	}
	
	// make sure this script is at the end of onHit scripts for it gets the final health
	// Getting to 0 hp causes a heart attack and stops animation
	if (this.getHealth() <= 0.0f)
	{
		if(this.hasTag("animated")){
			this.Untag("animated");
			Kill(this,hitterBlob,customData);
		}
		if (this.get_u8("heart") == HeartType::Beating)
		{
			this.set_u8("heart",HeartType::Stopped);
		}
	}
	
	if (this.get_u8("heart") != HeartType::Beating && this.hasTag("alive"))
	{
		Kill(this,hitterBlob,Hitters::nothing);
	}

	return 0.0f; //done, we've used all the damage
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("alive") && !this.hasTag("animated")){
	
		CBlob @carried = this.getCarriedBlob();
		if (carried !is null)
		{
			carried.server_DetachFromAll();
		}
		
		this.set_f32("hit dmg modifier", 0.5f);
		
		this.getShape().setFriction(0.75f);
		this.getShape().setElasticity(0.2f);
		
		
	
	} else {
		this.set_f32("hit dmg modifier", 0.0f);
		this.getShape().setFriction(0.07f);
		this.getShape().setElasticity(0.0f);
	}
	
	if(!this.hasTag("alive")){
		u32 VANISH_BODY_SECS = 30*getTicksASecond();
		
		if(this.hasTag("cannibal"))VANISH_BODY_SECS = 10*getTicksASecond();
	
		f32 rotMod = 2.0f;
		if(this.isInWater())rotMod = 1.0f;
		//rot
		if (this.get_u32("death time") + VANISH_BODY_SECS*rotMod < getGameTime() && this.getInventoryName() != "Rotting Corpse")
		{
			
			if(isLivingFlesh(this.get_u8("head_type")))morphLimb(this,"head", BodyType::Zombie);
			if(isLivingFlesh(this.get_u8("tors_type"))){
				morphLimb(this,"tors", BodyType::Zombie);
				this.setInventoryName("Rotting Corpse");
			}
			if(isLivingFlesh(this.get_u8("marm_type")))morphLimb(this,"marm", BodyType::Zombie);
			if(isLivingFlesh(this.get_u8("sarm_type")))morphLimb(this,"sarm", BodyType::Zombie);
			if(isLivingFlesh(this.get_u8("fleg_type")))morphLimb(this,"fleg", BodyType::Zombie);
			if(isLivingFlesh(this.get_u8("bleg_type")))morphLimb(this,"bleg", BodyType::Zombie);
			
			this.set_u32("death time",getGameTime());
		}
		
		//zombify
		if(!this.hasTag("animated"))
		if (this.get_u32("death time") + VANISH_BODY_SECS*2 < getGameTime() && this.hasTag("living_dead"))
		{
			
			/////////// Should be turned into a 'make zombie scripts
			
			this.Tag("animated");
			this.Tag("undead");
			if(isServer()){
				this.server_SetHealth(0.0f);
				server_Heal(this,10.0f);
				
				CPlayer @ghost_player = getPlayerByUsername(this.get_string("player_name"));
				if(ghost_player !is null){
					this.set_string("player_name","");
					if(this.getPlayer() !is null)this.Untag("soul_"+this.getPlayer().getUsername());
					if(ghost_player.getBlob() !is null){
						if(ghost_player.getBlob().getName() == "ghost" && ghost_player.getBlob().get_u16("soul_link") == this.getNetworkID()){
							ghost_player.getBlob().server_Die();
							this.server_SetPlayer(ghost_player);
						}
					}
				}
				if(this.getPlayer() is null){
					this.getBrain().server_SetActive(true);
				}
				this.Sync("animated",true);
				this.server_setTeamNum(10);
			}
			
			
			///////////
			
			if(this.getPlayer() is null){
				equipType(this, "marm", Equipment::ZombieHands, 0);
				equipType(this, "sarm", Equipment::ZombieHands, 0);
			} else {
				equipType(this, "marm", Equipment::Sword, 0);
			}
			
			this.Untag("living_dead");
		}
	} else {
		this.set_u32("death time", getGameTime());
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;//(!this.hasTag("alive") && !this.hasTag("animated") && this.getInventory().getItemsCount() > 0);
}

void onDie(CBlob@ this){
	if(isServer())
	for(int i = 0;i < EquipSlots.length;i++){
		if(getEquipmentBlob(this.get_u16(EquipSlots[i]+"_equip"),this.get_u16(EquipSlots[i]+"_equip_type")) != ""){
			server_CreateBlob(getEquipmentBlob(this.get_u16(EquipSlots[i]+"_equip"),this.get_u16(EquipSlots[i]+"_equip_type")),-1,this.getPosition());
		}
	}
}