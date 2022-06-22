// BoatShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"


void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	AddIconToken("$scroll_flight$", "Scroll.png",Vec2f(16, 16), 4);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Flight", "$scroll_flight$", "scroll_flight", "Lets you fly with holding W.\nDuration: 10 seconds", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
	}

	AddIconToken("$scroll_wallrun$", "Scroll.png",Vec2f(16, 16), 5);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Infinite Wallrun", "$scroll_wallrun$", "scroll_wallrun", "Lets you wallrun infinitely.\nDuration: 15 seconds", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 90);
	}
	AddIconToken("$scroll_drill$", "Scroll.png", Vec2f(16, 16), 13);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Drill", "$scroll_drill$", "scroll_drill", "Lets you use a drill even if you're not a builder.\nIncreases drill speed.\nDuration: 30 seconds", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}

	AddIconToken("$scroll_esau$", "Scroll.png",Vec2f(16, 16), 14);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Esau", "$scroll_esau$", "esauscroll", "Creates a Knight that mimics your movement.\nNot perfectly accurate.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
	}

	AddIconToken("$boulder_scroll$", "Scroll.png", Vec2f(16, 16), 25);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Stone", "$boulder_scroll$", "boulderscroll", "Turns you into a boulder. :)", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
	}

	AddIconToken("$mundir$", "Scroll.png", Vec2f(16, 16), 17);
	{
		ShopItem@ s = addShopItem(this, "Odur Mundir", "$mundir$", "mundir", "Creates a healing aura around the user.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	AddIconToken("$kaghlos$", "Scroll.png", Vec2f(16, 16), 25);
	{
		ShopItem@ s = addShopItem(this, "Scroll of Odur Kaghlos", "$kaghlos$", "kaghlos", "Creates a rocks in air around you", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 110);
	}
	AddIconToken("$icon_shackles$", "Shackles_icon.png", Vec2f(16, 16), 1);
	{
		ShopItem@ s = addShopItem(this, "Slavemaster's Kit", "$icon_shackles$", "shackles", "A kit containing shackles, shiny iron ball, elegant striped pants, noisy chains and a slice of cheese.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
} 

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ lantern = this.addSpriteLayer( "lantern", "Lantern.png" , 8, 8, blob.getTeamNum(), blob.getSkinNum() );
	
	if (lantern !is null)
    {
		lantern.SetOffset(Vec2f(9,2));
		
        Animation@ anim = lantern.addAnimation( "default", 3, true );
        anim.AddFrame(0);
        anim.AddFrame(1);
        anim.AddFrame(2);
        
        blob.SetLight(true);
		blob.SetLightRadius( 32.0f );
    }
}
