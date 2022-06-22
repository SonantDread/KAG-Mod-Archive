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
	
	//this.Tag("visible");

	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 50, 100, 50));

	this.set_s8("behavior",0);
	
	this.set_u32("created",getGameTime());
}

void onTick(CBlob@ this)
{
	/*
	if(isNight() && getGameTime() % 100 == 0) //Slowly heal during night time
	{
		if(isServer() && this.getHealth()<20){
			this.server_SetHealth(this.getHealth() + 1);
			//print(""+this.getHealth());
		}
	}*/
	
	if(this.get_u32("created")+30*60 < getGameTime() || !isNight()){ //If it's not night or 1 minute passes, get out
		this.AddForce(Vec2f(0,-10));
		if(this.getPosition().y < -640)this.server_Die();
	} else {
		CBlob @target = null;
		CBlob@[] humanoids;
		getBlobsByName("humanoid", humanoids);
		f32 distance = 1280; //human with smallest distance
			
		for(int i = 0;i < humanoids.length;i++){
			CBlob @h = humanoids[i];
			if(h !is null)
			if(h.getPlayer() !is null)
			{
				if(h.getDistanceTo(this) < distance)
				{
					@target = h;
					distance = h.getDistanceTo(this);
				}
			}
		}
		if(distance <= 16)
		{
			this.set_s8("behavior", 1); //Cause Chaos
			//if(isServer())this.Sync("behavior",true); //does this needs to be synced?
		}
		else if(distance > 100)
		{
			this.set_s8("behavior", 0); //Go To Human
			//if(isServer())this.Sync("behavior",true); //does this needs to be synced?
		}

		if(this.get_s8("behavior") == 0) //Find human and get in range (otherwise random movement to find a human)
		{
			if(target is null){
				RandomMovement(this, 5, false);
			} else { //Go to target
				if(getGameTime() % 3 == 0){
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
			if(this.get_s8("behavior") == 1) { //Pull objects in and drag them along (still random movement)

				CBlob@[] blobsInRadius;	 
				f32 radius = 64.0f;
				if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
				{
					for (uint i = 0; i < blobsInRadius.length; i++)
					{
						CBlob@ b = blobsInRadius[i];
						if(b.getShape() !is null)
						if(!b.getShape().isStatic())
						if(b.getName() != "stickfire")
						if(!b.hasTag("ghost")) //Wont pull ghosts
						{
							Vec2f vec = this.getPosition()-b.getPosition();
							vec.Normalize();
							f32 mass = b.getMass();
							//if(b.getDistanceTo(this) < 16)
							//{
							//	b.AddForce(-(b.getVelocity()-this.getVelocity())*0.3f);
							//}
							b.setVelocity(b.getVelocity()+vec*0.5f);
						}
					}
				}
			}
			RandomMovement(this, 3, true);

		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("ghost");
}

/*
void onCollision( CBlob@ this, CBlob@ blob, bool solid ){
	if(blob !is null){
		if(blob.getName()=="ghost" || blob.getName() == "poltergeist")
		{
			if(isServer()){
				this.server_SetHealth(this.getHealth() - 1); //takes damage on collision with other ghost entities
				//print("Health "+this.getHealth());
				if(this.getHealth() <= 0)
				{
					this.server_Die();
				}
			} 
			for(int i = 0;i < 5.0f;i++){
				int dir = XORRandom(360);
				CParticle@ p = ParticlePixel(this.getPosition(), getRandomVelocity(dir,1+XORRandom(1),0),SColor(255,100,100,255),true, 30);
				if(p !is null){
					p.fastcollision = true;
					p.gravity = Vec2f(0,0);
					p.bounce = 0;
					p.lighting = false;
				}
			}
		}
	}
}*/

void RandomMovement(CBlob@ this, int tickrate, bool onlyUp)
{
	s8 hori = this.get_s8("hori");
	s8 verti = this.get_s8("verti");
	if(getGameTime() % 10 == 0){
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
		
		if(onlyUp){
			if(verti > -5)verti -= 1;
		} else {
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
		}
		
		if(this.getPosition().y < 0)verti = 5;
		
		this.set_s8("hori",hori);
		this.set_s8("verti",verti);
	}
			
			
			
	if(getGameTime() % tickrate == 0){
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
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if(blob.getPlayer() !is null){
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		if (!left && right && !up && !down)this.SetFrameIndex(0);
		if (left && !right && !up && !down)this.SetFrameIndex(1);
	} else {
		Vec2f vel = blob.getVelocity();
		if(vel.x > 0)this.SetFrameIndex(0);
		if(vel.x < 0)this.SetFrameIndex(1);
	}
	
	if(getGameTime() % 10 == 0){
		this.SetZ(1000.0f);
		
		if(!blob.hasTag("visible"))this.SetVisible(false);
		else {
			this.SetVisible(true);
			this.setRenderStyle(RenderStyle::normal);
			blob.Untag("visible");
		}
		
		if(getLocalPlayerBlob() !is null){
			if(getLocalPlayerBlob().hasTag("spirit_view")){
				if(this.isVisible() == false){
					this.SetVisible(true);
					this.setRenderStyle(RenderStyle::additive);
				}
			}
		}
	}
}