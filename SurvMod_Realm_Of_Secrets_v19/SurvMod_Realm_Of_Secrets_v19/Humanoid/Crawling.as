#include "RunnerCommon.as";
#include "LimbsCommon.as";

void onTick(CBlob@ this)
{
	bool old_hitbox = this.get_bool("short_hitbox");
	bool short_hitbox = (this.isKeyJustPressed(key_down) || old_hitbox) && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)) && this.isOnGround() && !this.isOnLadder() && this.isKeyPressed(key_down);
	
	if(!this.isOnGround() && old_hitbox && !this.isOnLadder())short_hitbox = true;
	
	int frontLeg = this.get_u8("fleg_type");
	int backLeg = this.get_u8("bleg_type");
	
	if(!short_hitbox)if(this.getHealth() <= 0.0 || frontLeg == BodyType::None || backLeg == BodyType::None)short_hitbox = true;
	
	if(frontLeg == BodyType::Wood && backLeg == BodyType::Wood)short_hitbox = false;
	if(frontLeg == BodyType::Golem && backLeg == BodyType::Golem)short_hitbox = false;
	
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
			moveVars.jumpFactor *= 0.1f;
			moveVars.walkFactor *= 0.3f;
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