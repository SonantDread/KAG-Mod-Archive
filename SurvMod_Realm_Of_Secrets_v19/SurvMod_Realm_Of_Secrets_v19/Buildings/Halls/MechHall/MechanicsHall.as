// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(-12, 7));
	this.set_Vec2f("shop menu size", Vec2f(2, 3));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	AddIconToken("$bomber_icon$", "VehicleIcons.png", Vec2f(32, 32), 6);
	
	{
		ShopItem@ s = addShopItem(this, "Hot Air Balloon", "$bomber_icon$", "bomber", "$bombershopicon$\n\n\n" + "Perfect for floating through the skies.", false, true);
		s.crate_icon = 3;
		AddRequirement(s.requirements, "blob", "coin", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Mounted Bow", "$mounted_bow$", "mounted_bow", "$mounted_bow$\n\n\n" + "Perfect for shooting through enemy's hearts...", false, true);
		AddRequirement(s.requirements, "blob", "coin", "Coins", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
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