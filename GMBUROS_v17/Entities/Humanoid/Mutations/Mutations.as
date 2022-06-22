// Builder logic

#include "Hitters.as";
#include "ModHitters.as";
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
#include "TimeCommon.as";

int ZombieCooldown = 30;

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
	
	if(getGameTime() % ZombieCooldown == 0){
		if((this.isKeyPressed(key_action1) && isLimbUsable(this,LimbSlot::MainArm) && equip.MainHand == Equipment::ZombieHands)
		|| (this.isKeyPressed(key_action2) && isLimbUsable(this,LimbSlot::SubArm) && equip.SubHand == Equipment::ZombieHands)){
			f32 side = 1.0f;
			if(this.isFacingLeft())side = -1.0f;
			
			f32 damage = 0.5;
			if(isNight())damage = 2.0f;
		
			bool hit = false;
			if(getNet().isServer()){
				CBlob@[] blobsInRadius;
				if (this.getMap().getBlobsInRadius(this.getPosition()+Vec2f(8*side,0), 8.0f, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						
						if(b !is null && b !is this && b.getTeamNum() != this.getTeamNum() && !b.hasTag("invincible")){
							hit = true;
							this.server_Hit(b, this.getPosition(), b.getPosition()-this.getPosition(), damage, Hitters::bite, true);
						}
					}
				}
			}

			Vec2f Aim = this.getAimPos()-this.getPosition();
			Aim.Normalize();
			if(Aim.x > 0)for(int i = 0;i < 4;i++)if(XORRandom(3) == 0)getMap().server_DestroyTile(this.getPosition()+Vec2f(12,-12+8*i),2.0f);
			if(Aim.x < 0)for(int i = 0;i < 4;i++)if(XORRandom(3) == 0)getMap().server_DestroyTile(this.getPosition()+Vec2f(-12,-12+8*i),2.0f);
			if(Aim.y > 0)for(int i = 0;i < 4;i++)if(XORRandom(3) == 0)getMap().server_DestroyTile(this.getPosition()+Vec2f(-12+8*i,12),2.0f);
			if(Aim.y < 0)for(int i = 0;i < 4;i++)if(XORRandom(3) == 0)getMap().server_DestroyTile(this.getPosition()+Vec2f(-12+8*i,-12),2.0f);
			
			if(isNight())this.Tag("climb_walls");
			else this.Untag("climb_walls");
		} else {
			this.Untag("climb_walls");
		}
	}
	
	if(!isNight())
	if(this.hasTag("animated") && this.getPlayer() is null){
		RunnerMoveVars@ moveVars;
		if(this.get("moveVars", @moveVars)){
			moveVars.walkFactor *= 0.5;
		}
	}

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
	
	if(isNight())if(this.getTeamNum() == 10)damage *= 0.25;
	
	return damage;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::bite)
	{
		this.getSprite().PlaySound("ZombieBite"+(1+XORRandom(2)));
	}
}