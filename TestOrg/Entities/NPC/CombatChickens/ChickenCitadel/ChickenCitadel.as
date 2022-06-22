﻿void onInit(CBlob@ this)
{
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getCurrentScript().tickFrequency = 600;
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	
	this.Tag("minimap_small");
	this.set_u8("minimap_index", 27);
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("ChickenMarch.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.5f);
	
	if (getNet().isServer())
	{
		for (int i = 0; i < 3; i++)
		{
			server_CreateBlob("commanderchicken", -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
		}
	}
}

void onTick(CBlob@ this)
{
	SetMinimap(this);

	if (getNet().isServer())
	{
		if (XORRandom(100) < 8)
		{
			CBlob@[] chickens;
			getBlobsByTag("combat chicken", @chickens);
			
			if (chickens.length < 12)
			{
				CBlob@ blob = server_CreateBlob((XORRandom(100) < 75 ? "heavychicken" : "soldierchicken"), -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
			}
		}
	}
}

void SetMinimap(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
	if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
	else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));

	this.SetMinimapRenderAlways(true);
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_DropCoins(this.getPosition(), 1000 + XORRandom(500));
	}
}