//Ghost logic

#include "TimeCommon.as"
#include "Knocked.as";
#include "CommonParticles.as";
#include "Magic.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	
	this.SetMapEdgeFlags(CBlob::map_collide_none);

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	//shape.getConsts().net_threshold_multiplier = 0.5f;

	this.Tag("ghost");
	this.Tag("invincible");
	
	this.set_s8("hori",0);
	this.set_s8("verti",0);
	
	this.SetLight(true);
	this.SetLightColor(SColor(128,64,0,64));
	this.SetLightRadius(4.0f);
}

void onTick(CBlob@ this)
{
	if(isServer()){
		if(!isNight()){
			this.AddForce(Vec2f(0,-10));
			if(this.getPosition().y < -640)this.server_Die();
		}
	}
	if(isClient() && this.isOnScreen() && XORRandom(2) == 0){
		this.Tag("visible");
		CorruptDarkness(this.getPosition()+Vec2f(XORRandom(8)-4,XORRandom(8)), this.getVelocity()*0.8f);
	}
	
	if(isNight()){
	
		bool seesTarget = false;
		s8 hori = this.get_s8("hori");
		s8 verti = this.get_s8("verti");
		
		CBlob @target = null;
		CBlob@[] humanoids;
		getBlobsByName("humanoid", humanoids);
		f32 distance = 1280;
		
		for(int i = 0;i < humanoids.length;i++){
			CBlob @h = humanoids[i];
			if(h !is null)
			if(h.getPlayer() !is null)
			if(h.hasTag("in_dark")){
				if(h.getDistanceTo(this) < distance){
					@target = h;
					distance = h.getDistanceTo(this);
				}
			}
		}
	
	
		if(target is null){
			
			if(getGameTime() % 30 == 0){
				if(hori == 0){
					if(XORRandom(2) == 0)hori += 1;
					else hori -= 1;
				} else
				if(hori > 0){
					if(XORRandom(hori+1) == 0)hori += 1;
					else hori -= 1;
				} else {
					if(XORRandom(-hori+1) == 0)hori -= 1;
					else hori += 1;
				}
				
				if(verti == 0){
					if(XORRandom(2) == 0)verti += 1;
					else verti -= 1;
				} else
				if(verti > 0){
					if(XORRandom(verti+1) == 0)verti += 1;
					else verti -= 1;
				} else {
					if(XORRandom(-verti+1) == 0)verti -= 1;
					else verti += 1;
				}
				
				if(this.getPosition().y < 0)verti = 5;
				//if(this.getPosition().y > (getMap().tilemapheight*8)/4)verti = -5;
				
				this.set_s8("hori",hori);
				this.set_s8("verti",verti);
			}
			
			
			
			if(getGameTime() % 6 == 0){
				this.setKeyPressed(key_right, hori > 0);
				this.setKeyPressed(key_left, hori < 0);
				this.setKeyPressed(key_down, verti > 0);
				this.setKeyPressed(key_up, verti < 0);
			} else {
				this.setKeyPressed(key_right, false);
				this.setKeyPressed(key_left, false);
				this.setKeyPressed(key_down, false);
				this.setKeyPressed(key_up, false);
			}
			
			if(isServer()){
				CBlob@[] blobs;
				getBlobsByTag("lantern", @blobs);
				getBlobsByName("stickfire", @blobs);
				
				for (int j = 0; j < blobs.length; j++){
					CBlob @blob = blobs[j];
					if(blob !is null)
					if(blob.getDistanceTo(this) < blob.getLightRadius()*0.5){
					
						Vec2f ang = blob.getPosition() - this.getPosition();
						ang.Normalize();
						this.AddForce(-ang*50.0f);
					}
				}
			}
		} else {
			if(getGameTime() % 5 == 0){
				this.setKeyPressed(key_right, target.getPosition().x > this.getPosition().x);
				this.setKeyPressed(key_left, target.getPosition().x < this.getPosition().x);
				this.setKeyPressed(key_down, target.getPosition().y > this.getPosition().y);
				this.setKeyPressed(key_up, target.getPosition().y < this.getPosition().y);
			} else {
				this.setKeyPressed(key_right, false);
				this.setKeyPressed(key_left, false);
				this.setKeyPressed(key_down, false);
				this.setKeyPressed(key_up, false);
			}
		}
	} else {
		this.setKeyPressed(key_right, false);
		this.setKeyPressed(key_left, false);
		this.setKeyPressed(key_down, false);
		this.setKeyPressed(key_up, false);
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid ){
	if(blob !is null){
		if(blob.getName() == "humanoid")
		if(blob.hasTag("in_dark")){
			SetKnocked(blob, 30);
			MagicExplosion(this.getPosition(), "DE"+XORRandom(4)+".png", 1.0f);
			if(blob is getLocalPlayerBlob())if(blob.getSprite() !is null)blob.getSprite().PlaySound("boo.ogg",1.0f);
			if(isServer())this.server_Die();
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("ghost");
}