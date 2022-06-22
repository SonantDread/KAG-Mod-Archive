#include "VehicleCommon.as"
#include "Hitters.as"
#include "MapFlags.as";

// Boat logic


void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              47.0f, // move speed
	              0.19f,  // turn speed
	              Vec2f(0.0f, -5.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_SetupAirship(this, v, -350.0f);

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.set_f32("map dmg modifier", 35.0f);

	//this.getShape().SetOffset(Vec2f(0,0));
	//  this.getShape().getConsts().bullet = true;
//	this.getShape().getConsts().transports = true;

	CSprite@ sprite = this.getSprite();

	// add balloon
	
	Vec2f m = this.getPosition();
	
	CBlob@[] BlobList;
	getMap().getBlobsInRadius(m,140.0f,@BlobList);
	//print(BlobList.length + "");
	
	print("Hellllllll");
	CBlob@ FoundBlob2 = null;
	CMap@ map = getMap();
	for(int i =-10 ; i < 20; i++)
	{
		print("i: " + i );
		for(int x = -10; x < 20; x++)
		{
			  
			
				//TileType NewTile = map.getTile(offset).type;
		
			
			Vec2f tilespace = map.getTileSpacePosition(this.getPosition());
			const int offset = map.getTileOffsetFromTileSpace(tilespace + Vec2f(x,i));
			TileType NewTile = map.getTile(offset).type;
			//print(NewTile + "");
			//NewTile = map.getTile(Vec2f(this.getPosition().x + x,this.getPosition().y + i)).type;
			//print("x: " + x );
			if(map.isTileWood(NewTile) && isServer())
			{
				AttachmentPoint@ newap = this.getAttachments().AddAttachmentPoint("NewPoint" + x + i, true); 
			
					
				CBlob@ FoundBlob2 = server_CreateBlob("woodblob", -1, Vec2f(this.getPosition().x + x * 8, this.getPosition().y + 1.5f + i * 8));
					
				if (FoundBlob2 !is null)
				{
					
					newap.offset = Vec2f(FoundBlob2.getPosition().x - this.getPosition().x, FoundBlob2.getPosition().y - this.getPosition().y + 10);
					this.server_AttachTo(FoundBlob2, "NewPoint" + x + i);
					FoundBlob2.getShape().SetStatic(true);
					FoundBlob2.getShape().getConsts().collideWhenAttached = true;
				}
    //map.server_DestroyTile(Vec2f(this.getPosition().x + x * 8,this.getPosition().y + i * 8), 1000000);
			}
			
			else if(map.isTileCastle(NewTile) && isServer())
			{
				AttachmentPoint@ newap = this.getAttachments().AddAttachmentPoint("NewPoint" + x + i, true); 
			
						CBlob@ FoundBlob2 = server_CreateBlob("stoneblob", -1, Vec2f(this.getPosition().x + x * 8, this.getPosition().y + 1.5f + i * 8));
					
				if (FoundBlob2 !is null)
				{
					newap.offset = Vec2f(FoundBlob2.getPosition().x - this.getPosition().x, FoundBlob2.getPosition().y - this.getPosition().y + 10);
					this.server_AttachTo(FoundBlob2, "NewPoint" + x + i);
					FoundBlob2.getShape().SetStatic(true);
					FoundBlob2.getShape().getConsts().collideWhenAttached = true;
				}
    //map.server_DestroyTile(Vec2f(this.getPosition().x + x * 8,this.getPosition().y + i * 8), 1000000);
			}
			else if(NewTile == CMap::tile_castle_back && isServer())
			{
				AttachmentPoint@ newap = this.getAttachments().AddAttachmentPoint("NewPoint" + x + i, true); 
			
						CBlob@ FoundBlob2 = server_CreateBlob("backcastlewallblob", -1, Vec2f(this.getPosition().x + x * 8, this.getPosition().y + 1.5f + i * 8));
					
				if (FoundBlob2 !is null)
				{
					newap.offset = Vec2f(FoundBlob2.getPosition().x - this.getPosition().x, FoundBlob2.getPosition().y - this.getPosition().y + 10);
					this.server_AttachTo(FoundBlob2, "NewPoint" + x + i);
					FoundBlob2.getShape().SetStatic(true);
					FoundBlob2.getShape().getConsts().collideWhenAttached = true;
				}
    //map.server_DestroyTile(Vec2f(this.getPosition().x + x * 8,this.getPosition().y + i * 8), 1000000);
			}
			else if(NewTile == CMap::tile_wood_back && isServer())
			{
				AttachmentPoint@ newap = this.getAttachments().AddAttachmentPoint("NewPoint" + x + i, true); 
		
				CBlob@ FoundBlob2 = server_CreateBlob("backwoodwallblob", -1, Vec2f(this.getPosition().x + x * 8, this.getPosition().y + 1.5f + i * 8));
					
				if (FoundBlob2 !is null)
				{
					newap.offset = Vec2f(FoundBlob2.getPosition().x - this.getPosition().x, FoundBlob2.getPosition().y - this.getPosition().y + 10);
					this.server_AttachTo(FoundBlob2, "NewPoint" + x + i);
					FoundBlob2.getShape().SetStatic(true);
					FoundBlob2.getShape().getConsts().collideWhenAttached = true;
				}
    //map.server_DestroyTile(Vec2f(this.getPosition().x + x * 8,this.getPosition().y + i * 8), 1000000);
			}
		}
	}
	




	for(int l= 0; l < BlobList.length; l++)
	{
		CBlob@ FoundBlob = BlobList[l];
		if(FoundBlob.getName() == "structure" || FoundBlob.getName() == "mounted_bow" || FoundBlob.getName() == "seat" || FoundBlob.getName() == "ladder" || FoundBlob.getName() == "wooden_platform" || FoundBlob.getName() == "bolter" || FoundBlob.getName() == "dispenser"|| FoundBlob.getName() == "lamp" || FoundBlob.getName() == "obstructor" || FoundBlob.getName() == "wire" || FoundBlob.getName() == "push_button" || FoundBlob.getName() == "sensor" || FoundBlob.getName() == "lever" || FoundBlob.getName() == "pressure_plate" || FoundBlob.getName() == "elbow" || FoundBlob.getName() == "tee" || FoundBlob.getName() == "oscillator" || FoundBlob.getName() == "junction" || FoundBlob.getName() == "magazine" || FoundBlob.getName() == "inverter" || FoundBlob.getName() == "randomizer" || FoundBlob.getName() == "diode" || FoundBlob.getName() == "toogle" || FoundBlob.getName() == "structurebackground" || FoundBlob.getName() == "bed")
		{
		
			Vec2f FoundBlobPos = FoundBlob.getPosition();
			AttachmentPoint@ newap2 = this.getAttachments().AddAttachmentPoint("Newattachment" + l, true); 
			//name; x; y; socket or a plug; pickup radius
			newap2.offset = Vec2f(FoundBlobPos.x - this.getPosition().x, FoundBlobPos.y - this.getPosition().y + 10);
			this.server_AttachTo(FoundBlob, "Newattachment" + l);
		
			FoundBlob.getShape().getConsts().collideWhenAttached = true;
		}
	}

	CSpriteLayer@ balloon = sprite.addSpriteLayer("balloon", "Balloon.png", 48, 64);
	if (balloon !is null)
	{
		balloon.addAnimation("default", 0, false);
		int[] frames = { 0, 2, 3 };
		balloon.animation.AddFrames(frames);
		balloon.SetRelativeZ(1.0f);
		balloon.SetOffset(Vec2f(0.0f, -26.0f));	
		
	}

	CSpriteLayer@ background = sprite.addSpriteLayer("background", "Balloon.png", 32, 16);
	if (background !is null)
	{
		background.addAnimation("default", 0, false);
		int[] frames = { 3 };
		background.animation.AddFrames(frames);
		background.SetRelativeZ(-5.0f);
		background.SetOffset(Vec2f(0.0f, -5.0f));

	}

	CSpriteLayer@ burner = sprite.addSpriteLayer("burner", "Balloon.png", 8, 16);
	if (burner !is null)
	{
		{
			Animation@ a = burner.addAnimation("default", 3, true);
			int[] frames = { 41, 42, 43 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("up", 3, true);
			int[] frames = { 38, 39, 40 };
			a.AddFrames(frames);
		}
		{
			Animation@ a = burner.addAnimation("down", 3, true);
			int[] frames = { 44, 45, 44, 46 };
			a.AddFrames(frames);
		}
		burner.SetRelativeZ(1.5f);
		burner.SetOffset(Vec2f(0.0f, -26.0f));

	}
	
	CSprite@ SpriteBomber = this.getSprite();
	SpriteBomber.SetZ(100.0f);
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		if (this.getHealth() > 1.0f)
		{
			VehicleInfo@ v;
			if (!this.get("VehicleInfo", @v))
			{
				return;
			}
			Vehicle_StandardControls(this, v);

			//TODO: move to atmosphere damage script
			f32 y = this.getPosition().y;
			if (y < 100)
			{
				if (getGameTime() % 15 == 0)
					this.server_Hit(this, this.getPosition(), Vec2f(0, 0), y < 50 ? (y < 0 ? 2.0f : 1.0f) : 0.25f, 0, true);
			}
		}
		else
		{
			this.server_DetachAll();
			this.setAngleDegrees(this.getAngleDegrees() + (this.isFacingLeft() ? 1 : -1));
			if (this.isOnGround() || this.isInWater())
			{
				this.server_SetHealth(-1.0f);
				this.server_Die();
			}
			else
			{
				//TODO: effects
				if (getGameTime() % 30 == 0)
					this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.05f, 0, true);
			}
		}
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_ground(this, blob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onAttach(this, v, attached, attachedPoint);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onDetach(this, v, detached, attachedPoint);
}


// SPRITE

void onInit(CSprite@ this)
{
	this.SetZ(-50.0f);
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	f32 ratio = 1.0f - (blob.getHealth() / blob.getInitialHealth());
	this.animation.setFrameFromRatio(ratio);

	CSpriteLayer@ balloon = this.getSpriteLayer("balloon");
	if (balloon !is null)
	{
		if (blob.getHealth() > 1.0f)
			balloon.animation.frame = Maths::Min((ratio) * 3, 1.0f);
		else
			balloon.animation.frame = 2;
	}

	CSpriteLayer@ burner = this.getSpriteLayer("burner");
	if (burner !is null)
	{
		burner.SetOffset(Vec2f(0.0f, -14.0f));
		s8 dir = blob.get_s8("move_direction");
		if (dir == 0)
		{
			blob.SetLightColor(SColor(255, 255, 240, 171));
			burner.SetAnimation("default");
		}
		else if (dir < 0)
		{
			blob.SetLightColor(SColor(255, 255, 240, 200));
			burner.SetAnimation("up");
		}
		else if (dir > 0)
		{
			blob.SetLightColor(SColor(255, 255, 200, 171));
			burner.SetAnimation("down");
		}
	}
}
