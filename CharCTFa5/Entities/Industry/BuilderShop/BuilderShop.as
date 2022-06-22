	// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$crate$", "Crate.png", Vec2f(32, 16), 22);
	AddIconToken("$mat_bolterarrows$", "Materials.png", Vec2f(16, 16), 27);
	AddIconToken("$mat_bolterfirearrows$", "Materials.png", Vec2f(16, 16), 12);
	AddIconToken("$mat_bolterwaterarrows$", "Materials.png", Vec2f(16, 16), 28);
	AddIconToken("$mat_bolterbombarrows$", "BolterBombarrow.png", Vec2f(16, 16), 0);
	AddIconToken("$onestarbuilderuniform$", "Uniform.png", Vec2f(16, 16), 0);
	AddIconToken("$onestarbuilderuniform2$", "Uniform.png", Vec2f(16, 16), 0);
	AddIconToken("$twostarbuilderuniform$", "Uniform.png", Vec2f(16, 16), 0);
	AddIconToken("$twostarbuilderuniform2$", "Uniform.png", Vec2f(16, 16), 0);
	AddIconToken("$threestarbuilderuniform$", "Uniform.png", Vec2f(16, 16), 0);
	AddIconToken("$threestarbuilderuniform2$", "Uniform.png", Vec2f(16, 16), 0);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(6, 5));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "a light", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", "puts out fires when full", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", "soaks up water", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", "crush people", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", "bouncy", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "cuts things", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone",  50);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "digs fast", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 12);	
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", "Storage and Stuff", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Bolter Arrows", "$mat_bolterarrows$", "mat_bolterarrows", "bolter arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Bolter Water Arrows", "$mat_bolterwaterarrows$", "mat_bolterwaterarrows", 		"bolter water arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 36);
	}
	{
		ShopItem@ s = addShopItem(this, "Bolter Fire Arrows", "$mat_bolterfirearrows$", "mat_bolterfirearrows", 		"bolter fire arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 36);
	}
	{
		ShopItem@ s = addShopItem(this, "Bolter Bomb Arrows", "$boltermat_bombarrows$", "mat_bolterbombarrows", 		"bolter bomb arrows", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 105);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarBuilderUniform", "$onestarbuilderuniform$", "onestarbuilderuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "OneStarBuilderUniform2", "$onestarbuilderuniform2$", "onestarbuilderuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarBuilderUniform", "$twostarbuilderuniform$", "twostarbuilderuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestarbuilderuniform", "One Star Builder Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "TwoStarBuilderUniform2", "$twostarbuilderuniform2$", "twostarbuilderuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 40);
		AddRequirement(s.requirements, "blob", "onestarbuilderuniform2", "One Star Builder Uniform", 1);
	}

	{
		ShopItem@ s = addShopItem(this, "ThreeStarBuilderUniform", "$threestarbuilderuniform$", "threestarbuilderuniform", "uniform", true);
		AddRequirement(s.requirements, "blob", "redlifefiber", "Red Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostarbuilderuniform", "Two Star Builder Uniform", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "ThreeStarBuilderUniform2", "$threestarbuilderuniform2$", "threestarbuilderuniform2", "uniform", true);
		AddRequirement(s.requirements, "blob", "bluelifefiber", "Blue Life Fiber", 60);
		AddRequirement(s.requirements, "blob", "twostarbuilderuniform2", "Two Star Builder Uniform", 1);
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

