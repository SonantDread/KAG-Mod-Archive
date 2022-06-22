// Stick Fire

#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "FireParticle.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.set_u16("wood_amount", 99);
	this.SetLight(true);
	this.SetLightRadius(0.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
	this.set_u16("smoke_buildup", 0);

	this.Tag("fire source");
	//this.server_SetTimeToDie(60*3);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.get_u16("wood_amount") > 50)this.sub_u16("wood_amount", 50);
	else this.server_Die();
	
	if (hitterBlob !is this)
	{
		this.getSprite().PlayRandomSound("/WoodHit", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		makeGibParticle("/GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
					1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	
	//ignore all damage
	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	if(this.get_u16("wood_amount") < 10*50){
		if (blob.getName() == "stick")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 25);
			blob.server_Die();
		} else
		if (blob.getName() == "log")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 50);
			blob.server_Die();		
		} else
		if (blob.getName() == "mat_wood")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", blob.getQuantity());
			blob.server_Die();		
		}  else
		if (blob.getName() == "log_cage")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 50); //Made from 1 log
			blob.server_Die();		
		} else
		if (blob.getName() == "core" && blob.get_u8("level") == 0) //Only burns wooden cores if they are level 0 (as in made from wood)
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 50); //Made from 1 log
			blob.server_Die();		
		}  else
		if (blob.getName() == "ward" && blob.get_u8("mat") == 0 && blob.get_s8("factor") != 2) //Only burns non stone non fire wards 
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 25); //Made from 1 stick
			blob.server_Die();		
		} else
		if (blob.getName() == "mallet")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 75); //Made from a stick and a log
			blob.server_Die();		
		} else
		if (blob.getName() == "lantern")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 50); //Made from 50 wood
			blob.server_Die();		
		} else
		if (blob.getName() == "cloth_shirt")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 25); //low burn value due to unknown recepie
			blob.server_Die();		
		} else
		if (blob.getName() == "cloth")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 25); //low burn value due to unknown recepie
			blob.server_Die();		
		} else
		if (blob.getName() == "fibre")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			this.add_u16("wood_amount", 25); //low burn value due to unknown recepie
			blob.server_Die();		
		}
		/*
		else
		if(getNet().isServer())
		if(blob.hasTag("flesh")){
			
			f32 burn = f32(this.get_u16("wood_amount"))/50.0f*0.25f;
			
			if(this.get_u16("wood_amount") < 300)burn = 0.0f;
			
			if(burn > 0.0f)this.server_Hit(blob, this.getPosition(), Vec2f(0,0), 2.0, Hitters::burn, true);
		}*/
	}
}
void onTick(CBlob@ this)
{
// make this smoke more if it's getting low
	this.getSprite().SetEmitSoundPaused(this.get_u16("wood_amount") < 50);
	
	if (this.get_u16("wood_amount") / 50 < 10) this.getSprite().SetFrame(this.get_u16("wood_amount") / 50);
	else this.getSprite().SetFrame(10);
	
	if (this.get_u16("wood_amount") < 150)
	{
		if (XORRandom(2) == 0)
		{
			makeSmokeParticle(this.getPosition()+Vec2f(0,1), -0.05f);
		}
	}
	if (this.get_u16("wood_amount") >= 150)
	{
		if (XORRandom(5) == 0)
		{
			makeSmokeParticle(this.getPosition(), -0.05f);
		}
		for(int i = 0; i < this.get_u16("wood_amount")/50+1; i+= 1){
			makeFireParticle(this.getPosition() + Vec2f(XORRandom(16)-8,(-XORRandom(16)*(i/10.0f))+6));
		}

		
		
		// TFlippy's Edit, added "smoke" spawning

		if (getNet().isServer())
		{
			this.add_u16("smoke_buildup", f32(this.get_u16("wood_amount"))/50.0f);
			
			if(this.get_u16("smoke_buildup") > 100)
			{
				this.sub_u16("smoke_buildup",100);
				
				CBlob@[] blobs;
				getMap().getBlobsInBox(this.getPosition() + Vec2f(4, -4), this.getPosition() + Vec2f(-4,4), @blobs);
			
				int counter = 0;
			
				for (int i = 0; i < blobs.length; i++) if (blobs[i].hasTag("gas")) counter++;

				//if (counter < 4)
				{
					CBlob@ smokey = server_CreateBlobNoInit("smoke");
					smokey.setPosition(this.getPosition() + Vec2f(0, -1));
					smokey.setVelocity(Vec2f((XORRandom(1000)-500.0f)/2000.0f,0));
					smokey.server_setTeamNum(-1);
					smokey.Init();
				}
				
				// this.set_u32("next_smoke", getGameTime() + 15);
			}
		}
	}
			
	if (this.isInWater())
	{
		this.getSprite().Gib();
		this.server_Die();
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onInit(CSprite@ this)
{
	// this.SetZ(-50); //background
	this.SetZ(20); //foreground

	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);

	if (fire !is null)
	{
		{
			fire.SetRelativeZ(100);
			{
				Animation@ anim = fire.addAnimation("bigfire", 6, true);
				anim.AddFrame(1);
				anim.AddFrame(2);
				anim.AddFrame(3);
			}
			{
				Animation@ anim = fire.addAnimation("smallfire", 6, true);
				anim.AddFrame(4);
				anim.AddFrame(5);
				anim.AddFrame(6);
			}
		fire.SetVisible(true);
		}
	}
}
void onTick(CSprite@ this)
{
    CSpriteLayer@ fire = this.getSpriteLayer("fire_animation_large");
	if(fire !is null){
		CBlob @blob = this.getBlob();
		if (blob.get_u16("wood_amount") >= 50 && blob.get_u16("wood_amount") < 150)
			fire.SetVisible(true);
		else
			fire.SetVisible(false);
	}
}