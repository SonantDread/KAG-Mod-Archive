// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "FireParticle.as";
#include "MaterialCommon.as";

const f32 MAX_SMELT = 10;

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().SetEmitSound("CampfireSound.ogg");

	this.inventoryButtonPos = Vec2f(24, 14);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 7));
	this.set_Vec2f("shop menu size", Vec2f(3, 1));
	this.set_string("shop description", "Anvil");
	this.set_u8("shop icon", 15);

	AddIconToken("$metal_blade_icon$", "MetalBladeIcon.png", Vec2f(16, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Metal Blade", "$metal_blade_icon$", "metal_blade", "A large metal blade, for cutting people in-two.", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 2);
	}
	AddIconToken("$knife_icon$", "KnifeIcon.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Knife", "$knife_icon$", "knife", "Knives are incredibly useful, butchery, home medicine, cooking, surgery, etc.\nA very practical tool.", false);
		AddRequirement(s.requirements, "blob", "mat_metal", "Metal", 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 5);
		AddRequirement(s.requirements, "tech", "tek_surgery", "Surgery", 1);
	}
	AddIconToken("$coin_icon$", "Coin.png", Vec2f(16, 16), 10);
	{
		ShopItem@ s = addShopItem(this, "Mint Coin", "$coin_icon$", "coin", "Mint a batch of coins.", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		AddRequirement(s.requirements, "tech", "tek_minting", "Coin Minting", 1);
	}
	
	CSpriteLayer@ fire = this.getSprite().addSpriteLayer( "fire","Quarters.png", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {48,49,50,51};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(-24, 21));
		fire.SetRelativeZ(0.1f);
	}
	this.SetLightRadius(80);
	this.SetLight(true);
	
	this.set_u8("smelting",0);
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

void onTick(CBlob@ this)
{
	if(XORRandom(8) == 0)makeSmokeParticle(this.getPosition()+Vec2f(20+XORRandom(8),-26-XORRandom(4))); 
	
	if(XORRandom(20) == 0)makeFireParticle(this.getPosition()+Vec2f(10+XORRandom(8),20-XORRandom(4))); 
	if(XORRandom(40) == 0)makeFireParticle(this.getPosition()+Vec2f(20+XORRandom(8),20-XORRandom(4))); 
	
	if(getGameTime() % 30 == 0){
		bool must_burn = false;
		
		if(this.hasBlob("mat_stone", 50))must_burn = true;
		
		if(must_burn){
			if(this.hasBlob("mat_wood", 1)){
				if(this.get_u8("smelting") >= MAX_SMELT){
					
					
					if(this.hasBlob("mat_stone", 50)){
						this.TakeBlob("mat_stone", 50);
						if(isServer())Material::createFor(this,"mat_metal",1);
					}
				
					this.set_u8("smelting",0);
				} else
				this.add_u8("smelting",1);
				this.TakeBlob("mat_wood", 1);
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CBlob@ player = getLocalPlayerBlob();
	if(player !is null)
	if(blob.isOverlapping(player))
	{
		//VV right here VV
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(24, 13));
		Vec2f posTopLeft = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(24, 13) + Vec2f(-7, 0));
		Vec2f posBotRight = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(24, 13) + Vec2f(7, 0));
		const f32 perc = blob.get_u8("smelting") / MAX_SMELT;
		if (perc > 0.0f)
		{
			GUI::DrawRectangle(posTopLeft-Vec2f(2,2), posBotRight+Vec2f(2,10));
			GUI::DrawRectangle(posTopLeft+Vec2f(2,2), posTopLeft+Vec2f(2,6) + Vec2f((posBotRight-Vec2f(2,0)).x-(posTopLeft+Vec2f(2,0)).x,0)*perc, SColor(0xffce4c06));
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	
	if (!blob.isAttached() && blob.hasTag("material") && !this.hasBlob(blob.getName(),250))
	{
		this.server_PutInInventory(blob);
	}
}