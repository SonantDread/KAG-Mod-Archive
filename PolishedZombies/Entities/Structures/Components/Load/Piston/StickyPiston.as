// StickyPiston.as

#include "MechanismsCommon.as";
#include "Hitters.as";

const int MaximumBlocksToMove = 10; //change it if you want :)

class StickyPiston : Component
{
	u16 id;
	Vec2f offset;

	StickyPiston(Vec2f position, u16 netID, Vec2f _offset)
	{
		x = position.x;
		y = position.y;

		id = netID;
		offset = _offset;
	}

	void Activate(CBlob@ this)
	{
		Vec2f position = this.getPosition();

		CMap@ map = getMap();

		AttachmentPoint@ mechanism = this.getAttachments().getAttachmentPointByName("MECHANISM");
		if(mechanism is null) return;

		CBlob@ StickyPistonHead = mechanism.getOccupied();
		if(StickyPistonHead is null) return;

		Tile[] blocksInFront;
		Vec2f[] blobstomove;
		bool pushBlocks = false;
		bool done = false;
		int maxMovDistance = 0;
		while(!done)
		{
			maxMovDistance = maxMovDistance+1;
			//int curposval = MaximumBlocksToMove-maxMovDistance;
			Tile curTile = map.getTile(offset * maxMovDistance * 8 + position);
			if (maxMovDistance > MaximumBlocksToMove+1)
			{	
				pushBlocks = false;
				done = true;
				return;
			}
			if (map.isTileSolid(curTile.type))
			{
				if (map.isTileBedrock(curTile.type))
				{
					pushBlocks = false;
					done = true;
					return;
				}
				blocksInFront.push_back(curTile);
			}
			else
			{
				//CBlob@ isThereBlob = map.getBlobAtPosition(offset * maxMovDistance * 8 + position);
				CBlob@[] blobs;
				getMap().getBlobsAtPosition(offset * maxMovDistance * 8 + position, @blobs);
				bool find = false;
				for(uint i = 0; i < blobs.length; i++)
				{
					CBlob@ blob = blobs[i];
					if (blob !is null && blob.getName() != "spike" && blob.getName() != "pistonhead" && blob.getName() != "stickypistonhead" && blob.getShape().isStatic())
					{
						//print("isThereBlob: "+isThereBlob.getName());
						blocksInFront.push_back(curTile);
						blobstomove.push_back(blob.getPosition());
						find = true;
						break;
					}
				}
				if (!find)
				{
					pushBlocks = true;
					done = true;
				}
			}
		}
		if(pushBlocks)
		{
			StickyPistonHead.set_u8("state", 1);

			CSprite@ sprite = this.getSprite();
			if(sprite is null) return;

			sprite.PlaySound("Out.ogg", 2.0f);
			sprite.getSpriteLayer("background").SetVisible(false);
			for(int i = 0; i<blobstomove.length(); i++)
			{
				CBlob@ tempblob = map.getBlobAtPosition(blobstomove[i]);
				if (tempblob.getName() == "spike" || tempblob.getName() == "pistonhead" || tempblob.getName() == "stickypistonhead")
				{
					CBlob@ spikerorpiston = tempblob.getAttachments().getAttachedBlob("MECHANISM", 0);
					print("tempblob: "+tempblob.getName());
					print("spikerorpiston: "+spikerorpiston.getName());
					string burning_tag = "burning";
					bool onFire = spikerorpiston.hasTag(burning_tag);
					f32 health = spikerorpiston.getHealth();
					Vec2f nextPos = offset * 8 + spikerorpiston.getPosition();
					f32 angle = spikerorpiston.getShape().getAngleDegrees();
					MoveBlob(spikerorpiston, nextPos, health, onFire, angle);
				}
				else if (tempblob.getShape().isStatic())
				{	
					string burning_tag = "burning";
					bool onFire = tempblob.hasTag(burning_tag);
					f32 health = tempblob.getHealth();
					Vec2f nextPos = offset * 8 + tempblob.getPosition();
					f32 angle = tempblob.getShape().getAngleDegrees();
					MoveBlob(tempblob, nextPos, health, onFire, angle);
				}
			}
			for(int i = 0; i<blocksInFront.length(); i++)
			{
				getMap().server_SetTile((offset * (i+2) * 8 + position), blocksInFront[i]);
			}
			getMap().server_SetTile(offset * 8 + position, 0);
			blocksInFront.empty();
			mechanism.offset = Vec2f(0, -9.5);
		}
		else
		{
			blocksInFront.empty();
			this.getSprite().PlaySound("dry_hit.ogg");
		}
	}

	void Deactivate(CBlob@ this)
	{
		AttachmentPoint@ mechanism = this.getAttachments().getAttachmentPointByName("MECHANISM");
		if(mechanism is null) return;

		mechanism.offset = Vec2f(0, -1.5);
		
		CSprite@ sprite = this.getSprite();
		if(sprite is null) return;

		CBlob@ StickyPistonHead = mechanism.getOccupied();
		if(StickyPistonHead is null) return;

		if(StickyPistonHead.get_u8("state") != 0)
		{
			Vec2f position = this.getPosition();
			sprite.PlaySound("In.ogg");
			Tile curTile = getMap().getTile(offset * 16 + position);
			CBlob@[] blob;
			getMap().getBlobsAtPosition(offset * 16 + position, @blob);
			bool find = false;
			if (getMap().isTileSolid(curTile.type))
			{
				if (!getMap().isTileBedrock(curTile.type))
				{
					getMap().server_SetTile((offset * 16 + position), 0);
					getMap().server_SetTile((offset * 8 + position), curTile);
				}
			}
			else
			{
				for(int i = 0; i<blob.length(); i++)
				{
					CBlob@ tempblob = blob[i];
					if (tempblob is null)
						break;
					if (tempblob.getName() == "spike" || tempblob.getName() == "pistonhead" || tempblob.getName() == "stickypistonhead")
					{
						CBlob@ spikerorpiston = tempblob.getAttachments().getAttachedBlob("MECHANISM", 0);
						print("tempblob: "+tempblob.getName());
						print("spikerorpiston: "+spikerorpiston.getName());
						string burning_tag = "burning";
						bool onFire = spikerorpiston.hasTag(burning_tag);
						f32 health = spikerorpiston.getHealth();
						Vec2f nextPos = spikerorpiston.getPosition() - offset * 8;
						f32 angle = spikerorpiston.getShape().getAngleDegrees();
						MoveBlob(spikerorpiston, nextPos, health, onFire, angle);
						break;
					}
					else if (tempblob.getShape().isStatic())
					{	
						string burning_tag = "burning";
						bool onFire = tempblob.hasTag(burning_tag);
						f32 health = tempblob.getHealth();
						Vec2f nextPos = tempblob.getPosition() - offset * 8;
						f32 angle = tempblob.getShape().getAngleDegrees();
						MoveBlob(tempblob, nextPos, health, onFire, angle);
						break;
					}
				}
			}
		}

		StickyPistonHead.set_u8("state", 0);

		sprite.getSpriteLayer("background").SetVisible(true);
	}
	void MoveBlob(CBlob@ this, Vec2f nextposition, f32 hp, bool onfire, f32 angle)
	{
		string bname = this.getName();
		int bteam = this.getTeamNum();
		this.server_Die();
		CBlob@ movedblob = server_CreateBlob(bname, bteam, nextposition);
		movedblob.getShape().SetAngleDegrees(angle);
		movedblob.getShape().SetStatic(true);
		movedblob.server_SetHealth(hp);
		CMap@ map = getMap();
		if (onfire)
			map.server_setFireWorldspace(nextposition, true);
	}
}

void onInit(CBlob@ this)
{
	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by KnightLogic.as
	this.Tag("blocks sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().collidable = true;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f position = this.getPosition() / 8;
	const u16 angle = this.getAngleDegrees();
	const Vec2f offset = Vec2f(0, -1).RotateBy(angle);

	StickyPiston component(position, this.getNetworkID(), offset);
	this.set("component", component);

	this.getAttachments().getAttachmentPointByName("MECHANISM").offsetZ = -5;
	
	AttachmentPoint@ mechanism = this.getAttachments().getAttachmentPointByName("MECHANISM");
	if(mechanism is null) return;

	mechanism.offset = Vec2f(0, -1.5);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		TOPO_CARDINAL,                      // input topology
		TOPO_NONE,                          // output topology
		INFO_LOAD,                          // information
		0,                                  // power
		component.id);                      // id

		CBlob@ StickyPistonHead = server_CreateBlob("stickypistonhead", this.getTeamNum(), this.getPosition());
		StickyPistonHead.setAngleDegrees(this.getAngleDegrees());
		StickyPistonHead.set_u8("state", 0);

		ShapeConsts@ consts = StickyPistonHead.getShape().getConsts();
		consts.mapCollisions = false;
		consts.collideWhenAttached = true;

		this.server_AttachTo(StickyPistonHead, "MECHANISM");
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	sprite.SetZ(500);
	sprite.SetFrameIndex(angle / 90);
	sprite.SetFacingLeft(false);

	CSpriteLayer@ layer = sprite.addSpriteLayer("background", "StickyPiston.png", 8, 16);
	layer.addAnimation("default", 0, false);
	layer.animation.AddFrame(4);
	layer.SetRelativeZ(-100);
	layer.SetFacingLeft(false);
	layer.SetVisible(true);
}

void onDie(CBlob@ this)
{
	if(!getNet().isServer()) return;

	CBlob@ StickyPistonHead = this.getAttachments().getAttachmentPointByName("MECHANISM").getOccupied();
	if(StickyPistonHead is null) return;

	StickyPistonHead.server_Die();
}