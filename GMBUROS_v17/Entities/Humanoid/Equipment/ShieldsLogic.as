#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"
#include "ParticleSparks.as";
#include "Hitters.as";
#include "RunnerCommon.as";
#include "Knocked.as";

void onTick(CBlob @this){ //Block Block
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))return;
	
	Vec2f vel = this.getVelocity();
	
	bool forcedrop = (vel.y > Maths::Max(Maths::Abs(vel.x), 2.0f) && moveVars.fallCount > 50);
	bool gliding = false;
	bool dropping = false;
	this.Untag("sliding");
	
	bool canShield = true;
	if(equip.mainSwingTimer != 0 && (equip.MainHand != Equipment::Shield && equip.MainHand != Equipment::None && equip.MainHand != Equipment::Pole))canShield = false;
	if(equip.subSwingTimer != 0 && (equip.SubHand != Equipment::Shield && equip.SubHand != Equipment::None && equip.SubHand != Equipment::Pole))canShield = false;
	
	for(int i = 0;i < 2;i++){
		f32 shield = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		
		if(i != 0){
			shield = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			if(equip.SubHand != Equipment::Shield || !isLimbMovable(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Shield || !isLimbMovable(this,LimbSlot::MainArm))continue;
		}
		
		if(shield > 0){
			shield--;
		}
		if(holding && canShield){
			if(shield == 0)shield = 1;
		}
		
		if(shield == 1){
			if(getAimAngle(this) > 45 && getAimAngle(this) < 135)gliding = true;
			if(getAimAngle(this) > 270-45 && getAimAngle(this) < 270+45)dropping = true;
		}
		
		if(i == 0)equip.mainSwingTimer = shield;
		else equip.subSwingTimer = shield;
	}
	
	if(dropping){
		if(this.isInWater()){
			if (vel.y > 1.5f){// && Maths::Abs(vel.x) * 3 > Maths::Abs(vel.y)){
				vel.y = Maths::Max(-Maths::Abs(vel.y) + 1.0f, -8.0);
				this.setVelocity(vel);
			}
		} else 
		if(!this.isOnLadder()){
		
			this.Tag("sliding");
		
			
		}
	}
	
	if(gliding){
		this.Tag("shieldplatform");
		if(!this.isInWater() && !this.isOnGround() && !this.isOnLadder() && !forcedrop){
			moveVars.stoppingFactor *= 0.5f;

			f32 glide_amount = 1.0f - (moveVars.fallCount / f32(50 * 2));

			if (vel.y > 0.5f)
			{
				this.AddForce(Vec2f(0, -40.0f * glide_amount));
			}
		}
	} else {
		this.Untag("shieldplatform");
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal ){
	if(solid)
	if(this.hasTag("sliding")){
		Vec2f vel = this.getOldVelocity();
		
		if(vel.y > 3.0f){
		
			

			if(vel.x > 0)this.setVelocity(Vec2f(vel.x/2.0f+vel.y,-vel.y));
			if(vel.x < 0)this.setVelocity(Vec2f(vel.x/2.0f-vel.y,-vel.y));

			if(vel.x != 0){
				this.getSprite().PlayRandomSound("/Scrape");
				for(int i = 0;i < XORRandom(3)+3;i++){
					Vec2f velr = getRandomVelocity(!this.isFacingLeft() ? 50 : 130, 2.3f, 20.0f);
					velr.y = -Maths::Abs(velr.y) + Maths::Abs(velr.x) / 3.0f - 2.0f - float(XORRandom(100)) / 100.0f;
					ParticlePixel(this.getPosition()+Vec2f((this.isFacingLeft() ? 1 : -1)*XORRandom(5),7), velr, SColor(255, 255, 255, 0), true);
				}
			}
			
			print("Vec2f"+vel);
		}
	}
	
}


bool canBlockThisType(u8 type) // this function needs to use a tag on the hitterBlob, like ("bypass shield")
{
	return type == Hitters::stomp ||
	       type == Hitters::builder ||
	       type == Hitters::sword ||
	       type == Hitters::shield ||
		   type == Hitters::muscles ||
	       type == Hitters::arrow ||
	       type == Hitters::bite ||
	       type == Hitters::stab ||
	       isExplosionHitter(type);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	
	if (this.hasTag("dead") ||
	        !canBlockThisType(customData) ||
	        this is hitterBlob)
	{
		return damage;
	}
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return damage;

	//no shield when stunned
	if (this.get_u8("knocked") > 0){
		return damage;
	}
	
	Vec2f direction = (this.getPosition()-worldPoint);
	
	bool bombJump = false;
	
	bool mainBlocked = false;
	bool mainKnocked = false;
	
	bool subBlocked = false;
	bool subKnocked = false;

	for(int i = 0;i < 2;i++){
		f32 shield = equip.mainSwingTimer;
		int Slot = EquipSlot::Main;
		if(i != 0){
			shield = equip.subSwingTimer;
			Slot = EquipSlot::Sub;
			if(equip.SubHand != Equipment::Shield || !isLimbMovable(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::Shield || !isLimbMovable(this,LimbSlot::MainArm))continue;
		}
		
		if(shield == 1)
		if (blockAttack(this, direction, Slot)){
			if (isExplosionHitter(customData)){
				bombJump = true;
			} else
			if(exceedsShieldBreakForce(this, damage, Slot) && customData != Hitters::arrow){
				if(i == 0)mainKnocked = true;
				else subKnocked = true;
			} else {
				if(hitterBlob !is null){
					SetKnocked(hitterBlob, 15);
				}
			}
		
			if(i == 0)mainBlocked = true;
			else subBlocked = true;
			
			Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);
			const f32 vellen = velocity.Length();
			sparks(worldPoint, -velocity.Angle(), Maths::Max(vellen * 0.05f, damage));
		}
		
		
		if(i == 0)equip.mainSwingTimer = shield;
		else equip.subSwingTimer = shield;
	}
	
	if(mainBlocked && subBlocked){
		if(mainKnocked && subKnocked){
			equip.mainSwingTimer = 40;
		}
	}
	if(mainBlocked && !subBlocked){
		if(mainKnocked){
			equip.mainSwingTimer = 40;
			SetKnocked(this, 10);
		}
	}
	if(!mainBlocked && subBlocked){
		if(subKnocked){
			equip.subSwingTimer = 40;
			SetKnocked(this, 10);
		}
	}
	
	if(bombJump){ //bomb jump
		Vec2f vel = this.getVelocity();
		this.setVelocity(Vec2f(0.0f, Maths::Min(0.0f, vel.y)));

		Vec2f bombforce = Vec2f(0.0f, ((velocity.y > 0) ? 0.7f : -1.3f));

		bombforce.Normalize();
		bombforce *= 2.0f * Maths::Sqrt(damage) * this.getMass();
		bombforce.y -= 2;

		if (!this.isOnGround() && !this.isOnLadder())
		{
			if (this.isFacingLeft() && vel.x > 0)
			{
				bombforce.x += 50;
				bombforce.y -= 80;
			}
			else if (!this.isFacingLeft() && vel.x < 0)
			{
				bombforce.x -= 50;
				bombforce.y -= 80;
			}
		}
		else if (this.isFacingLeft() && vel.x > 0)
		{
			bombforce.x += 5;
		}
		else if (!this.isFacingLeft() && vel.x < 0)
		{
			bombforce.x -= 5;
		}

		this.AddForce(bombforce);
		this.Tag("dont stop til ground");

	}
	
	if(mainBlocked || subBlocked)return 0.0f;

	return damage; //no block, damage goes through
}

bool blockAttack(CBlob@ this, Vec2f direction, int slot)
{
	if (this.hasTag("dead")) return false;

	//zero direction = bypass shield
	if (direction.LengthSquared() < 0.001f) return false;
	
	f32 Arc = 80.0f;
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return false;

	Vec2f aim = this.getAimPos() - this.getPosition();
	f32 angle = Maths::Abs(aim.AngleWith(direction));
	f32 angle_difference = 180.0f - angle;
	
	return ((angle_difference) < Arc);
}

bool exceedsShieldBreakForce(CBlob@ this, f32 damage, int slot)
{
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return true;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return true;

	f32 MaxDamage = 2.0f;
	
	if(slot == EquipSlot::Main)MaxDamage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
	if(slot == EquipSlot::Sub)MaxDamage = getEquipmentDamage(equip.SubHand,equip.SubHandType)*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);

	return damage >= MaxDamage;
}