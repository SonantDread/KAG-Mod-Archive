
//SSK random items spawning logic

const array<string> ITEMS_LIST =
{
	"bomb",
	"waterbomb",
	"keg",
	"mine",
	"trampoline",
	"saw",
	"boulder",
	"green_shell",
	"smart_bomb",
	"food",
	"steak",
	"drill",
	"barrel",
	"grenade",
	"gravity_bomb",
	"ray_gun"
};

const int SPAWN_INTERVAL = 160;
const int SPAWNING_TIME = 70;
const f32 MAX_SPAWN_HEIGHT = 32.0f;
const f32 SPAWN_MARGIN = 64.0f;

const int MAX_ITEMS = 20;

const int MAX_ITERATIONS = 20;

void onInit( CRules@ this )
{
	this.set_bool("item ready to spawn", false);
	this.set_u32("spawning timer", 0);
	this.set_Vec2f("spawning pos", Vec2f_zero);
	this.set_u16("item interval timer", 0);
	this.set_u16("item counter", 0);

	this.addCommandID("begin spawning timer");
	this.addCommandID("spawn item");
}

void onTick( CRules@ this )
{
	u16 spawningTimer = this.get_u32("spawning timer");
	if (spawningTimer > 0)
	{
		if (getNet().isClient())
		{
			makeSparksSmall(this.get_Vec2f("spawning pos"), 2);
		}
		
		spawningTimer--;
		this.set_u32("spawning timer", spawningTimer);
	}
	else if (this.get_bool("item ready to spawn"))
	{
		if (getNet().isServer())
		{
			string randomItemName = ITEMS_LIST[XORRandom(ITEMS_LIST.length())];

			CBitStream bt;
			bt.write_string(randomItemName);
			bt.write_Vec2f(this.get_Vec2f("spawning pos"));
			this.SendCommand(this.getCommandID("spawn item"), bt);
		}

		this.set_bool("item ready to spawn", false);	
	}

	if (getNet().isServer()) 
	{
		u16 itemTimer = this.get_u16("item interval timer");
		bool itemSpawnPosFound = false;
		if (itemTimer <= 0)
		{
			u16 itemCounter = this.get_u16("item counter");

			if (itemCounter < MAX_ITEMS)
			{
				CMap@ map = getMap();
				const u16 mapWidth = map.tilemapwidth * map.tilesize;
				const u16 mapHeight = map.tilemapheight * map.tilesize;
				
				f32 randomPosX = SPAWN_MARGIN + XORRandom(mapWidth - SPAWN_MARGIN);

				Vec2f[] potentialSpawnPos;

				int rayStartY = 0;	// start from top of the map
				for (uint rayStartY = 0; rayStartY < mapHeight; rayStartY += map.tilesize*2)
				{
					Vec2f startPos = Vec2f(randomPosX, rayStartY);

					Tile startPosTile = map.getTile(startPos);
					if (map.isTileSolid(startPosTile))	// scan down until there is an open space in tilemap
					{
						continue;
					}
					else
					{	
						HitInfo@[] hitInfos;
						if (map.getHitInfosFromRay(startPos, 90.0f, mapHeight - rayStartY, null, hitInfos))
						{
							for (uint i = 0; i < hitInfos.length; i++)
							{
								HitInfo@ hi = hitInfos[i];
								CBlob@ hitBlob = hi.blob;
								if (hitBlob !is null)	// hit blob
								{
									const bool isBlobGround = hitBlob.isCollidable() && hitBlob.getShape().isStatic();
									if (isBlobGround)
									{
										f32 spawnPosY = hi.hitpos.y - Maths::Min(MAX_SPAWN_HEIGHT, hi.hitpos.y - rayStartY);
										potentialSpawnPos.push_back(Vec2f(hi.hitpos.x, spawnPosY));

										rayStartY = hi.hitpos.y;
										break;
									}
									else
									{
										rayStartY = hi.hitpos.y;
										continue;
									}
								}
								else if (hi.hitpos.y < mapHeight)	// hit valid map pos
								{
									f32 spawnPosY = hi.hitpos.y - Maths::Min(MAX_SPAWN_HEIGHT, hi.hitpos.y - rayStartY);
									potentialSpawnPos.push_back(Vec2f(hi.hitpos.x, spawnPosY));

									rayStartY = hi.hitpos.y;
									break;
								}
							}
						}
						else
						{
							break;
						}
					}
				}
			
				if (potentialSpawnPos.length > 0)
				{
					u16 randPosIndex = XORRandom(potentialSpawnPos.length);	

					CBitStream bt;
					bt.write_Vec2f(potentialSpawnPos[randPosIndex]);
					this.SendCommand(this.getCommandID("begin spawning timer"), bt);

					itemSpawnPosFound = true;
				}

				// old item spawn position code
				/*
				if (canSpawnItemAtPos(spawnPos, map, mapWidth, mapHeight))
				{
					string randomItemName = ITEMS_LIST[XORRandom(ITEMS_LIST.length())];

					CBitStream bt;
					bt.write_string( randomItemName );
					bt.write_Vec2f( spawnPos );
					this.SendCommand(this.getCommandID("spawn item"), bt);

					u16 itemCounter = this.get_u16("item counter");
					itemCounter++;
					this.set_u16("item counter", itemCounter);

					itemSpawnPosFound = true;
				}
				*/
			}
			else
			{
				// update item counter on intervals
	  			CBlob@[] itemBlobs;
				getBlobsByTag("item", @itemBlobs);
				this.set_u16("item counter", itemBlobs.length);

				this.set_u16("item interval timer", SPAWN_INTERVAL);
			}
		}

		if (itemSpawnPosFound)
		{
			this.set_u16("item interval timer", SPAWN_INTERVAL);
		}
		else if (itemTimer > 0)
		{
			itemTimer--;
			this.set_u16("item interval timer", itemTimer);
		}
	}
}

bool canSpawnItemAtPos(Vec2f spawnPos, CMap@ map, u16 mapWidth, u16 mapHeight)
{
	Tile tile = map.getTile(spawnPos);
	if (!map.isTileSolid(tile))
	{
		Vec2f endPos = Vec2f(spawnPos.x, spawnPos.y + MAX_SPAWN_HEIGHT);
		bool itemOverGround = map.rayCastSolidNoBlobs(spawnPos, endPos, endPos) && endPos.y < mapHeight;

		return itemOverGround;
	}

	return false;
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("begin spawning timer"))
	{
		Vec2f spawnPos = params.read_Vec2f();

		this.set_bool("item ready to spawn", true);
		this.set_u32("spawning timer", SPAWNING_TIME);
		this.set_Vec2f("spawning pos", spawnPos);
	}
	else if (cmd == this.getCommandID("spawn item"))
	{
		string blobName = params.read_string();
		Vec2f spawnPos = params.read_Vec2f();

		if (getNet().isServer())
		{
			CBlob @blob = server_CreateBlob(blobName, -1, spawnPos);
			if (blob !is null)
			{
				blob.Tag("item");

				if (blob.getName() == "bomb")
				{
					if (XORRandom(2) == 0)
					{
						blob.Tag("activated");
					}
				}
			}

			u16 itemCounter = this.get_u16("item counter");
			itemCounter++;
			this.set_u16("item counter", itemCounter);
		}
		
		if (getNet().isClient())
		{
			ParticleAnimated("sparkle3.png", spawnPos, Vec2f(0, 0), XORRandom(360), 2.0f, 6, 0.0f, true);
			makeSparksBig(spawnPos, 30);

			Sound::Play("itemland.ogg", spawnPos, 2.0f);
		}
	}
}

Random _sprk_r();
void makeSparksBig(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;
		
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 4.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 255, 200+_sprk_r.NextRanged(55), 200+_sprk_r.NextRanged(55), 255), true );
        if(p is null) return; //bail if we stop getting particles
		
		p.gravity = Vec2f(0.0f,0.1f);
        p.timeout = 40 + _sprk_r.NextRanged(40);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.95f;
    }
}

void makeSparksSmall(Vec2f pos, int amount)
{
	if ( !getNet().isClient() )
		return;
		
	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(_sprk_r.NextFloat() * 3.0f, 0);
        vel.RotateBy(_sprk_r.NextFloat() * 360.0f);

        CParticle@ p = ParticlePixel( pos, vel, SColor( 255, 200+_sprk_r.NextRanged(55), 200+_sprk_r.NextRanged(55), 255), true );
        if(p is null) return; //bail if we stop getting particles
		
		p.gravity = Vec2f(0.0f,0.01f);
        p.timeout = 10 + _sprk_r.NextRanged(10);
        p.scale = 1.0f + _sprk_r.NextFloat();
        p.damping = 0.9f;
    }
}