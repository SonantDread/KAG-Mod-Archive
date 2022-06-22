#include "CommonParticles.as"
#include "AbilityCommon.as"
#include "Health.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	//shape.getConsts().mapCollisions = false;
	shape.SetGravityScale(0.0f);
	
	this.Tag("no hands");
	this.Tag("flesh");
	
	this.set_s16("darkness",1000);
	
	this.Tag("darkness_sworn");
	
	addAbility(this,Ability::SummonDarkGreatBlade);
	//addAbility(this,Ability::SummonGreaterDarkStaff);
	
	for(int i = 0;i < 8;i++){
		Vec2f pos = Vec2f(32,0);
		pos.RotateByDegrees(i*45);
		CBlob @child = server_CreateBlob("dark_explosion",this.getTeamNum(),this.getPosition()+pos);
		if(child !is null){
			child.set_u8("amount",6+XORRandom(2));
			child.set_s16("direction",i*45);
			child.set_u32("spawntime",getGameTime()+XORRandom(10));
		}
	}
}

void onTick(CBlob@ this)
{
	if(this.get_s16("darkness") > 0){
		if(this.isKeyJustPressed(key_action2))if(this.get_s16("darkness") > 30){
			Vec2f vec = this.getAimPos()-this.getPosition();
			vec.Normalize();
			CBlob @child = server_CreateBlob("dark_explosion",this.getTeamNum(),this.getPosition());
			if(child !is null){
				child.set_u8("amount",10);
				child.set_s16("direction",-vec.AngleDegrees());
			}
			this.sub_s16("darkness",20);
		}
	
		if(this.isKeyPressed(key_action1)){
			if(isServer() && ((getGameTime() % 5) == 0 || this.isKeyJustPressed(key_action1))){
				Vec2f vec = this.getAimPos()-this.getPosition();
				vec.Normalize();
				this.sub_s16("darkness",1);
				for(int i= -2;i <= 2;i++){
					Vec2f start = Vec2f((1-Maths::Abs(i))*8.0f,i*12.0f+XORRandom(16)-8);
					start.RotateByDegrees(-vec.AngleDegrees());
					CBlob @eco = server_CreateBlob("eco",this.getTeamNum(),this.getPosition()+start);
					if(eco !is null){
						eco.setVelocity(vec*4.0f);
					}
				}
			}
		}
		
		if((getGameTime() % 30) == 0){
			if(this.get_string("default_hp_sprite") != "DarkHeartHUD.png")this.set_string("default_hp_sprite","DarkHeartHUD.png");
			if(isServer() && this.get_s16("darkness") >= 40 && getHealth(this) <= 9){
				server_Heal(this,1.0f);
				this.sub_s16("darkness",20);
			}
		}
	} else {
		if(isServer())this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	
	this.getSprite().PlaySound("/splat", 2.0f, 0.70f);
	this.getSprite().PlaySound("/thud", 2.0f, 0.70f);
	
	for(int i = 0;i < 20;i++)cpr(worldPoint+(Vec2f(XORRandom(16),0).RotateBy(XORRandom(360))),Vec2f(XORRandom(7)-3,XORRandom(7)-3)*0.5f+velocity*0.1f);
	
	return damage;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound("/Thunder1", 2.0f, 0.70f);
	for(int i = 0;i < 50;i++)cpr(this.getPosition()+(Vec2f(XORRandom(32),0).RotateBy(XORRandom(360))),Vec2f(XORRandom(7)-3,XORRandom(7)-3));
	if(isServer() && !this.hasTag("ded")){
		server_CreateBlob("dark_core",this.getTeamNum(),this.getPosition());
		this.Tag("ded");
	}
}