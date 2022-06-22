
#include "Hitters.as";
#include "ModHitters.as";
#include "TimeCommon.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightColor(SColor(11, 213, 255, 171));
	this.SetLightRadius(32.0f);
	
	this.set_s16("flight_height",16);
	this.set_s16("flight_target_height",this.getPosition().y);
	
	this.set_s16("locationX",-1);
	
	this.Tag("no hands");
	this.Tag("alive");
	
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

void onTick(CBlob@ this)
{
	int Height = this.get_s16("flight_height");
	int LocX = this.get_s16("locationX");
	Vec2f pos = this.getPosition();
	
	CMap@ map = this.getMap();
	Vec2f surfacepos;
	if(this.getPlayer() is null){
		bool foundWater = false;
		bool waterTooClose = false;
		
		for(int i = 0; i*8 < Height; i++){
			if(map.isInWater(pos+Vec2f(0,i*8+8))){
				foundWater = true;
				if(i  <= 1)waterTooClose = true;
				break;
			}
		}
		
		if(map.rayCastSolid(pos, pos+Vec2f(0,Height), surfacepos) || (pos+Vec2f(0,Height)).y > getMap().tilemapheight*8 || foundWater){
			this.AddForce(Vec2f(0, -6));
		} else {
			this.AddForce(Vec2f(0, -5));
		}
		
		if(waterTooClose && this.getVelocity().y > 0)this.setVelocity(Vec2f(this.getVelocity().x,this.getVelocity().y/2.0f));
		
		this.set_s16("flight_target_height",pos.y);
	} else {
		if(this.get_s16("flight_target_height") < pos.y){
			this.AddForce(Vec2f(0, -10));
		} else {
			this.AddForce(Vec2f(0, -2));
		}
	}
	
	
	if(LocX != -1){
		if(LocX < pos.x -2){
			this.AddForce(Vec2f(-1, 0));
		} 
		if(LocX > pos.x +2){
			this.AddForce(Vec2f(1, 0));
		}
	}
	
	
	
	if(this.getPlayer() !is null){
	
		if(this.isKeyPressed(key_left)){
			
			LocX = pos.x-4;
		}
		
		if(this.isKeyPressed(key_right)){
			
			LocX = pos.x+4;
		}
		
		if(this.isKeyPressed(key_up)){
			
			if(this.get_s16("flight_target_height") > 4)this.set_s16("flight_target_height",pos.y-1);
		}
		
		if(this.isKeyPressed(key_down)){
			
			this.set_s16("flight_target_height",pos.y+6);
		}
	
		this.SetFacingLeft(this.getAimPos().x < pos.x);
	
	} else {
		this.SetFacingLeft(this.getVelocity().x < 0);
	}
	
	
	
	if(getNet().isServer()){
		if(this.getPlayer() is null){
			if(getGameTime() % 30 == 0){
				if(this.isAttached()){
					CBlob @p = this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
					if(p !is null){
						this.server_Hit(p, pos, Vec2f(0,0), 0.5f, Hitters::burn, true);
					}
				}
			}
		}
		
		if(getHour() >= 21 || getHour() < 5){
			Height += 32;
			if(pos.y < -640)this.server_Die();
		} else{
			if(map.rayCastSolid(pos, pos+Vec2f(0,-8.0f), surfacepos) || pos.y < 32){
				Height -= 4;
			}
			if(XORRandom(10) == 0){
				Height += XORRandom(30)-15;
				
				if(XORRandom(2) == 0){
					LocX = -1;
				} else {
					LocX = pos.x+XORRandom(640)-320;
				}
			}
		}
		
		if(Height < 32)Height = 32;
		this.set_s16("flight_height",Height);
		if(getGameTime() % 31 == 0)
		if(Height != this.get_s16("flight_height")){
			this.Sync("flight_height",true);
		}
		
		if(LocX != this.get_s16("locationX")){
			this.set_s16("locationX",LocX);
			this.Sync("locationX",true);
		}
	}
	
	if(XORRandom(3) == 0){
		CParticle @p = ParticleAnimated("lp.png", pos+Vec2f(XORRandom(5)-2,XORRandom(5)-3), this.getVelocity()/10+Vec2f(XORRandom(801)-400,-XORRandom(100))/10000, 90.0f, 1.0f, 6, -0.1f, true);
		if(p !is null){
			p.Z = -50.0f;
		}
	}
	
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(blob !is null){
		if(getNet().isServer()){
			if(blob.hasTag("flesh"))
			if(XORRandom(3) == 0){
				this.server_Hit(blob, this.getPosition(), Vec2f(0,0), 0.5f, Hitters::burn, true);
			}
		}
	}
}
