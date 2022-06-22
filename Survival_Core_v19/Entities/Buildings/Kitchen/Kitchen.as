// Quarters.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "StandardControlsCommon.as"
#include "FireParticle.as";
#include "Health.as";

void onInit(CSprite@ this)
{
	CSpriteLayer@ fire = this.addSpriteLayer( "fire", "Quarters.png", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {48,49,50,51};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(-7, 6));
		fire.SetRelativeZ(0.1f);
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	
	this.getSprite().SetEmitSound("CampfireSound.ogg");

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// ICONS
	AddIconToken("$quarters_beer$", "Kitchen.png", Vec2f(24, 24), 7);
	AddIconToken("$quarters_meal$", "Kitchen.png", Vec2f(48, 24), 2);
	AddIconToken("$quarters_egg$", "Kitchen.png", Vec2f(24, 24), 8);
	AddIconToken("$quarters_burger$", "Kitchen.png", Vec2f(24, 24), 9);
	AddIconToken("$rest$", "InteractionIcons.png", Vec2f(32, 32), 29);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Beer", "$quarters_beer$", "beer", Descriptions::beer, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "blob", "coin", "Coin", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Meal", "$quarters_meal$", "meal", Descriptions::meal, false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "coin", "Coin", 4);
	}
	{
		ShopItem@ s = addShopItem(this, "Egg", "$quarters_egg$", "egg", Descriptions::egg, false);
		AddRequirement(s.requirements, "blob", "coin", "Coin", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Burger", "$quarters_burger$", "food", Descriptions::burger, true);
		AddRequirement(s.requirements, "blob", "coin", "Coin", 1);
	}
}

void onTick(CBlob@ this)
{
	
	if(XORRandom(10) == 0)makeSmokeParticle(this.getPosition()+Vec2f(4+XORRandom(8),-10-XORRandom(4))); 
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			if (name == "beer")
			{
				// TODO: gulp gulp sound
				if (isServer)
				{
					server_OverHeal(callerBlob,1.0f,2.0f);
				}
			}
			else if (name == "meal")
			{
				this.getSprite().PlaySound("/Eat.ogg");
				if (isServer)
				{
					server_OverHeal(callerBlob,4.0f,2.0f);
				}
			}
		}
	}
}