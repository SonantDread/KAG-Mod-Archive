// Lamp.as

#include "MechanismsCommon.as";

class Lamp : Component
{
	u16 id;

	Lamp(Vec2f position, u16 _id)
	{
		x = position.x;
		y = position.y;

		id = _id;
	}

	void Activate(CBlob@ this)
	{
		this.getSprite().SetFrameIndex(1);
		
		CMap@ Map = getMap();
		
		for(int i =-20 ; i < 20; i++) //7
		{
			for(int x = -20; x < 20; x++) //7
			{
			
				Vec2f tilespace = Map.getTileSpacePosition(this.getPosition());
				const int offset = Map.getTileOffsetFromTileSpace(tilespace + Vec2f(x,i));
				Vec2f tilespace2 = Map.getTileSpacePosition(offset);

				Map.server_setFloodWaterTilespace(tilespace2.x, tilespace2.y, false);
		
			}
		
		}
	}

	void Deactivate(CBlob@ this)
	{
		this.getSprite().SetFrameIndex(0);
	}
}

void onInit(CBlob@ this)
{
	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by BlobPlacement.as
	this.Tag("place ignore facing");

	// used by KnightLogic.as
	this.Tag("block sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);

	// background, let water overlap
	this.getShape().getConsts().waterPasses = true;

	this.SetLight(false);
	//this.SetLightRadius(96.0f);
	//this.SetLightColor(SColor(255, 255, 240, 171));
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic || this.exists("component")) return;

	const Vec2f POSITION = this.getPosition() / 8;
	const u16 ANGLE = this.getAngleDegrees();

	Lamp component(POSITION, this.getNetworkID());
	this.set("component", component);

	if (getNet().isServer())
	{
		MapPowerGrid@ grid;
		if (!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		rotateTopology(ANGLE, TOPO_DOWN),   // input topology
		TOPO_NONE,                          // output topology
		INFO_LOAD,                          // information
		0,                                  // power
		component.id);                      // id
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		const bool FACING = false;

		sprite.SetZ(-55);
		sprite.SetFacingLeft(FACING);

		CSpriteLayer@ layer = sprite.addSpriteLayer("background", "ElectricSponge.png", 16, 16);
		layer.addAnimation("default", 0, false);
		layer.animation.AddFrame(2);
		layer.SetRelativeZ(-1);
		layer.SetFacingLeft(FACING);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}