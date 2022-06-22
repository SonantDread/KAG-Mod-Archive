#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"
#include "Knocked.as";

void onTick(CBlob @this){ //Chop chop
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	for(int i = 0;i < 2;i++){
		f32 axe = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
		
		if(i != 0){
			axe = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			damage = getEquipmentDamage(equip.SubHand,equip.SubHandType)*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm)*getEquipmentSpeed(equip.SubHand,equip.SubHandType,getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm));
			if(equip.SubHand != Equipment::Axe || !canLimbAttack(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Axe || !canLimbAttack(this,LimbSlot::MainArm))continue;
		}
		
		
		if(holding && axe >= 0){
			if(axe <= 29 && axe+speed > 29)Sound::Play("AnimeSword.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.7f);
			if(axe <= 10 && axe+speed > 10)Sound::Play("ChargeEnough.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.1f);
			if(axe > 55){
				Sound::Play("/Stun", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
				SetKnocked(this, 15);
				axe = 0;
			}
			if(axe < 31)axe = Maths::Min(axe+speed,31);
			else axe += -1.0f+XORRandom(4);
		} else {
			if(axe > 10){
				DoAttack(this,Maths::Min(axe,30.0f)/30.0f*damage,-getAimAngle(this),60+axe);
				axe = -1;
			} else 
			if(axe < 0){
				if(axe > -60)axe -= 12;
				else axe = 0;
			} else {
				axe = 0;
			}
		}
		
		if(i == 0)equip.mainSwingTimer = axe;
		else equip.subSwingTimer = axe;
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (aimangle < 0.0f)aimangle += 360.0f;

	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = this.getPosition() - thinghy * 6.0f + this.getVelocity();

	f32 attack_distance = Maths::Min(10 + (2.5f * this.getShape().vellen),52);

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
			{
				if(isServer()){
					const bool large = !b.isAttached() && b.doesCollideWithBlob(this) && b.isCollidable();//big things block attacks

					if (!canHit(this, b)){
						if(large)break;
						continue;
					}

					Vec2f velocity = b.getPosition() - pos;
					Material::fromBlob(this, b, damage);
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::saw, true);  // server_Hit() is server-side only
					
					
					// end hitting if we hit something solid, don't if its flesh
					if (large)break;
				}
			} else { //Hit map
				if(isServer())
				if(map.isTileWood(hi.tile)){
					Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
					Vec2f offset = (tpos - this.getPosition());
					
					f32 dif = Maths::Abs(getAimAngle(this) - offset.Angle());
					if (dif > 180)dif -= 360;
					dif = Maths::Abs(dif);
					
					if (dif < 20.0f){
						//dont dig through no build zones
						bool canhit = map.getSectorAtPosition(tpos, "no build") is null;

						if (canhit){
							this.server_HitMap(hi.hitpos, Vec2f(0,0), 1.0f, Hitters::saw);
						}
						break;
					}
				}
			}
		}
	}
}