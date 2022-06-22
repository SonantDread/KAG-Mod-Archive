/*
-Air:
unstab: makes everyone lighter/restores breath
stable: FORCEFIELD
-Fire:
unstab: warms everyone if they are under norm temp
stable: FIREWAVE
-Nature:
unstab: heal all
stable: INDESTRUCTABLE WORLD
-Blood:
unstab: heal team, hurt enemies
stable: BLOOD CHAINS
-Life:
unstab: generates wisp kisses in an area
stable: SOUL STEALS AND BLASTS ORBS
-Death:
unstab: lets you see ghosts
stable: ANTIGHOST FIELD
-Golden:
unstab: heal everyone, hurt undead
stable: INVINCIBILITY
-Dark:
unstab: infects non-evil
stable: KILLS EVERYTHING NOT EVIL
*/

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Hitters.as";
#include "Health.as";

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 80.0f;

	this.Tag("builder always hit");
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.set_u8("shop button radius", 32);
	this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$flow_icon$", "Runes.png", Vec2f(8, 8), 0);
	AddIconToken("$heat_icon$", "Runes.png", Vec2f(8, 8), 1);
	AddIconToken("$nature_icon$", "Runes.png", Vec2f(8, 8), 2);
	AddIconToken("$blood_icon$", "Runes.png", Vec2f(8, 8), 3);
	AddIconToken("$soul_icon$", "Runes.png", Vec2f(8, 8), 4);
	AddIconToken("$spirit_icon$", "Runes.png", Vec2f(8, 8), 5);
	AddIconToken("$light_icon$", "Runes.png", Vec2f(8, 8), 6);
	AddIconToken("$dark_icon$", "Runes.png", Vec2f(8, 8), 7);
	
	{
		ShopItem@ s = addShopItem(this, "Flow Ward", "$flow_icon$", "flow", "Infuse this ward with flow.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Heat Ward", "$heat_icon$", "heat", "Infuse this ward with heat.");
		AddRequirement(s.requirements, "blob", "lantern", "Lantern", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Nature Ward", "$nature_icon$", "nature", "Infuse this ward with nature.");
		AddRequirement(s.requirements, "blob", "seed", "Seed", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Blood Ward", "$blood_icon$", "blood", "Infuse this ward with blood.");
		AddRequirement(s.requirements, "blob", "heart", "Heart", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Soul Ward", "$soul_icon$", "soul", "Infuse this ward with lifeforce.");
		AddRequirement(s.requirements, "blob", "wisp", "Wisp", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Spirit Ward", "$spirit_icon$", "spirit", "Infuse this ward with spirit.");
		AddRequirement(s.requirements, "blob", "ghost_shard", "Ectoplasm", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Light Ward", "$light_icon$", "light", "Band this ward with gold.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Dark Ward", "$dark_icon$", "dark", "Infuse this ward with corruption.");
		AddRequirement(s.requirements, "blob", "dark_core", "Darkness", 1);
		s.spawnNothing = true;
	}
	
	this.set_s8("factor",0);
	this.set_u8("mat",0);
	
	this.addCommandID("upgrade");
	this.addCommandID("infuse");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getCarriedBlob() is this)
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
		
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(caller.getCarriedBlob() !is null){
		if(this.get_u8("factor") == 0){
			if(caller.getCarriedBlob().getName() == "wisp")caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("infuse"), "Infuse with wisp", params);
		}
	} else {
		if(this.get_u8("mat") == 0 && caller.hasBlob("mat_stone", 100))caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with 100 stone", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		
		u16 item;
		if(!params.saferead_netid(item))return;
		
		string name = params.read_string();
		if (caller !is null)
		{
			if(!this.hasTag("shop disabled")){
				if(name == "flow")this.set_s8("factor",1);
				if(name == "heat")this.set_s8("factor",2);
				if(name == "nature")this.set_s8("factor",3);
				if(name == "blood")this.set_s8("factor",4);
				if(name == "soul")this.set_s8("factor",5);
				if(name == "spirit")this.set_s8("factor",6);
				if(name == "light")this.set_s8("factor",7);
				if(name == "dark")this.set_s8("factor",8);
				this.Tag("shop disabled");
				if(isServer())this.Sync("factor",true);
			}
			
		}
	}
	
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(isServer()){
				if(this.get_u8("mat") == 0){
					if(caller.hasBlob("mat_stone", 100)){
						caller.TakeBlob("mat_stone", 100);
						this.set_u8("mat",1);
						this.Sync("mat",true);
						this.server_SetHealth(this.getInitialHealth()*2.0f);
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("infuse"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(isServer()){
				if(this.get_s8("factor") == 0 && caller.getCarriedBlob() !is null){
					if(caller.getCarriedBlob().getName() == "wisp"){
						caller.getCarriedBlob().server_Die();
						this.set_s8("factor",5);
						this.Sync("factor",true);
					}
				}
			}
		}
	}
	
	UpdateFrame(this.getSprite());
}

void onTick(CBlob@ this){
	bool active = true;
	
	if(this.isInInventory()){
		active = false;
		if(this.getInventoryBlob() !is null){
			if(this.getInventoryBlob().hasTag("carries_wards")){
				active = true;
			}
		}
	}
	
	if(active)
	if(this.get_s8("factor") != 0){
		Aura(this,this.get_s8("factor"));
	}
	
	if(!this.hasTag("lightchecked")){
		if(this.get_s8("factor") != 0){
			if(this.get_s8("factor") == 2){
				this.SetLight(true);
				this.SetLightRadius(64.0f);
				this.SetLightColor(SColor(255, 255, 220, 151));
			}
			this.Tag("lightchecked");
		}
	}
}

void UpdateFrame(CSprite@ this)
{
	this.getBlob().inventoryIconFrame = this.getBlob().get_u8("mat")*9+this.getBlob().get_s8("factor");
	this.SetFrame(this.getBlob().inventoryIconFrame);
}

void Aura(CBlob@ this, int factor){

	f32 power = 1;
	f32 wards = 1;
	f32 radius = 64.0f;

	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "ward" && b !is this){
				wards += 1.0f;
			}
			if(b.hasTag("carries_wards")){
				CInventory@ inv = b.getInventory();
				if(inv !is null){
					for (int j = 0; j < inv.getItemsCount(); j++)
					{
						CBlob@ item = inv.getItem(j);
						if(item !is null && item !is this){
							if(item.getName() == "ward"){
								wards += 1.0f;
							}
						}
					}
				}
			}
		}
	}
	
	power = power/wards;
	
	//print("power:"+power);
	
	if(factor == 1){
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.hasTag("alive") || b.hasTag("animated"))//if(b.getTeamNum() != this.getTeamNum())
				{
					b.set_u8("air_count",180);
					Vec2f vel = b.getVelocity();
					//if (vel.y > 0.5f)
					{
						b.AddForce(Vec2f(0, -15.0f*power));
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,200,200,255),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 2){
		if(getGameTime() % 10.0f/power == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), power*radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.exists("temperature"))//if(b.getTeamNum() != this.getTeamNum())
					{
						if(b.get_s8("temperature") < 50){
							b.add_s8("temperature",1);
						}
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f*power;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(power*radius);
			if(i < 3)dis = power*radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,255,200,100),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	
	if(factor == 3){
		if(getGameTime() % 45 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					{
						if(getHealth(b) < 10)server_Heal(b,power*0.5f);
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,225,255,100),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 4){
		if(getGameTime() % 45 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("flesh")){
						if(b.getTeamNum() == this.getTeamNum()){
							if(getHealth(b) < 10)server_Heal(b,power*0.25f);
						} else {
							this.server_Hit(b, b.getPosition(), Vec2f(0,0),power*0.25f, Hitters::nothing);
						}
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,255,50,25),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 5){
		if(getGameTime() % 45 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("flesh")){
						if(b.getTeamNum() != this.getTeamNum()){
							this.server_Hit(b, b.getPosition(), Vec2f(0,0),power*0.5f, Hitters::nothing);
						}
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,100,255,255),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 6){
		if(getGameTime() % 45 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.hasTag("undead")){
						if(getHealth(b) < 10)server_Heal(b,power*0.5f);
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,225,255,225),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 7){
		if(getGameTime() % 45 == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(!b.hasTag("undead")){
						if(getHealth(b) < 10)server_Heal(b,power*0.25f);
					} else {
						this.server_Hit(b, b.getPosition(), Vec2f(0,0),power*1.0f, Hitters::nothing, true);
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,255,255,150),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
	
	if(factor == 8){
		if(getGameTime() % 60/power == 0){
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.exists("darkness"))
					if(b.get_s16("darkness") < 100){
						b.add_s16("darkness",1);
					}
				}
			}
		}
		
		for(int i = 0;i < 5.0f;i++){
			int dir = XORRandom(360);
			int dis = XORRandom(radius);
			if(i < 3)dis = radius;
			CParticle@ p = ParticlePixel(getRandomVelocity(dir,dis,0) + this.getPosition(), getRandomVelocity(dir-90*(XORRandom(2)*2-1),1+XORRandom(1),0),SColor(255,50,0,50),true, 30);
			if(p !is null){
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 0;
				p.lighting = false;
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle"))); // boat
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() == blob.getTeamNum();
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}