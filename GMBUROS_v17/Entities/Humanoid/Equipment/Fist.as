#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"

void onTick(CBlob @this){ //Inb4 FIST! clan thinks I made this class for them
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	if(this.getCarriedBlob() !is null)if(this.getCarriedBlob().hasTag("temp blob"))return;
	if(this.get_TileType("buildtile") > 0)return;
	
	for(int i = 0;i < 2;i++){
		f32 punch = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = 0.5f*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm);
		
		if(i != 0){
			punch = equip.subSwingTimer;
			holding = this.isKeyPressed(key_action2);
			damage = 0.5f*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm);
			if(equip.SubHand != Equipment::None || !isLimbMovable(this,LimbSlot::SubArm))continue;
		} else {
			if(equip.MainHand != Equipment::None || !isLimbMovable(this,LimbSlot::MainArm))continue;
		}
		
		
		if(holding && punch < 31){
			if(speed <= 1.5f){
				punch = Maths::Min(punch+speed,30);
			} else {
				punch = Maths::Min(punch+speed,31);
			}
		} else {
			if(punch > 10){
				if(punch <= 32){
					DoPunch(this,(punch/30.0f*0.5f+0.5f)*damage,-getAimAngle(this),40);
					punch = 65-punch;
				} else {
					if(punch < 60)punch += 4;
					else punch = 0;
				}
			} else {
				punch = 0;
			}
		}
		
		
		if(i == 0)equip.mainSwingTimer = punch;
		else equip.subSwingTimer = punch;
	}
}

void DoPunch(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(10 + (2.5f * this.getShape().vellen),26);

	f32 radius = this.getRadius();
	CMap@ map = this.getMap();

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(pos, aimangle, arcdegrees, radius + attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null) // blob
			if(!b.hasTag("building")){

				//big things block attacks
				const bool large = !b.isAttached() && b.isCollidable();

				if (!canHitFist(this, b))
				{
					// no TK
					if (large)break;
				}

				Vec2f velocity = b.getPosition() - pos;
				this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::muscles, true);  // server_Hit() is server-side only
				CSprite @sprite = this.getSprite();
				
				// end hitting if we hit something solid, don't if its flesh
				if(large)break;
			}
		}
	}
}

bool canHitFist(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}