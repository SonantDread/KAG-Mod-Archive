#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"
#include "Knocked.as";

void onTick(CBlob @this){ //hack n slash
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	for(int i = 0;i < 2;i++){
		f32 knife = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
		
		if(i != 0){
			knife = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			damage = getEquipmentDamage(equip.SubHand,equip.SubHandType);
			speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm)*getEquipmentSpeed(equip.SubHand,equip.SubHandType,getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm));
			if(equip.SubHand != Equipment::Knife || !canLimbAttack(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Knife || !canLimbAttack(this,LimbSlot::MainArm))continue;
		}
		
		
		if(knife >= 0){
			if(holding){
				if(knife <= 30 && knife+speed > 30){
					//Sound::Play("AnimeSword.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.7f);
					DoAttack(this,damage*0.5f,-getAimAngle(this),45);
					knife = -50;
				}
				if(knife <= 15 && knife+speed > 15)Sound::Play("SwordSheath.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.1f);
				knife = knife+speed;
			} else 
			if(knife > 0){
				DoAttack(this,damage,-getAimAngle(this),45);
				knife = -15;
			}
		} else {
			if(knife >= -15){
				knife += speed;
				if(knife >= 0)knife = 0;
			} else
			if(knife >= -50){
				knife += speed;
				if(knife >= -35)knife = 30;
			}
		}
		
		if(i == 0)equip.mainSwingTimer = knife;
		else equip.subSwingTimer = knife;
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (aimangle < 0.0f)aimangle += 360.0f;

	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = this.getPosition() - thinghy * 6.0f + this.getVelocity();

	f32 attack_distance = Maths::Min(14 + (2.5f * this.getShape().vellen),52);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	
	Sound::Play("/SwordSlash", this.getPosition());

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if(map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null) // blob
			if(!b.hasTag("building")){
				if(isServer()){
					const bool large = !b.isAttached() && b.doesCollideWithBlob(this) && b.isCollidable();//big things block attacks

					if (!canHit(this, b)){
						if(large)break;
						continue;
					}

					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::stab, true);  // server_Hit() is server-side only
					
					// end hitting if we hit something solid, don't if its flesh
					if (large)break;
				}
			}
		}
	}
}