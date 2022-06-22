// AmmoCrate Script

#include "CrateCommon.as"
#include "MiniIconsInc.as"
#include "Help.as"
#include "Hitters.as"
#include "GenericButtonCommon.as"

//property name
const string required_space = "required space";

//proportion of distance allowed (1.0f == overlapping radius, 2.0f = within 1 extra radius)

void onInit(CBlob@ this)
{
	this.checkInventoryAccessibleCarefully = true;

	u8 frame = 0;
	if (this.exists("frame"))
	{
		frame = this.get_u8("frame");

		u8 newFrame = 0;


		if (newFrame > 0)
		{
			CSpriteLayer@ icon = this.getSprite().addSpriteLayer("icon", "/MiniIcons.png" , 16, 16, this.getTeamNum(), -1);
			if (icon !is null)
			{
				icon.SetFrame(newFrame);
				icon.SetOffset(Vec2f(-2, 1));
				icon.SetRelativeZ(1);
			}
			this.getSprite().SetAnimation("label");
		}
	}
	else
	{
		this.getSprite().SetRelativeZ(-10.0f);

		this.Tag("dont deactivate");
	}

	this.Tag("activated");

	if (!this.exists(required_space))
	{
		this.set_Vec2f(required_space, Vec2f(5, 4));
	}

	this.getSprite().SetZ(-10.0f);


	// Give random loot items
	if (isServer())
	{
		if (XORRandom(2) == 0)
		{
			CBlob@ b = server_CreateBlob("mat_7mmround", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		if (XORRandom(2) == 0)
		{
			CBlob@ b = server_CreateBlob("mat_7mmround", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		if (XORRandom(3) == 0)
		{
			CBlob@ b = server_CreateBlob("mat_14mmround", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		if (XORRandom(2) == 0)
		{
			CBlob@ b = server_CreateBlob("mat_bolts", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		if (XORRandom(2) == 0)
		{
			CBlob@ b = server_CreateBlob("steak", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
		if (XORRandom(20) == 0)
		{
			CBlob@ b = server_CreateBlob("mat_heatwarhead", -1, this.getPosition());
			this.server_PutInInventory(b);
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (forBlob.getCarriedBlob() !is null && this.getInventory().canPutItem(forBlob.getCarriedBlob()))
	{
		return true; // OK to put an item in whenever
	}

	f32 dist = (this.getPosition() - forBlob.getPosition()).Length();
	f32 rad = (this.getRadius() + forBlob.getRadius());

	if (dist < rad * 2.6f)
	{
		return true; // Allies can access from further away
	}

	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	Vec2f buttonpos(0, 0);

	bool putting = caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this;
	bool canput = putting && this.getInventory().canPutItem(caller.getCarriedBlob());
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("thud.ogg");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;

	dmg *= 0.3;

	if (isExplosionHitter(customData) || customData == Hitters::keg)
	{
		if (dmg > 50.0f) // inventory explosion
		{
			this.Tag("crate exploded");
		}
		else
		{
			if (customData == Hitters::keg)
			{
				dmg = Maths::Max(dmg, this.getInitialHealth() * 2); // Keg always kills crate
			}
		}
	}

	return dmg;
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	// Crate gibs
	string fname = CFileMatcher("/Crate.png").getFirst();
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 110), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}

Vec2f crate_getOffsetPos(CBlob@ blob, CMap@ map)
{
	Vec2f halfSize = blob.get_Vec2f(required_space) * 0.5f;

	Vec2f alignedWorldPos = map.getAlignedWorldPos(blob.getPosition() + Vec2f(0, -2)) + (Vec2f(0.5f, 0.0f) * map.tilesize);
	Vec2f offsetPos = alignedWorldPos - Vec2f(halfSize.x , halfSize.y) * map.tilesize;
	return offsetPos;
}

// SPRITE
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	Vec2f pos2d = blob.getScreenPos();
	u32 gameTime = getGameTime();

	if (blob.isAttached())
	{
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");

		CBlob@ holder = point.getOccupied();

		if (holder is null) { return; }

		CPlayer@ local = getLocalPlayer();
		if (local !is null && local.getBlob() is holder)
		{
			CMap@ map = blob.getMap();
			if (map is null) return;

			Vec2f space = blob.get_Vec2f(required_space);
			Vec2f offsetPos = crate_getOffsetPos(blob, map);

			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			Vec2f aligned = getDriver().getScreenPosFromWorldPos(offsetPos);
			GUI::DrawIcon("CrateSlots.png", 0, Vec2f(40, 32), aligned, zoom);

			for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
			{
				for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
				{
					Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
					Vec2f v = offsetPos + temp;
					if (map.isTileSolid(v))
					{
						GUI::DrawIcon("CrateSlots.png", 5, Vec2f(8, 8), aligned + (temp - Vec2f(0.5f, 0.5f)* map.tilesize) * 2 * zoom, zoom);
					}
				}
			}
		}
	}
}