#include "RunnerCommon.as";
#include "LimbsCommon.as";

void onTick(CBlob@ this)
{
	bool old_hitbox = this.get_bool("short_hitbox");
	bool short_hitbox = ((this.isKeyJustPressed(key_left) || this.isKeyJustPressed(key_right)) || old_hitbox) && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)) && this.isOnGround() && !this.isOnLadder() && this.isKeyPressed(key_down);
	
	if(!this.isOnGround() && old_hitbox && !this.isOnLadder())short_hitbox = true;
	
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	if(!short_hitbox)if(this.getHealth() <= 0.0 || limbs.FrontLeg == BodyType::None || limbs.BackLeg == BodyType::None)short_hitbox = true;
	if(!this.hasTag("alive") && !this.hasTag("animated"))short_hitbox = true;
	
	if(limbs.FrontLeg == BodyType::Gold && limbs.BackLeg == BodyType::Gold)short_hitbox = false;
	if(limbs.FrontLeg == BodyType::Wood && limbs.BackLeg == BodyType::Wood)short_hitbox = false;
	if(limbs.FrontLeg == BodyType::Golem && limbs.BackLeg == BodyType::Golem)short_hitbox = false;
	if(limbs.FrontLeg == BodyType::Metal && limbs.BackLeg == BodyType::Metal)short_hitbox = false;
	
	if(!short_hitbox && old_hitbox)
	if(getMap().rayCastSolid(this.getPosition()+Vec2f(0,-8),this.getPosition()+Vec2f(0,-8))
	|| getMap().rayCastSolid(this.getPosition()+Vec2f(0,-8),this.getPosition()+Vec2f(5.5,-8))
	|| getMap().rayCastSolid(this.getPosition()+Vec2f(0,-8),this.getPosition()+Vec2f(-5.5,-8))){
		short_hitbox = true;
	}
	
	//if(!short_hitbox)if(this.isInWater() && !this.isOnGround())short_hitbox = true;
	
	if(short_hitbox){
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(isLimbMovable(this,LimbSlot::MainArm) && isLimbMovable(this,LimbSlot::SubArm)){ //If both arms usable
				moveVars.walkFactor *= 0.1f*getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm) + 0.1f*getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm);
				moveVars.jumpFactor *= 0.35f*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm) + 0.35f*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			} else
			if(isLimbMovable(this,LimbSlot::MainArm)){ //If front arm usable
				moveVars.walkFactor *= 0.1f*getLimbSpeed(this,LimbSlot::MainArm,limbs.MainArm);
				moveVars.jumpFactor *= 0.35f*getLimbStrength(this,LimbSlot::MainArm,limbs.MainArm);
			} else
			if(isLimbMovable(this,LimbSlot::SubArm)){ //If back arm usable
				moveVars.walkFactor *= 0.1f*getLimbSpeed(this,LimbSlot::SubArm,limbs.SubArm);
				moveVars.jumpFactor *= 0.35f*getLimbStrength(this,LimbSlot::SubArm,limbs.SubArm);
			} else {
				moveVars.walkFactor *= 0.01;
				moveVars.jumpFactor *= 0.01;
			}
		}
	}
	
	if(short_hitbox != old_hitbox){

		CShape@ shape = this.getShape();
	
		f32 height = 1.0f;
		f32 yoffset = 0.0f;
		if(short_hitbox){
			height = 0.1f;
		}
		
		Vec2f[] head;
		head.push_back(Vec2f(-5.5f,yoffset+-5.5f*height));
		head.push_back(Vec2f(0.0f,yoffset+-6.5f*height));
		head.push_back(Vec2f(5.5f,yoffset+-5.5f*height));
		head.push_back(Vec2f(6.5f,yoffset+0.0f));
		head.push_back(Vec2f(5.5f,yoffset+5.5f));
		head.push_back(Vec2f(0.0f,yoffset+5.5f+2.0f*height));
		head.push_back(Vec2f(-5.5f,yoffset+5.5f));
		head.push_back(Vec2f(-6.5f,yoffset+0.0f));
		
		shape.SetShape(head);
		
		this.set_bool("short_hitbox",short_hitbox);
	}
}