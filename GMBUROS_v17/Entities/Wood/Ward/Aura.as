

#include "Hitters.as";
#include "Magic.as";
#include "FireCommon.as";
#include "LimbsCommon.as";
#include "EnchantCommon.as";

void onInit(CBlob@ this){
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 80.0f;
	
	this.set_u16("blood_charges",0);
}

void onTick(CBlob@ this){
	if(this.isInInventory() || this.get_u8("gem") <= 0){
		return;
	}
	
	int rad = getWardRadius(this);
	this.getCurrentScript().runProximityRadius = f32(rad)*1.5f;

	int factor = this.get_s8("factor");
	f32 power = this.get_f32("power");
	if(factor != 0 && power > 0){
		AuraParticles(this,factor,rad);
		Aura(this,factor,rad,power);
	}
}

int getWardRadius(CBlob @this){
	f32 size = this.get_u8("gem");
	int mat = this.get_u8("mat");
	
	if(mat == 0)size += 1; //Wood
	if(mat == 3)size += 4; //Gold
	if(mat == 4)size += 2; //Lecit
	
	if(size >= 2)if(this.isAttached())size -= 1;
	
	return size*16.0f;
}

/*
Gold ward:
	damages undead, converts spirit cores into soul cores
*/

void Aura(CBlob@ this, int factor, int radius, f32 power){

	bool unstable = this.hasTag("unstable");
	
	if(unstable){
		if(XORRandom(200) == 0)MagicExplosion(this.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 1.0f);
	}
	
	if(factor == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null){
					if(!unstable){
						if(b.hasTag("alive") || b.hasTag("animated")){
							if(b.isInWater()){
								if(b.get_u8("air_count") < 178 && power >= 2){
									b.add_u8("air_count",2);
									power -= 2;
									
									Vec2f pos = Vec2f(1,0);
									int r = XORRandom(360);
									pos.RotateByDegrees(r);
									CParticle@ p = ParticlePixel(b.getPosition()+pos*16+Vec2f(0,-4), -pos*4,getFactorColour(1),true, 15);
									if(p !is null){
										p.fastcollision = true;
										p.gravity = Vec2f(0,0);
										p.bounce = 0;
										p.lighting = false;
									}
								}
							} else {
								if(power >= 3){
									Vec2f vel = b.getVelocity();
									if(!b.isKeyPressed(key_down)){
										if(!b.isOnGround())power -= 3;
										if(vel.y > 0.0f || b.isKeyPressed(key_up)){
											if(vel.y > 0.0f)b.AddForce(Vec2f(0, -50.0f));
											else b.AddForce(Vec2f(0, -30.0f));
											
											int side = XORRandom(16)-8;
											CParticle@ p = ParticlePixel(b.getPosition()+Vec2f(side,16-Maths::Abs(side)), Vec2f(0,-2),getFactorColour(1),true, 10);
											if(p !is null){
												p.fastcollision = true;
												p.gravity = Vec2f(0,0);
												p.bounce = 0;
												p.lighting = false;
											}
										}
									}
								}
							}
						}
					} else {
						if(XORRandom(30) == 0 && power > 10){
							Vec2f force = Vec2f(5,0);
							force.RotateByDegrees(-XORRandom(180));
							b.setVelocity(force);
							power -= 10;
						}
					}
				}
			}
		}
	}
	
	
	if(factor == 2){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b !is null){
					if(!unstable){
						if(b.hasTag("alive") || b.hasTag("animated")){
							if(!b.isInWater()){
								if(power >= 1){
									b.Tag("fire_immune");
									power -= 1;
									if(isServer()){
										b.Untag(burning_tag);
										b.Sync(burning_tag, true);

										b.set_s16(burn_timer, 0);
										b.Sync(burn_timer, true);
									}
									
									Vec2f pos = Vec2f(1,0);
									Vec2f vel = Vec2f(1,0);
									int r = XORRandom(360);
									pos.RotateByDegrees(r);
									vel.RotateByDegrees(r+60);
									CParticle@ p = ParticlePixel(b.getPosition()+pos*12, -vel*0.5f,getFactorColour(2),true, 30);
									if(p !is null){
										p.fastcollision = true;
										p.gravity = Vec2f(0,0);
										p.bounce = 0;
										p.lighting = false;
										p.collides = false;
									}
								}
							}
						}
					} else 
					if(b !is this && power >= 10 && getGameTime() % 30 == 0){
						if(b.hasTag("hard_liquid_blob"))b.Tag("heated");
						else if(!b.hasTag(burning_tag)){this.server_Hit(b, b.getPosition(), Vec2f(0,0), 0.5f, Hitters::fire, true);power -= 10;}
						
						if(XORRandom(200) == 0)MagicExplosion(b.getPosition(), "UnstableMagic"+XORRandom(4)+".png", this.get_u8("gem"));
					}
				}
			}
		}
	}
	
	if(factor == 3){
		if(getGameTime() % 12 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++){
					CBlob@ b = blobsInRadius[i];
					if(b !is null)if(b.getName() == "humanoid"){
						if(unstable)
						if(power >= 30){
							u32 Enchants = b.get_u32("enchants");
							if(!hasEnchant(Enchants,Enchantment::Nature)){
								Enchants = addEnchant(Enchants,Enchantment::Nature);
								b.set_u32("enchants",Enchants);
								if(isServer())b.Sync("enchants",true);
								power -= 30;
							}
						}
						
						LimbInfo@ limbs;
						if(b.get("limbInfo", @limbs)){
							for(int j = 0;j < LimbSlot::length;j++){
								if(getLimb(limbs,j) == BodyType::Wood || isFlesh(getLimb(limbs,j))){
									if(power >= 6){
										if(unstable){
											if(power >= 30+6 && XORRandom(10) == 0){
												morphLimb(b, j, BodyType::Wood);
												power -= 30;
											}
											if(getLimb(limbs,j) == BodyType::Wood){
												if(getLimbHealth(limbs,j) < getLimbMaxHealth(j,getLimb(limbs,j))){
													healLimb(limbs,j,0.20f);
													power -= 6;
												}
											}
											if(isFlesh(getLimb(limbs,j))){
												hitLimb(b, j, 0.20f, Hitters::water);
												power -= 6;
											}
										} else {
											if(getLimbHealth(limbs,j) < getLimbMaxHealth(j,getLimb(limbs,j))){
												healLimb(limbs,j,0.20f);
												power -= 6;
											}
										}
									}
									if(getLimb(limbs,j) == BodyType::None && getLimb(limbs,LimbSlot::Torso) == BodyType::Wood){
										if(power >= 150){
											morphLimb(b, j, BodyType::Wood);
											power -= 150;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	if(factor == 4){
		if(getGameTime() % 30 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++){
					CBlob@ b = blobsInRadius[i];
					if(b !is null)if(b.getName() == "humanoid"){
						LimbInfo@ limbs;
						if(b.get("limbInfo", @limbs)){
							for(int j = 0;j < LimbSlot::length;j++){
								if(!unstable || (b.getPlayer() is null && b.hasTag("alive"))){
									if(isFlesh(getLimb(limbs,j))){
										if(power >= 30){
											if(getLimbHealth(limbs,j) < getLimbMaxHealth(j,getLimb(limbs,j))){
												healLimb(limbs,j,1);
												power -= 30;
											}
										}
									}
									if(getLimb(limbs,j) == BodyType::Zombie){
										if(power >= 30){
											morphLimb(b, j, BodyType::Flesh);
											power -= 30;
										}
									}
									if(getLimb(limbs,j) == BodyType::Ghoul){
										if(power >= 30){
											morphLimb(b, j, BodyType::Cannibal);
											power -= 30;
										}
									}
									if(getLimb(limbs,j) == BodyType::None && isLivingFlesh(getLimb(limbs,LimbSlot::Torso))){
										if(power >= 150){
											morphLimb(b, j, BodyType::PinkFlesh);
											power -= 150;
										}
									}
								} else {
									if(power >= 30 && XORRandom(3) == 0){
										if(isFlesh(getLimb(limbs,j))){
											hitLimb(b, j, 2.0f, Hitters::water);
											power -= 30;
											if(isServer())this.add_u16("blood_charges",1);
										}
									}
								}
							}
						}
					}
				}
			}
			if(isServer()){
				if(this.get_u16("blood_charges") >= 50){
					this.sub_u16("blood_charges",50);
					CBlob @fleshling = server_CreateBlob("humanoid",-1,this.getPosition());
					LimbInfo@ limbs;
					if(fleshling.get("limbInfo", @limbs)){
						int body = BodyType::PinkFlesh;
						setUpLimbs(limbs,body,body,CoreType::Beating,body,body,body,body);
					}
					if(fleshling.getBrain() !is null)fleshling.getBrain().server_SetActive(true);
				}
			}
		}
	}

	if(factor == 5){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++){
				CBlob@ b = blobsInRadius[i];
				if(b !is null){
					if(b.getName() == "humanoid"){
						if(power >= 1){
							b.set_u32("immortality",getGameTime()+30);
							if(b.hasTag("pure_life_save")){
								power--;
								b.Untag("pure_life_save");
							}
						}
						
						if(unstable){
							if(power >= 30)
							if(isServer() && getGameTime() % 30 == 0){
								this.server_Hit(b, b.getPosition(), Vec2f(0,0), 0.5f, Hitters::burn, true);
								power -= 30;
							}
						}
					}
				}
			}
		}
	}

	if(factor == 6){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++){
				CBlob@ b = blobsInRadius[i];
				if(b !is null){
					if(power >= 1){
						if(b.getName() == "humanoid"){
							if(!unstable){
								b.Tag("spirit_infested");
								power--;
							} else {
								if(b.getPlayer() is null && b.getBrain() !is null)
								if(!b.hasTag("alive") && !b.hasTag("animated")  && !b.hasTag("spirit_infested")){
									b.Tag("spirit_infested");
									if(isServer())b.getBrain().server_SetActive(true);
								}
							}
						}
						if(b.hasTag("ghost")){
							b.Tag("visible");
							power--;
						}
					}
				}
			}
		}
	}
	
	if(factor == 7){
		if(getGameTime() % 12 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++){
					CBlob@ b = blobsInRadius[i];
					if(b !is null)if(b.getName() == "humanoid"){
						LimbInfo@ limbs;
						if(b.get("limbInfo", @limbs)){
							for(int j = 0;j < LimbSlot::length;j++){
								if(getLimb(limbs,j) != BodyType::Gold){
									if(power >= 6){
										if(getLimbHealth(limbs,j) >= getLimbMaxHealth(j,getLimb(limbs,j))){
											if(unstable)
											if(power >= 6+30 && XORRandom(10) == 0){
												morphLimb(b, j, BodyType::Gold);
												power -= 30;
											}
										} else {
											healLimb(limbs,j,0.20f);
											power -= 6;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	this.set_f32("power",power);
}

void AuraParticles(CBlob@ this, int factor, int radius){

	SColor Colour = getFactorColour(factor);
	SColor GemColour = SColor(255,200,200,255);

	int Gem = this.get_u8("gem");
	
	if(!this.hasTag("unstable")){
		if(Gem == 1)GemColour = SColor(255,100,100,200);
		if(Gem == 2)GemColour = SColor(255,150,200,100);
		if(Gem == 3)GemColour = SColor(255,230,230,110);
	} else {
		GemColour = SColor(255,255,10,10);
		if(XORRandom(3) == 0)Colour = GemColour;
	}

	for(int i = 0;i < (f32(radius)/10.0f);i++){
		int dir = XORRandom(360);
		int dis = XORRandom(radius);
		SColor c = Colour;
		if(i == 0){
			dis = 8;
			c = GemColour;
		} else
		if(i < 4)dis = radius;
		CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),c,true, 20);
		if(p !is null){
			p.fastcollision = true;
			p.gravity = Vec2f(0,0);
			p.bounce = 0;
			p.lighting = false;
		}
	}
}

SColor getFactorColour(int factor){

	switch(factor){
		case 1:
			return SColor(255,200,200,255);
		break;
		
		case 2:
			return SColor(255,255,200,100);
		break;
		
		case 3:
			return SColor(255,225,255,100);
		break;
		
		case 4:
			return SColor(255,255,50,25);
		break;
		
		case 5:
			return SColor(255,100,255,255);
		break;
		
		case 6:
			return SColor(255,225,255,225);
		break;
		
		case 7:
			return SColor(255,255,255,150);
		break;
		
		case 8:
			return SColor(255,50,0,50);
		break;
		
	}
	
	return SColor(255,225,255,225);;

}