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
		f32 sword = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
		
		if(i != 0){
			sword = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			damage = getEquipmentDamage(equip.SubHand,equip.SubHandType)*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm)*getEquipmentSpeed(equip.SubHand,equip.SubHandType,getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm));
			if(equip.SubHand != Equipment::Sword || !canLimbAttack(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Sword || !canLimbAttack(this,LimbSlot::MainArm))continue;
		}
		
		
		if(sword >= 0){
			if(holding){
				if(sword <= 38 && sword+speed > 38)Sound::Play("AnimeSword.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.7f);
				if(sword <= 15 && sword+speed > 15)Sound::Play("SwordSheath.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.1f);
				if(sword < 38)sword = Maths::Min(sword+speed,38);
				else {
					if(sword > 63){
						Sound::Play("/Stun", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
						SetKnocked(this, 15);
						sword = 0;
					}
					sword++;
				}
			} else 
			if(sword > 0){
				if(sword < 15){
					DoAttack(this,0.5f*damage,-getAimAngle(this),45, true);
					sword = -15;
				} else
				if(sword < 38){
					DoAttack(this,damage,-getAimAngle(this),90, false);
					sword = -60;
				} else {
					DoAttack(this,damage,-getAimAngle(this),90, false);
					sword = -90;
				}
			}
		} else {
			if(sword >= -15){
				sword++;
				if(sword >= 0)sword = 0;
			} else
			if(sword >= -60){
				sword++;
				if(sword >= -50)sword = 0;
			} else
			if(sword >= -90){
				sword++;
				if(sword >= -70)sword = 0;
				if(holding && sword >= -80){
					DoAttack(this,damage,-getAimAngle(this),90, false);
					sword = -60;
				}
			}
		}
		
		if(i == 0)equip.mainSwingTimer = sword;
		else equip.subSwingTimer = sword;
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, bool Stab)
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
			{
				if(isServer() && !b.hasTag("building")){
					const bool large = !b.isAttached() && b.doesCollideWithBlob(this) && b.isCollidable();//big things block attacks

					if (!canHit(this, b)){
						if(large)break;
						continue;
					}

					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::sword, true);  // server_Hit() is server-side only
					
					// end hitting if we hit something solid, don't if its flesh
					if (large)break;
				}
			} else 
			if(!Stab){ //Hit map
				if(isServer())
				if(map.isTileWood(hi.tile) || map.isTileGroundStuff(hi.tile)){
					Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
					Vec2f offset = (tpos - this.getPosition());
					
					f32 dif = Maths::Abs(getAimAngle(this) - offset.Angle());
					if (dif > 180)dif -= 360;
					dif = Maths::Abs(dif);
					
					if (dif < 20.0f){
						//dont dig through no build zones
						bool canhit = map.getSectorAtPosition(tpos, "no build") is null;

						if (canhit){
							this.server_HitMap(hi.hitpos, Vec2f(0,0), 1.0f, Hitters::sword);
						}
						break;
					}
				}
			}
		}
	}
}