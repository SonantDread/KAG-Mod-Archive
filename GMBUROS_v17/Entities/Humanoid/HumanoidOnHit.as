
#include "Hitters.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";
#include "Health.as";
#include "ParticleSparks.as";
#include "ClanCommon.as";
#include "HumanoidStun.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(damage <= 0.0f)return damage;
	
	///Zombies deal bite damage, so this prevents them from destroying corpses so they can spread.
	if (customData == Hitters::bite && !this.hasTag("alive") && !this.hasTag("animated") && hitterBlob.getName() == "humanoid"){
		this.Tag("living_dead");
		return 0;
	}

	///Limb and equipment info
	LimbInfo@ limbs;
	EquipmentInfo@ equip;
	if (!this.get("limbInfo", @limbs) || !this.get("equipInfo", @equip))return damage/4.0f;

	///Angles
	Vec2f vec = worldPoint - this.getPosition();
	f32 angle = vec.Angle();
	f32 aimangle = getAimAngle(this);
	
	///Determine hit location
	bool HeadHit = false;
	bool TorsoHit = false;
	bool FrontLegHit = false;
	bool BackLegHit = false;
	bool MainHit = false;
	bool SubHit = false;
	
	f32 DamageSpread = 1.0f; //For when multiple limbs are hit
	
	if(angle >= 70.0f && angle <= 110.0f){ //Headhit
		if(canHitLimb(this, LimbSlot::Head))HeadHit = true;
		else TorsoHit = true;
		//print("Head");
	} else
	if(angle >= 210.0f && angle <= 330.0f){ //Legs hit
		if(canHitLimb(this, LimbSlot::FrontLeg) && canHitLimb(this, LimbSlot::BackLeg)){
			if(damageIsPierce(customData)){
				if(XORRandom(2) == 0)FrontLegHit = true;
				else BackLegHit = true;
			} else {
				FrontLegHit = true;
				BackLegHit = true;
				DamageSpread = 0.5f;
			}
		} else
		if(canHitLimb(this, LimbSlot::FrontLeg)){
			FrontLegHit = true;
		} else
		if(canHitLimb(this, LimbSlot::BackLeg)){
			BackLegHit = true;
		} else {
			TorsoHit = true;
		}
		//print("Legs");
	} else { //Torso hit
		//print("Torso");
		if(damageIsPierce(customData)){
			if(XORRandom(2) == 0)TorsoHit = true;
			else {
				if(XORRandom(2) == 0)MainHit = true;
				else SubHit = true;
			}
			if(!canHitLimb(this, LimbSlot::MainArm) && MainHit){
				MainHit = false;
				TorsoHit = true;
			}
			if(!canHitLimb(this, LimbSlot::SubArm) && SubHit){
				SubHit = false;
				TorsoHit = true;
			}
		} else {
			int HitSide = 0;
			f32 def = 0;
			
			if(isLimbMovable(this,LimbSlot::SubArm) && canHitLimb(this, LimbSlot::SubArm)){
				if(equip.Torso > Equipment::None)def += getEquipmentArmour(equip.Torso,equip.TorsoType);
				if(equip.SubHand > Equipment::None)def += getEquipmentArmour(equip.SubHand,equip.SubHandType);
				HitSide = -1;
			}
			
			if(isLimbMovable(this,LimbSlot::MainArm) && canHitLimb(this, LimbSlot::MainArm)){
				f32 td = 0.0f;
				if(equip.Torso > Equipment::None)td += getEquipmentArmour(equip.Torso,equip.TorsoType);
				if(equip.MainHand > Equipment::None)td += getEquipmentArmour(equip.MainHand,equip.MainHandType);
				if(td > def || HitSide == 0)HitSide = 1;
			}
			
			if(HitSide == 0){ //Hit torso if arms don't work
				TorsoHit = true;
			}
			if(HitSide == -1){
				SubHit = true;
				if(equip.Torso > Equipment::None && equip.SubHand != Equipment::Shield){ //If armour will block some, spread out the damage to torso if we don't have a shield
					TorsoHit = true;
					DamageSpread = 0.5f;
				}
			}
			if(HitSide == 1){
				MainHit = true;
				if(equip.Torso > Equipment::None && equip.MainHand != Equipment::Shield){ //If armour will block some, spread out the damage to torso if we don't have a shield
					TorsoHit = true;
					DamageSpread = 0.5f;
				}
			}
		}
	}
	
	///Override hit locations
	
	bool ArmourHit = true;
	
	if(customData == Hitters::fall){
		HeadHit = false;
		TorsoHit = false;
		FrontLegHit = false;
		BackLegHit = false;
		MainHit = false;
		SubHit = false;
		
		if(canHitLimb(this, LimbSlot::FrontLeg) && canHitLimb(this, LimbSlot::BackLeg)){
			FrontLegHit = true;
			BackLegHit = true;
			DamageSpread = 0.5f;
		} else
		if(canHitLimb(this, LimbSlot::FrontLeg)){
			FrontLegHit = true;
		} else
		if(canHitLimb(this, LimbSlot::BackLeg)){
			BackLegHit = true;
		} else {
			TorsoHit = true;
		}
	}
	
	if(customData == Hitters::water){
		HeadHit = true;
		TorsoHit = true;
		FrontLegHit = true;
		BackLegHit = true;
		MainHit = true;
		SubHit = true;
		ArmourHit = false;
	}
	
	if (customData == Hitters::burn || customData == Hitters::fire){
		if(!this.hasTag("fire_immune")){
			HeadHit = true;
			TorsoHit = true;
			FrontLegHit = true;
			BackLegHit = true;
			MainHit = true;
			SubHit = true;
			ArmourHit = false;
			//DamageSpread = 0.25f;
		} else {
			this.Untag("fire_immune");
			return 0.0f;
		}
	}
	
	if (isExplosionHitter(customData)){
		HeadHit = false;
		TorsoHit = true;
		FrontLegHit = true;
		BackLegHit = true;
		MainHit = true;
		SubHit = true;
		DamageSpread = 1.0f;
	}
	
	if (customData == Hitters::drown)
	{
		HeadHit = (limbs.HeadHealth > 0) && LimbNeedsAir(limbs.Head,LimbSlot::Head);
		TorsoHit = (limbs.TorsoHealth > 0) && LimbNeedsAir(limbs.Torso,LimbSlot::Torso);
		FrontLegHit = (limbs.FrontLegHealth > 0) && LimbNeedsAir(limbs.FrontLeg,LimbSlot::FrontLeg);
		BackLegHit = (limbs.BackLegHealth > 0) && LimbNeedsAir(limbs.BackLeg,LimbSlot::BackLeg);
		MainHit = (limbs.MainArmHealth > 0) && LimbNeedsAir(limbs.MainArm,LimbSlot::MainArm);
		SubHit = (limbs.SubArmHealth > 0) && LimbNeedsAir(limbs.SubArm,LimbSlot::SubArm);
		ArmourHit = false;
		DamageSpread = 1.0f;
	}

	///Do hits
	bool dink = false;
	f32 resultDamage = 0.0f;

	if(HeadHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit)if(equip.Head > Equipment::None)defense += getEquipmentArmour(equip.Head,equip.HeadType);
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);
		
		if(!dink)CreateHitEffect(this, limbs.Head, worldPoint, dmg, customData);
		else CreateDinkEffect(this, equip.Head, worldPoint, dmg, customData);
		hitLimb(this,LimbSlot::Head, dmg, customData);
		resultDamage += dmg;
	}
	if(TorsoHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit)if(equip.Torso > Equipment::None)defense += getEquipmentArmour(equip.Torso,equip.TorsoType);
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);
		
		if(!dink)CreateHitEffect(this, limbs.Torso, worldPoint, dmg, customData);
		else CreateDinkEffect(this, equip.Torso, worldPoint, dmg, customData);
		hitLimb(this,LimbSlot::Torso, dmg, customData);
		resultDamage += dmg;
	}
	if(FrontLegHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit){
			if(equip.Torso > Equipment::None)defense += getEquipmentArmour(equip.Torso,equip.TorsoType);
			if(equip.Feet > Equipment::None)defense += getEquipmentArmour(equip.Feet,0);
		}
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);
		
		if(!dink)CreateHitEffect(this, limbs.FrontLeg, worldPoint, dmg, customData);
		else CreateDinkEffect(this, equip.Feet, worldPoint, dmg, customData);
		hitLimb(this,LimbSlot::FrontLeg, dmg, customData);
		resultDamage += dmg;
	}
	if(BackLegHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit){
			if(equip.Torso > Equipment::None)defense += getEquipmentArmour(equip.Torso,equip.TorsoType);
			if(equip.Feet > Equipment::None)defense += getEquipmentArmour(equip.Feet,0);
		}
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);
		
		if(!dink)CreateHitEffect(this, limbs.BackLeg, worldPoint, dmg, customData);
		else CreateDinkEffect(this, equip.Feet, worldPoint, dmg, customData);
		hitLimb(this,LimbSlot::BackLeg, dmg, customData);
		resultDamage += dmg;
	}
	if(MainHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit){
			if(equip.Torso > Equipment::None)defense += getEquipmentArmour(equip.Torso,equip.TorsoType);
			if(equip.MainHand > Equipment::None)defense += getEquipmentArmour(equip.MainHand,equip.MainHandType);
		}
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);

		if(!dink)CreateHitEffect(this, limbs.MainArm, worldPoint, dmg, customData);
		else {
			CreateDinkEffect(this, equip.Torso, worldPoint, dmg, customData);
			CreateDinkEffect(this, equip.MainHand, worldPoint, dmg, customData);
		}
		hitLimb(this,LimbSlot::MainArm, dmg, customData);
		resultDamage += dmg;
	}
	if(SubHit && damage > 0.0f){
		f32 defense = 0.0f;
		f32 dmg = damage;
		if(ArmourHit){
			if(equip.Torso > Equipment::None)defense += getEquipmentArmour(equip.Torso,equip.TorsoType);
			if(equip.SubHand > Equipment::None)defense += getEquipmentArmour(equip.SubHand,equip.SubHandType);
		}
		
		if(damageIsPierce(customData))if(dmg > defense)defense = 0.0f;	///Pierce either pierces or doesn't
		if(damageIsBlunt(customData))defense = (defense/dmg); ///Blunt heavily ignores armour
		
		dink = (dmg < defense);
		dmg = dmg-defense;
		dmg = Maths::Max(dmg*DamageSpread,0.25f);

		if(!dink)CreateHitEffect(this, limbs.SubArm, worldPoint, dmg, customData);
		else {
			CreateDinkEffect(this, equip.Torso, worldPoint, dmg, customData);
			CreateDinkEffect(this, equip.SubHand, worldPoint, dmg, customData);
		}
		hitLimb(this,LimbSlot::SubArm, dmg, customData);
		resultDamage += dmg;
	}
	
	if(hitterBlob !is this && hitterBlob !is null)
	if(this.getPlayer() !is null){
		int CID = getBlobClan(hitterBlob);
		if(CID > 0)
		if(CID != getBlobClan(this)){
			CBlob @clan = getClan(CID);
			if(clan !is null)clan.add_u32("Bloodlust",resultDamage*8.0f);
		}
	}
	
	if (this.isMyPlayer() && resultDamage > 0){
        SetScreenFlash( 90, 120, 0, 0 );
        ShakeScreen( 9, 2, this.getPosition() );
    }
	
	doDamageStun(this, resultDamage, customData);
	
	return 0.0f;
}

void CreateHitEffect( CBlob@ this, int LimbType, Vec2f worldPoint, f32 damage, u8 customData ){
	
	if(customData == Hitters::drown)return;
	if(customData == Hitters::burn || customData == Hitters::fire)return;
	
	Vec2f vec = this.getPosition()-worldPoint;
	f32 angle = vec.Angle();
	
	if(LimbType == BodyType::Golem){
		this.getSprite().PlaySound("dig_stone", Maths::Min(1.25f, Maths::Max(0.5f, damage)));

		for(f32 i = 0;i < damage;i++)
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
						2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	
	if(LimbType == BodyType::Wood){
		this.getSprite().PlayRandomSound("/WoodHit", Maths::Min(1.25f, Maths::Max(0.5f, damage)));

		for(f32 i = 0;i < damage;i++)
		makeGibParticle("/GenericGibs", worldPoint, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
						1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	
	if(isFlesh(LimbType)){
		f32 capped_damage = Maths::Min(damage, 2.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case Hitters::sword:
				Sound::Play("SwordKill", this.getPosition());
				break;

			case Hitters::stab:
				if (this.getHealth() > 0.0f && damage > 2.0f)
				{
					this.Tag("cutthroat");
				}
				break;

			default:
				if (customData != Hitters::bite)
					Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;

		if (showblood)
		{
			if (capped_damage > 1.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 0.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				for (f32 count = 0.0f ; count < capped_damage + 0.6f; count += 0.1f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * capped_damage * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * capped_damage;
					ParticleBlood(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0));
					ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));
				}
			}
		}
	}
}

void CreateDinkEffect( CBlob@ this, int Armour, Vec2f worldPoint, f32 damage, u8 customData ){
	
	if(customData == Hitters::drown)return;
	if(customData == Hitters::burn)return;
	if(customData == Hitters::fire)return;
	
	Vec2f vec = this.getPosition()-worldPoint;
	f32 angle = vec.Angle();
	
	if(Armour == Equipment::KnightArmour || Armour == Equipment::Shield){
		Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);

		sparks(worldPoint, angle, 0.1f);
	}
	
	if(Armour == Equipment::Shirt){
		Sound::Play("thud.ogg", worldPoint);
	}
}