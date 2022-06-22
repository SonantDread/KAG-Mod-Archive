#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"
#include "CMap.as"

void onTick(CBlob @this){ //STICK POWAAAAAAAAAA
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	
	for(int i = 0;i < 2;i++){
		f32 pole = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
		int Type = equip.MainHandType;
		int DmgType = getEquipmentDamageType(equip.MainHand,equip.MainHandType);
		f32 range = getEquipmentRange(this,LimbSlot::MainArm,equip.MainHand,equip.MainHandType);
		
		if(i != 0){
			Type = equip.SubHandType;
			DmgType = getEquipmentDamageType(equip.SubHand,equip.SubHandType);
			pole = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			damage = getEquipmentDamage(equip.SubHand,equip.SubHandType)*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm)*getEquipmentSpeed(equip.SubHand,equip.SubHandType,getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm));
			range = getEquipmentRange(this,LimbSlot::SubArm,equip.SubHand,equip.SubHandType);
			if(equip.SubHand != Equipment::Pole || !canLimbAttack(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Pole || !canLimbAttack(this,LimbSlot::MainArm))continue;
		}
		
		bool PogoJump = (Type == 0);
		bool HitMap = (Type == 0 || Type == 1);
		
		
		if(holding && (Type != 1 || pole < 20)){
			if(pole > 20)pole = 0;
			pole = Maths::Min(pole+speed,20);
		} else {
			if(pole > 10){
				if(pole < 21){
					DoAttack(this,(f32(pole-10)/10.0f*0.5f+0.5f)*damage,-getAimAngle(this),30,HitMap,PogoJump,DmgType,range);
					pole = 21;
				} else {
					if(pole < 90)pole += 6;
					else pole = 0;
				}
			} else {
				pole = 0;
			}
		}
		
		if(i == 0)equip.mainSwingTimer = pole;
		else equip.subSwingTimer = pole;
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, bool hitMap, bool PogoJump, int DmgType, f32 Range)
{
	if (aimangle < 0.0f)aimangle += 360.0f;

	Vec2f blobPos = this.getPosition();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + this.getVelocity();

	f32 attack_distance = Maths::Min(Range + 6.0f + (2.5f * this.getShape().vellen),52);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	
	bool hitBlock = false;

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null){ //Hit blob
				if(isServer() && !b.hasTag("building") && !hitBlock){
					const bool large = !b.isAttached() && b.doesCollideWithBlob(this) && b.isCollidable();//big things block attacks

					if(!canHit(this, b)){// no TK
						if (large)hitBlock = true;
						continue;
					}

					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, DmgType, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if(large)hitBlock = true;
				}
			} else 
			if(hitMap){ //Hit map
				Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
				Vec2f offset = (tpos - blobPos);
				
				if(PogoJump){
					Vec2f Pogo = (this.getAimPos() - blobPos);
					Pogo.Normalize();
					Pogo = Pogo*250.0f;
					if(map.isTileCastle(hi.tile))Pogo = Pogo*0.5f;
					this.AddForce(-Pogo);
					PogoJump = false;
				}
				
				bool ground = map.isTileGround(hi.tile);
				bool dirt_stone = map.isTileStone(hi.tile);
				bool gold = map.isTileGold(hi.tile);
				bool wood = map.isTileWood(hi.tile);
				bool hard_stone = (hi.tile >= CMap::tile_stone_hard && hi.tile <= CMap::tile_stone_hard+23);
				if(isServer())
				if (ground || wood || dirt_stone || gold || hard_stone){
					
					f32 dif = Maths::Abs(getAimAngle(this) - offset.Angle());
					if (dif > 180)dif -= 360;
					dif = Maths::Abs(dif);
					
					if (dif < 20.0f){
						//dont dig through no build zones
						bool canhit = map.getSectorAtPosition(tpos, "no build") is null;

						if(ground && !PogoJump)damage *= 2.0f;

						if (canhit){
							if(damage >= 0.5f)this.server_HitMap(hi.hitpos, Vec2f(0,0), damage, DmgType);
						}
						break;
					}
				}
			}
		}
	}
}