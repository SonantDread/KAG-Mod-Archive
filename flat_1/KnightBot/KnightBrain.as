// Knight brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Knocked.as"
#include "KnightCommon.as"
#include "ArcherCommon.as"


void onInit(CBrain@ this)
{
	InitBrain(this);
}


void onTick(CBrain@ this)
{
  
   CBlob @blob = this.getBlob();
   CBlob @target = this.getTarget();
   
   
   
	if (target !is null)
	{
		if(target.hasTag("dead")) {
		  this.SetTarget(null);
		} 
		
		f32 distance;
		distance = (blob.getPosition() - target.getPosition()).getLength();
		  
		KnightInfo@ knight;
		if (!blob.get("knightInfo", @knight))
		{
		  return;
		}
   
		// BC prevent bots from dancing when theres a wall between them and the target
		Vec2f col;
		bool visible = !getMap().rayCastSolid(blob.getPosition(), target.getPosition(), col);
		f32 visibleDistance = (blob.getPosition() - col).getLength();

   		if(isVisible(blob, target) || (visibleDistance > 19.0f && !blob.isOnWall() && !blob.isOnCeiling()) || (visibleDistance > 11.0f && blob.isOnWall())) {  // BC Hack to help bots jump over walls and prevent bots from dancing
			/* KNIGHT LOGIC */
			if(target.getName() == "knight" || target.getName() == "botknight") {
				KnightInfo@ other;
				if (!target.get("knightInfo", @other))
				{
					return;
				}
				
				if(distance < 30.0f ) {
					if(other.state < KnightStates::sword_cut_mid) {
						JustGo(blob,target);
						if( getKnocked(target) > 0 ) {
						  blob.setAimPos(target.getPosition());
						  blob.setKeyPressed(key_action1, true);
						  if(knight.swordTimer > 1) {
							blob.setKeyPressed(key_action1, false);
						  }
						}
						else if(knight.swordTimer > 38 && target.isKeyPressed(key_action2)) {
						  blob.setKeyPressed(key_action1, false);
						}
						else if(target.isKeyPressed(key_action2)) {
						  blob.setKeyPressed(key_action1, true);
						}
						else if(other.swordTimer > 0 && knight.swordTimer > 0 ) {
						  blob.setKeyPressed(key_action1, false);
						}
						else if(other.swordTimer == 0 && !target.isKeyPressed(key_action2)) {
						  blob.setAimPos(target.getPosition());
						  blob.setKeyPressed(key_action1, true);
						  if(knight.swordTimer > 1) {
							blob.setKeyPressed(key_action1, false);
						  }
						}
						else if(other.swordTimer >= 10 && other.swordTimer < 15 ) {
						  blob.setAimPos(target.getPosition());
						  blob.setKeyPressed(key_action1, true);
						  if(knight.swordTimer > 1) {
							blob.setKeyPressed(key_action1, false);
						  }
						}
						else if(other.swordTimer >= 20 && other.swordTimer < 35  ) {
						  blob.setAimPos(target.getPosition());
						  blob.setKeyPressed(key_action1, true);
						  if(knight.swordTimer > 1) {
							blob.setKeyPressed(key_action1, false);
						  }
						}
						else{
						  blob.setAimPos(target.getPosition());
						  blob.setKeyPressed(key_action2, true);
						}
						
					}
					else if(other.state >= KnightStates::sword_cut_mid) {
						blob.setAimPos(target.getPosition());
						blob.setKeyPressed(key_action2, true);
						Runaway(blob,target);
					}
				}
				else if(distance < 120.0f ) {
					blob.setAimPos(target.getPosition());
					blob.setKeyPressed(key_action1, true);
					JustGo(blob,target);
					  
					if(distance < 50.0f  && knight.swordTimer >= 15) {
						blob.setKeyPressed(key_action1, false);
						blob.setKeyPressed(key_up, true);
					}
					  
					  
				}

				else if(distance < 10000.0f) {
					
					blob.setAimPos(target.getPosition());
					if (visibleDistance > 120.0f)
					{
						JustGoShield(blob,target);
					}
					else
					{
						JustGo(blob,target);	
						blob.setKeyPressed(key_up, true);
					}
				}
			}
			
			/* ARCHER LOGIC */
			/*  BC DISABLE FOR NOW if(target.getName() == "archer") {
			  
				ArcherInfo@ other;
				if (!target.get("archerInfo", @other))
				{
					return;
				}
				
				if (other.charge_time >= 1){
					blob.set_u32("SawArrowTimer", 30);
				}
				
				if(other.charge_state == ArcherParams::legolas_ready) {
					blob.setAimPos(target.getPosition());
					blob.setKeyPressed(key_action2, true);
				}
				else {
					if(distance < 26.0f ) {
						JustGo(blob,target);
						blob.setAimPos(target.getPosition());
						blob.setKeyPressed(key_action1, true);
						if(knight.swordTimer > 1) {
							blob.setKeyPressed(key_action1, false);
						}
					}
					else if(distance < 120.0f ) {
						blob.setAimPos(target.getPosition());
						
						if(other.charge_time >= 68) {
							Runaway(blob,target);
						}
						else {
							JustGo(blob,target);
						}
						
						if(blob.get_u32("SawArrowTimer") > 0) {
							blob.setKeyPressed(key_action2, true);
							blob.sub_u32("SawArrowTimer",1);
						}
					}
					else if(distance < 300.0f) {
						if(blob.get_u32("SawArrowTimer") > 0) {
							if(other.charge_time >= 68) {
								Runaway(blob,target);
							}
							else 
							{
								JustGo(blob,target);
							}
						
							blob.setAimPos(target.getPosition());
							blob.setKeyPressed(key_action2, true);
							blob.sub_u32("SawArrowTimer",1);
						}
						else 
						{
							JustGoShield(blob,target);
						}
					}
				}
				
				
			}
			*/
			/* BUILDER & ARCHER LOGIC */
			if(target.getName() == "builder" || target.getName() == "archer")
			{
				blob.setAimPos(target.getPosition());
				if(distance < 30.0f ) 
				{
					JustGo(blob,target);
					blob.setKeyPressed(key_action1, true);
					if(knight.swordTimer > 1) {
						blob.setKeyPressed(key_action1, false);
					}
				}
				else if(distance < 120.0f ) 
				{
					JustGo(blob,target);
				}
				else if(distance < 10000.0f) 
				{
				   	if (visibleDistance > 120.0f)
					{
						JustGoShield(blob,target);
					}
					else
					{
						JustGo(blob,target);
					}

				}
			}
		}
		else
		{
			if(target !is null)
			{
				if (getGameTime() % 30 == 0) this.SetPathTo(target.getPosition(), 1);
				
				JustGo(blob, this.getNextPathPosition());
			}
		}
	}
	
	CBlob@ tar = getNewTarget(this, blob, true, true);
	this.SetTarget(tar);

	FloatInWater(blob);
}