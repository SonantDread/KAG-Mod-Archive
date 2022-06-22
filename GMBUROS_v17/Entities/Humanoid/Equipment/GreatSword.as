#include "Hitters.as"
#include "EquipmentCommon.as"
#include "LimbsCommon.as"
#include "Knocked.as";
#include "CommonParticles.as";

void onTick(CBlob@ this)
{
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;	

	if(equip.MainHand == Equipment::GreatSword && canLimbAttack(this,LimbSlot::MainArm)){
		f32 sword = equip.mainSwingTimer;
		bool holding = this.isKeyPressed(key_action1);
		f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
		f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
		int DmgType = getEquipmentDamageType(equip.MainHand,equip.MainHandType);
		f32 range = getEquipmentRange(this,LimbSlot::MainArm,equip.MainHand,equip.MainHandType);

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
					if(equip.MainHandType == 3){
						DoAttack(this,0.5f*damage,-getAimAngle(this),40, Hitters::stab, range+4.0f);
						sword = -15;
					} else {
						sword = 0;
					}
				} else
				if(sword < 38){
					DoAttack(this,damage,-getAimAngle(this),135,DmgType, range);
					sword = -60;
				} else {
					DoAttack(this,damage,-getAimAngle(this),135,DmgType, range);
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
					DoAttack(this,damage,-getAimAngle(this),135,DmgType, range);
					sword = -60;
				}
			}
		}
		
		equip.mainSwingTimer = sword;
	}
	
	if(!canLimbAttack(this,LimbSlot::SubArm))return;

	if(equip.SubHand == Equipment::GreatSwordAlt){
		if(this.isOnGround()){
			this.set_u16("ground_height",this.getPosition().y);
			this.Untag("shadow_aura");
		}
		if(this.isKeyPressed(key_action2))if(equip.SubHandType == 2)if(this.get_s16("darkness") > 0){ //Shadow blade alt
			//if(this.get_u16("ground_height") < this.getPosition().y+64)
			this.setVelocity(this.getVelocity()*0.90f+Vec2f(0,-0.5f));
			//else this.setVelocity(this.getVelocity()*0.80f);
			this.Tag("shadow_aura");
			cpr(this.getPosition()+(Vec2f(XORRandom(64),0).RotateBy(XORRandom(360))),Vec2f(XORRandom(7)-3,-XORRandom(7)-2)*0.3f);
			cpr(this.getPosition()+(Vec2f(XORRandom(8)+8,0).RotateBy(XORRandom(360))),Vec2f(XORRandom(2)-1,-XORRandom(7)-2)*0.4f);
			
			if(getGameTime() % 20 == 0 || this.isKeyJustPressed(key_action2))this.sub_s16("darkness",1);
		}
		this.getCurrentScript().tickFrequency = 1;
	} else this.getCurrentScript().tickFrequency = 61;
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("aura");
	CSpriteLayer@ aura = this.addSpriteLayer("aura", "DarkAura.png" , 128, 128, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (aura !is null)
	{
		Animation@ anim = aura.addAnimation("default", 0, false);
		anim.AddFrame(0);
		aura.SetVisible(false);
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ aura = this.getSpriteLayer("aura");

	if (aura !is null)
	{
		if(this.getBlob().hasTag("shadow_aura")){
			aura.setRenderStyle(RenderStyle::light);
			aura.SetRelativeZ(-100.0f);
			aura.SetVisible(true);
			aura.RotateBy(10,Vec2f(0,0));
		} else {
			aura.SetVisible(false);
		}
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, int DmgType, f32 Range)
{
	if (aimangle < 0.0f)aimangle += 360.0f;

	Vec2f blobPos = this.getPosition();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + this.getVelocity();

	f32 attack_distance = Maths::Min(Range + 6.0f + (2.5f * this.getShape().vellen),52);

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
					this.server_Hit(b, hi.hitpos, velocity, damage, DmgType, true);  // server_Hit() is server-side only
					
					// end hitting if we hit something solid, don't if its flesh
					if (large)break;
				}
			}
		}
	}
}