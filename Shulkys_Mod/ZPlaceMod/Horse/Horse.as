
//script for a bison

#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = blob.getVelocity().x;
		if (Maths::Abs(x) > 0.2f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{


	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 12);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);

	this.getBrain().server_SetActive(true);

	//for steaks
	this.set_u8("number of steaks", 1);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");

	this.set_s16("mad timer", 0);

	this.getShape().SetOffset(Vec2f(0, 6));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false; //maybe make a knocked out state? for loading to cata?
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;

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


	// footsteps

	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
	{
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min(0.1f + Maths::Abs(this.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = this.getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;

			if (this.getMap().isTileGroundStuff(tile))
			{
				this.getSprite().PlaySound("/EarthStep", volume, 0.75f);
			}
			else
			{
				this.getSprite().PlaySound("/StoneStep", volume, 0.75f);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)
		return;

	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
		
	

	// eat cake	and make friends
	
	if (blob.getName() == "food")
	{
		this.getSprite().PlaySound("/Eat.ogg");
		this.server_SetHealth(this.getInitialHealth());
		blob.server_Die();

		//if (blob.getPosition().x < this.getPosition().x)crash
		//	blob.setKeyPressed( key_left, true );
		//else
		//	blob.setKeyPressed( key_right, true );

		CPlayer@ owner = blob.getDamageOwnerPlayer();
		if (owner !is null)
		{
			CBlob@ ownerblob = owner.getBlob();
			if (ownerblob !is null)
			{
				this.set_u8(state_property, MODE_FRIENDLY);
				this.set_netid(friend_property, ownerblob.getNetworkID());
			}
		}
	}
	
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 80.0f;
		hitBlob.AddForce(force);
	}
}