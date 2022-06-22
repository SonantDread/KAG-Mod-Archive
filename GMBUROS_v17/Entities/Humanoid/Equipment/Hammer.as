// Builder logic

#include "Hitters.as";
#include "Knocked.as";
#include "BuilderCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "BuilderHittable.as";
#include "PlacementCommon.as";
#include "ParticleSparks.as";
#include "MaterialCommon.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit(CBlob@ this)
{
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	bool building = false;
	if(this.getCarriedBlob() !is null)if(this.getCarriedBlob().hasTag("temp blob"))building = true;
	if(this.get_TileType("buildtile") > 0)building = true;
	
	if(ismyplayer && this.isKeyPressed(key_action1) && !this.isKeyPressed(key_inventory)) //Don't let the builder place blocks if he/she is selecting which one to place
	{
		BlockCursor @bc;
		this.get("blockCursor", @bc);

		if(building){
			HitData@ hitdata;
			this.get("hitdata", @hitdata);
			hitdata.blobID = 0;
			hitdata.tilepos = bc.buildable ? bc.tileAimPos : Vec2f(-8, -8);
			
			if(equip.MainHand == Equipment::Hammer && isLimbUsable(this,LimbSlot::MainArm) && equip.mainSwingTimer <= 0)equip.mainSwingTimer = 40;
			if(equip.SubHand == Equipment::Hammer && isLimbUsable(this,LimbSlot::SubArm) && equip.subSwingTimer <= 0)equip.subSwingTimer = 40;
		}
	}
	
	if(building){
		if(equip.mainSwingTimer > 0)equip.mainSwingTimer -= 4;
		if(equip.subSwingTimer > 0)equip.subSwingTimer -= 4;
	}

	// get rid of the built item
	if(this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup) || !((isLimbUsable(this,LimbSlot::MainArm) && equip.MainHand == Equipment::Hammer) || (isLimbUsable(this,LimbSlot::SubArm) && equip.SubHand == Equipment::Hammer)))
	{
		this.set_u8("buildblob", 255);
		this.set_TileType("buildtile", 0);

		CBlob@ blob = this.getCarriedBlob();
		if(blob !is null && blob.hasTag("temp blob"))
		{
			blob.Untag("temp blob");
			blob.server_Die();
		}
	}
	
	if(!building){
		for(int i = 0;i < 2;i++){
			f32 hammer = equip.mainSwingTimer;
			bool holding = this.isKeyPressed(key_action1);
			u8 Type = equip.MainHandType;
			f32 damage = getEquipmentDamage(equip.MainHand,equip.MainHandType)*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
			f32 speed = getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm)*getEquipmentSpeed(equip.MainHand,equip.MainHandType,getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm));
			
			if(i != 0){
				hammer = equip.subSwingTimer;
				holding = this.isKeyPressed(key_action2);
				Type = equip.SubHandType;
				damage = getEquipmentDamage(equip.SubHand,equip.SubHandType)*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
				speed = getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm)*getEquipmentSpeed(equip.SubHand,equip.SubHandType,getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm));
				if(equip.SubHand != Equipment::Hammer || !canLimbAttack(this,LimbSlot::SubArm))continue;
			} else {
				if(equip.MainHand != Equipment::Hammer || !canLimbAttack(this,LimbSlot::MainArm))continue;
			}
			
			
			if(holding && hammer >= 0){
				if(hammer <= 29 && hammer+speed > 29)Sound::Play("Creak.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.7f);
				if(hammer <= 10 && hammer+speed > 10)Sound::Play("ChargeEnough.ogg", this.getPosition(), this.isMyPlayer() ? 1.3f : 0.1f);
				if(hammer > 55){
					Sound::Play("/Stun", this.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
					SetKnocked(this, 15);
					hammer = 0;
				}
				if(hammer < 31)hammer = Maths::Min(hammer+speed,31);
				else hammer += -1.0f+XORRandom(4);
			} else {
				if(hammer > 10){
					DoAttack(this,Maths::Min(hammer,30.0f)/30.0f*damage,-getAimAngle(this),60+hammer,Type);
					hammer = -1;
				} else 
				if(hammer < 0){
					if(hammer > -40)hammer -= 6;
					else hammer = 0;
				} else {
					hammer = 0;
				}
			}
			
			if(i == 0)equip.mainSwingTimer = hammer;
			else equip.subSwingTimer = hammer;
		}
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 Type)
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
				if(canHit(this, b))
				if(b.getName() == "humanoid" && Type == 3)Sound::Play("bonk.ogg", b.getPosition());
			
				if(isServer()){
					const bool large = !b.isAttached() && b.doesCollideWithBlob(this) && b.isCollidable();//big things block attacks

					if (!canHit(this, b)){
						if (large)break;
						continue;
					}

					Vec2f velocity = b.getPosition() - pos;
					this.server_Hit(b, hi.hitpos, velocity, damage, Hitters::shield, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)break;
				}
			} else { //Hit map
				if(isServer())
				if(map.isTileCastle(hi.tile)){
					Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
					Vec2f offset = (tpos - this.getPosition());
					
					f32 dif = Maths::Abs(getAimAngle(this) - offset.Angle());
					if (dif > 180)dif -= 360;
					dif = Maths::Abs(dif);
					
					if (dif < 20.0f){
						//dont dig through no build zones
						bool canhit = map.getSectorAtPosition(tpos, "no build") is null;

						if(canhit){
							if(damage >= 2.0f)this.server_HitMap(hi.hitpos, Vec2f(0,0), 1.0f, Hitters::builder);
						}
						break;
					}
				}
			}
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if(!this.get("blocks", @blocks))
	{
		return;
	}
	
	
	const u8 PAGE = this.get_u8("build page");
	
	for(u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if(block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if(detached.hasTag("temp blob"))
	{
		if(!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if(i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if(b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				CBitStream missing;
				if(hasRequirements(inv, b.reqs, missing, not b.buildOnGround))
				{
					server_TakeRequirements(inv, b.reqs);
				}
				// take out another one if in inventory
				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
	else if(detached.getName() == "seed")
	{
		if (not detached.hasTag('temp blob placed')) return;

		CBlob@ anotherBlob = this.getInventory().getItem(detached.getName());
		if(anotherBlob !is null)
		{
			this.server_Pickup(anotherBlob);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if(blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

	if(this.isMyPlayer() && blob.hasTag("material"))
	{
		SetHelp(this, "help inventory", "builder", "$Help_Block1$$Swap$$Help_Block2$           $KEY_HOLD$$KEY_F$", "", 3);
	}
}
