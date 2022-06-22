#include "ProductionCommon.as";
#include "Requirements.as"
#include "MakeFood.as"
#include "FireParticle.as"
#include "MakeDustParticle.as";

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.getSprite().SetAnimation("animate");
	this.getSprite().SetZ(-70.0f);
	this.SetLight(true);
	this.SetLightRadius(300.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	this.Tag("fire source");

	// Minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);

	this.getCurrentScript().tickFrequency = 20;
}

void onTick(CBlob@ this)
{
	// Particles
	if (XORRandom(3) == 0)
	{
		makeSmokeParticle(this.getPosition(), -0.05f);
		this.getSprite().SetEmitSoundPaused(false);
	}
	else
	{
		makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
	}

    float take_distance = 64.0f;

    array<CBlob@> blobs;
    CMap@ map = getMap();
    map.getBlobsInRadius(this.getPosition(), take_distance, blobs);

    for (u16 i = 0; i < blobs.size(); i++)
    {
        if (blobs[i].hasTag("offerable")) //If they have the offer tag
        {
        	SColor color = SColor(210, 83, 51, 7);
        	
            blobs[i].getSprite().PlaySound("Offering.ogg");
            this.getSprite().PlaySound("SparkleShort.ogg");

            CParticle@ smoke = ParticleAnimated(CFileMatcher("Smoke.png").getFirst(), blobs[i].getPosition(), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
            makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
            makeFireParticle(blobs[i].getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));

            blobs[i].server_Die();

            if (blobs[i].getName() == "basicoffering")
            {
				CBlob@ drop = server_CreateBlob("mat_gold",-1,this.getPosition());
				if (drop !is null)
				{
					Vec2f vel(0.0f, -7.5f);
					drop.setVelocity(vel * 1.2);
				}

				if (getNet().isClient())
				{
					client_AddToChat("The Fire is brighter with happiness, it seems pleased so it rewards you.", color);
				}
            }

            if (blobs[i].getName() == "coinoffering")
            {
				CBlob@ drop = server_CreateBlob("pouchofcoins",-1,this.getPosition());
				if (drop !is null)
				{
					Vec2f vel(0.0f, -7.5f);
					drop.setVelocity(vel * 1.2);
				}

				if (getNet().isClient())
				{
					client_AddToChat("The Fire is brighter with happiness, it seems pleased so it rewards you.", color);
				}
            }

            if (blobs[i].getName() == "soul")
			{	
				for (int i = 0; i < 6; i++)
				{
					CBlob@ b = server_CreateBlob("meteor");
					if (b !is null)
					{			
						CMap@ map = getMap();
						f32 mapWidth = (map.tilemapwidth * map.tilesize);	
						f32 mapHeight = (map.tilemapheight * map.tilesize);

						b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
						b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
					}
				}

				if (getNet().isClient())
				{
					client_AddToChat("The Fire growls and crackles as it consumes the soul!", color);
					client_AddToChat("You worry that you have made a poor choice.", color);
				}
			}
        }
    }
}
/*
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	SColor color = SColor(210, 83, 51, 7);
	if (blob !is null)
	{
		if (blob.getName() == "paper")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			makeSmokeParticle(this.getPosition(), -0.05f);
			makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
			CBlob@ reward = server_CreateBlob("mat_gold",-1,this.getPosition());
			if(reward !is null)
			{
				Vec2f vel(0.0f, -7.5f);
				reward.setVelocity(vel * 1.2);
			}

			blob.server_Die();
			client_AddToChat("The Fire is brighter with happiness, it seems pleased so it rewards you.", color);
		}
		if (blob.getName() == "log")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			blob.server_Die();
			
			if (XORRandom(4) == 0){
				if (XORRandom(8) == 0){
					client_AddToChat("The Fire speaks- Build a man a fire, and he’ll be warm for a day. Set a man on fire, and he’ll be warm for the rest of his life.", color);}
				else{
					if (XORRandom(7) == 0){
						client_AddToChat("The Fire speaks- What do you call Stephen Hawking on fire? Hot wheels.", color);}
					else{
						if (XORRandom(6) == 0){
							client_AddToChat("The Fire speaks- When Chuck Norris wants to burn calories, he throws fat children into the fire.", color);}
						else{
							if (XORRandom(5) == 0){
								client_AddToChat("The Fire speaks- A fire broke out at the circus, it was in-tents.", color);}
							else{
								if (XORRandom(4) == 0){
									client_AddToChat("The Fire speaks- What do you call a retard in a house fire? Flame Retardant.", color);}
								else{
									if (XORRandom(3) == 0){
										client_AddToChat("The Fire speaks- Why did the little girl’s ice cream melt? She was on fire.", color);}
									else{
										if (XORRandom(2) == 0){
											client_AddToChat("The Fire speaks- How fast can a wildfire start? Lightning fast.", color);}
										else{
											client_AddToChat("The Fire speaks- What do you call a Chinese woman on fire? Mel Ting.", color);}
									}
								}
							}
						}
					}
				}
			}
		}
		if (blob.getName() == "heart")
		{
			blob.getSprite().PlaySound("SparkleShort.ogg");
			makeSmokeParticle(this.getPosition(), -0.05f);
			makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 360.0f));
			this.getSprite().SetEmitSoundPaused(false);
			if (XORRandom(5) == 0){
				if (XORRandom(2) == 0){
					server_CreateBlob("mat_stone",-1,this.getPosition());}
				else{
					server_CreateBlob("mat_wood",-1,this.getPosition());}
			}
			else{
				if (XORRandom(40) == 0){
					server_CreateBlob("cannonball",-1,this.getPosition());
					server_CreateBlob("mat_gold",-1,this.getPosition());}
			}
			blob.server_Die();
		}
		if (blob.getName() == "soul")
		{		
			client_AddToChat("The Fire growls and crackles as it consumes the soul!", color);
			client_AddToChat("You worry that you have made a poor choice.", color);
			for (int i = 0; i < 7; i++)
			{
				CBlob@ b = server_CreateBlob("meteor");
				if (b !is null)
				{			
					CMap@ map = getMap();
					f32 mapWidth = (map.tilemapwidth * map.tilesize);	
					f32 mapHeight = (map.tilemapheight * map.tilesize);

					b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
					b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight -XORRandom(256)*30));
				}
			}
			blob.server_Die();
		}
	}
}
*/
