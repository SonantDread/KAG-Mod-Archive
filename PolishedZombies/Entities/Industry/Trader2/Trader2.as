// Builder Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(7,1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{	 
		ShopItem@ s = addShopItem(this, "Wood", "$mat_wood$", "mat_wood", "Exchange 50 Gold for 250 Wood", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}

	{
		ShopItem@ s = addShopItem(this, "Stone", "$mat_stone$", "mat_stone", "Exchange 125 Gold for 250 Stone", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 125);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Wood for Gold", "$mat_gold$", "mat_gold", "Exchange 2000 Wood for 250 Gold", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 2000);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Stone for Gold", "$mat_gold$", "mat_gold", "Exchange 500 Stone for 250 Gold", true);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 500);
	}
		
	{
		ShopItem@ s = addShopItem(this, "Coins for Gold", "$mat_gold$", "mat_gold", "Buy 250 gold for 125 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
	{
		ShopItem@ s = addShopItem(this, "Hire Knight Guard", "$knightbot$", "knightbot", "Hire a mercenary kinght to fight for you!", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Hire Archer Guard", "$archerbot$", "archerbot", "Hire a mercenary archer to fight for you! \n May occasionally need ammo", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller) /*&& caller.getName() == "builder"*/);
}
								   
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
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