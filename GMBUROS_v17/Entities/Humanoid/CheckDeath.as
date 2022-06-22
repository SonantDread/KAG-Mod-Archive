#include "Hitters.as"
#include "LimbsCommon.as"
#include "EquipmentCommon.as"
#include "Health.as"
#include "AfterLife.as"
#include "CommonParticles.as"

f32 getGibHealth(CBlob@ this)
{
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return 0.0f;
	
	if(isFlesh(limbs.Torso))return -5.0f;
	
	return 0.0f;
}

void onInit(CBlob@ this)
{
	this.set_f32("hit dmg modifier", 0.0f);
	this.getCurrentScript().tickFrequency = 28;
	
	if(XORRandom(5) == 0)
	this.Tag("living_dead");
	
	this.set_u32("death time", getGameTime());
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
		u32 VANISH_BODY_SECS = 60*getTicksASecond();
		
		if(this.hasTag("cannibal"))VANISH_BODY_SECS = 10*getTicksASecond();
	
		f32 rotMod = 2.0f;
		if(this.isInWater())rotMod = 1.0f;
		//rot
		if (this.get_u32("death time") + VANISH_BODY_SECS*rotMod < getGameTime() && this.getInventoryName() != "Rotting Corpse")
		{
			
			LimbInfo@ limbs;
			if(this.get("limbInfo", @limbs)){
				if(isLivingFlesh(limbs.Head))morphLimb(this,LimbSlot::Head, BodyType::Zombie);
				if(isLivingFlesh(limbs.Torso)){
					morphLimb(this,LimbSlot::Torso, BodyType::Zombie);
					this.setInventoryName("Rotting Corpse");
				}
				if(isLivingFlesh(limbs.MainArm))morphLimb(this,LimbSlot::MainArm, BodyType::Zombie);
				if(isLivingFlesh(limbs.SubArm))morphLimb(this,LimbSlot::SubArm, BodyType::Zombie);
				if(isLivingFlesh(limbs.FrontLeg))morphLimb(this,LimbSlot::FrontLeg, BodyType::Zombie);
				if(isLivingFlesh(limbs.BackLeg))morphLimb(this,LimbSlot::BackLeg, BodyType::Zombie);
			}
			this.set_u32("death time",getGameTime());
		}
		
		//zombify
		if(!this.hasTag("animated"))
		if(this.get_u32("death time") + VANISH_BODY_SECS*2 < getGameTime() && this.hasTag("living_dead"))
		{
			
			/////////// Should be turned into a 'make zombie' scripts
			
			this.Tag("spirit_infested");
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
				this.Sync("spirit_infested",true);
				this.server_setTeamNum(10);
			}
			
			
			///////////
			
			if(this.getPlayer() is null){
				equipType(this, EquipSlot::Main, Equipment::ZombieHands, 0);
				equipType(this, EquipSlot::Sub, Equipment::ZombieHands, 0);
			}
			
			this.Untag("living_dead");
		}
	} else {
		this.set_u32("death time", getGameTime());
	}
}

void onDie(CBlob@ this)
{
	this.Tag("destroyed");
	Kill(this,null,Hitters::nothing);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;//(!this.hasTag("alive") && !this.hasTag("animated") && this.getInventory().getItemsCount() > 0);
}

