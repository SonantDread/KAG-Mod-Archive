// Dispenser.as

#include "MechanismsCommon.as";
class Booster : Component
{
		u16 id;
	f32 angle;
	Vec2f offset;

	Booster(Vec2f position, u16 _id, f32 _angle, Vec2f _offset)
	{
		x = position.x;
		y = position.y;

		id = _id;
		angle = _angle;
		offset = _offset;
	}
	void Activate(CBlob@ this)
	{

		this.set_bool("is active", true);
		this.getSprite().SetAnimation("roll");
		//print("active");
	}

	void Deactivate(CBlob@ this)
	{
		this.set_bool("is active", false);
		this.getSprite().SetAnimation("default");
	

	}
}
/*
class Dispenser : Component
{
	u16 id;
	f32 angle;
	Vec2f offset;

	Dispenser(Vec2f position, u16 _id, f32 _angle, Vec2f _offset)
	{
		x = position.x;
		y = position.y;

		id = _id;
		angle = _angle;
		offset = _offset;
	}

	CBlob@ blob = this.getBlob();

	void Deactivate(CBlob@ this)
	{
		CBlob@ sprite = this.getSprite();

		this.SetAnimation("default");
		
	}

	void Activate(CBlob@ this)
	{
		CBlob@ sprite = this.getSprite();

		this.SetAnimation("roll");


		
	}


		ParticleAnimated(
		"DispenserFire.png",                // file name
		position + (offset * 8),            // position
		Vec2f_zero,                         // velocity
		angle,                              // rotation
		1.0f,                               // scale
		3,                                  // ticks per frame
		0.0f,                               // gravity
		false);                             // self lit
	
	}
}
*/
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	//shape.AddPlatformDirection(Vec2f(0, -1), 70, false);
	shape.SetRotationsAllowed(false);
	this.Tag("place ignore facing");

	//this.Tag("place norotate");

	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by KnightLogic.as
	this.Tag("blocks sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f position = this.getPosition() / 8;
	const u16 angle = this.getAngleDegrees();
	const Vec2f offset = Vec2f(0, -1).RotateBy(angle);

	Booster component(position, this.getNetworkID(), angle, offset);
	this.set("component", component);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		TOPO_CARDINAL,                      // input topology
		TOPO_CARDINAL,                          // output topology
		INFO_LOAD,                          // information
		0,                                  // power
		component.id);                      // id
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(-50);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)
	{
		blob.AddForce(Vec2f((this.getMass()/20), 0.0f));
	}
}
//bool isColliding*/
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)
	{
		//f32 angel = this.getAngleDegrees();
		//printf("angel: "+angel);

		if (this.get_bool("is active")) 
		{
			this.set_bool("is colliding", true);
			if (this.getAngleDegrees()==0.0f)
			{
				blob.setVelocity(Vec2f(6.0f, (this.getVelocity().y)));

				//printf("right");
			}
			if (this.getAngleDegrees()==90.0f)
			{
				blob.setVelocity(Vec2f(0.0f, 2.0f));

				//printf("down");
			}

			if (this.getAngleDegrees()==180.0f)
			{
				blob.setVelocity(Vec2f(-6.0f, -3.0f));

				//printf("left");
			}

			if (this.getAngleDegrees()==270.0f)
			{
				blob.setVelocity(Vec2f(0.0f, -8.0f));

				//printf("up");
			}


		}


		if (this.getTeamNum()==101)
		{

			if (this.get_bool("is active")) 
			{
				this.set_bool("is colliding", true);
				if (this.getAngleDegrees()==0.0f)
				{
					blob.setVelocity(Vec2f(25.0f, -3.0f));

					//printf("right");
				}
				if (this.getAngleDegrees()==90.0f)
				{
					blob.setVelocity(Vec2f(0.0f, 10.0f));

					//printf("down");
				}

				if (this.getAngleDegrees()==180.0f)
				{
					blob.setVelocity(Vec2f(-25.0f, -3.0f));

					//printf("left");
				}

				if (this.getAngleDegrees()==270.0f)
				{
					blob.setVelocity(Vec2f(0.0f, -15.0f));

					//printf("up");
				}
			}
		}

		if (this.getTeamNum()==99)
		{

			if (this.get_bool("is active")) 
			{
				this.set_bool("is colliding", true);
				if (this.getAngleDegrees()==0.0f)
				{
					blob.setVelocity(Vec2f(50.0f, -3.0f));

					//printf("right");
				}
				if (this.getAngleDegrees()==90.0f)
				{
					blob.setVelocity(Vec2f(0.0f, 25.0f));

					//printf("down");
				}

				if (this.getAngleDegrees()==180.0f)
				{
					blob.setVelocity(Vec2f(-50.0f, -3.0f));

					//printf("left");
				}

				if (this.getAngleDegrees()==270.0f)
				{
					blob.setVelocity(Vec2f(0.0f, -25.0f));

					//printf("up");
				}
			}
		}

	}
}
void onEndCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)
	{
		//f32 angel = this.getAngleDegrees();
		//printf("angel: "+angel);

		if (this.get_bool("is active")) 
		{
			this.set_bool("is colliding", true);
			if (this.getAngleDegrees()==0.0f)
			{
				blob.setVelocity(Vec2f(6.0f, -3.0f));

				//printf("right");
			}
			if (this.getAngleDegrees()==90.0f)
			{
				blob.setVelocity(Vec2f(0.0f, 2.0f));

				//printf("down");
			}

			if (this.getAngleDegrees()==180.0f)
			{
				blob.setVelocity(Vec2f(-6.0f, -3.0f));

				//printf("left");
			}

			if (this.getAngleDegrees()==270.0f)
			{
				blob.setVelocity(Vec2f(0.0f, -8.0f));

				//printf("up");
			}


		}

	}

}