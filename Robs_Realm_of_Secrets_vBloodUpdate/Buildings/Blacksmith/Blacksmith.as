// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 4));
	this.set_string("shop description", "Build");
	this.set_u8("shop icon", 15);

	
	AddIconToken("$gold_golem_icon$", "GoldGolemNoCore.png", Vec2f(32, 32), 0);
	AddIconToken("$cauldron_icon$", "Couldron.png", Vec2f(24, 24), 0);
	AddIconToken("$blooddagger_icon$", "BloodDagger.png", Vec2f(16, 16), 0);
	AddIconToken("$hardsword_icon$", "HardSword.png", Vec2f(16, 16), 0);
	
	
	{
		ShopItem@ s = addShopItem(this, "Gold Golem", "$gold_golem_icon$", "gold_golem", "A defensive mechanical unit.", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 200);
	}
	{
		ShopItem@ s = addShopItem(this, "Cauldron", "$cauldron_icon$", "couldron", "A pot for cooking.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Hardened Sword", "$hardsword_icon$", "hardsword", "A stronger sword for stronger men.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Blood Dirge", "$blooddagger_icon$", "blooddagger", "A self sacrifical dagger.", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "blob", "steak", "Meat", 1);
	}
	
	this.addCommandID("buildershop");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
	
	if(this.isOverlapping(caller) && caller.getName() == "builder" && caller.getTeamNum() == this.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,-8), this, this.getCommandID("buildershop"), "Downgrade to buildershop.", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
	if (cmd == this.getCommandID("buildershop"))
	{
		if(getNet().isServer()){
			server_CreateBlob("buildershop",this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
		this.getSprite().PlaySound("/Construct.ogg");
		this.getSprite().getVars().gibbed = true;
		
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}