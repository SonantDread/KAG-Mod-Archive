#include "Hitters.as";
#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";


void onInit(CBlob@ this)
{
	string configName = this.getName();

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", this.getInventoryName());
	this.set_u8("shop icon", 15);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$icon_repair$", "InteractionIcons.png", Vec2f(32, 32), 15);
	{
		ShopItem@ s = null;
	
		if (configName == "caravelwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "Caravel", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 750);
			AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		}
		else if (configName == "carwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "car", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
			AddRequirement(s.requirements, "coin", "", "Coins", 250);
		}
		else if (configName == "armoredcarwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "armoredcar", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
			AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 20);
			AddRequirement(s.requirements, "coin", "", "Coins", 750);
		}
		else if (configName == "armoredbomberwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "armoredbomber", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
			AddRequirement(s.requirements, "coin", "", "Coins", 100);
		}
		else if (configName == "bomberwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "bomber", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
			AddRequirement(s.requirements, "coin", "", "Coins", 50);
		}
		else if (configName == "triplanewreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "triplane", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
			AddRequirement(s.requirements, "coin", "", "Coins", 100);
		}
		else if (configName == "steamtankwreck")
		{
			@s = addShopItem(this, "Repair", "$icon_repair$", "steamtank", "Repair this badly damaged vehicle.");	
			
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
			AddRequirement(s.requirements, "coin", "", "Coins", 100);
		}
		
		if (s !is null)
		{
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			s.spawnNothing = true;
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		this.getSprite().PlaySound("/ConstructShort.ogg");
		
		if (isServer())
		{
			CBlob@ blob = server_CreateBlob(name, callerBlob.getTeamNum(), this.getPosition());
			this.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getTickSinceCreated() < 60) return 0;
	
	switch (customData)
	{
		case Hitters::fall:
		case Hitters::fire:
		case Hitters::burn:
			return damage * 0.10f;
	}
	
	return damage;
}

void onTick(CBlob@ this)
{
	if(!isClient()){return;}
	u32 tick = this.getTickSinceCreated();
	if (tick < 900 && getGameTime() % 10 == 0)
	{
		ParticleAnimated("LargeSmoke", this.getPosition() + Vec2f(XORRandom(32) - 16, XORRandom(16) - 8), Vec2f(0.5f, -0.75f), 0, 1.00f + (XORRandom(10) * 0.1f), 10 + XORRandom(10), 0, false);
	}
}