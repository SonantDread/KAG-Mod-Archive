#include "AnimalConsts.as";
const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = blob.getVelocity().x;
		f32 y = blob.getVelocity().y;
		if (!blob.isOnMap()) // In Air
		{
			if (y > 1.5f)
			{
				this.SetAnimation("fall");
			}
			else
			{
				this.SetAnimation("jump");
			}
			if ((Maths::Abs(x) > 2.8f))
			{
				this.SetAnimation("run");
			}
		}
		else // On Ground
		{
			if (Maths::Abs(x) > 0.2f)
			{
				if ((Maths::Abs(x) > 2.2f))
				{
					this.SetAnimation("run");
				}
				else
				{
					this.SetAnimation("walk");
				}
			}
			else
			{
				this.SetAnimation("idle");
			}
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}	 		  
}

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.set_u8("number of steaks", 3);

	// Brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 999);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 150.0f);
	this.getBrain().server_SetActive(true);

	// Sprite/Rotation
	this.getShape().SetRotationsAllowed(false);
	this.getShape().SetOffset(Vec2f(0, 6));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 90.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	f32 y = this.getVelocity().y;

	// Sprite Flipping
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft(x < 0);
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft(false);
		}
	}

	// Footstep SFX
	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
	{
		if ((this.getNetworkID() + getGameTime()) % 10 == 0)
		{
			f32 volume = Maths::Min(0.1f + Maths::Abs(this.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = this.getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;
			if (this.getMap().isTileGroundStuff(tile))
			{
				this.getSprite().PlaySound("/EarthStep", volume, 0.65f);
			}
			else
			{
				this.getSprite().PlaySound("/StoneStep", volume, 0.65f);
			}
		}
	}

	// Movement
	if (!this.isOnMap()) // In Air
	{
		if ((Maths::Abs(x) < 6.1f))
		{
			Vec2f vel = this.getVelocity();
			this.setVelocity(vel * 1.04);
		}
	}
	else // On Ground
	{
		if ((Maths::Abs(x) < 8.1f))
		{
			Vec2f vel = this.getVelocity();
			this.setVelocity(vel * 1.08);
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	// Taming Animal
	if (blob is null) return;
	if (blob.getPlayer() != null)
	{
		if (blob !is null)
		{
			this.set_u8(state_property, MODE_FRIENDLY);
			this.set_netid(friend_property, blob.getNetworkID());
		}
	}
}