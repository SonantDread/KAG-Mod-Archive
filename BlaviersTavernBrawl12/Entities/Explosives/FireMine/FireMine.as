// Mine.as

#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"

const u8 MINE_PRIMING_TIME = 35;

const string MINE_STATE = "mine_state";
const string MINE_TIMER = "mine_timer";
const string MINE_PRIMING = "mine_priming";
const string MINE_PRIMED = "mine_primed";

enum State
{
	NONE = 0,
	PRIMED
};

void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 0.5f);
	this.set_f32("map_damage_radius", 64.0f);
	this.set_f32("map_damage_ratio", 0.2f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.set_u8("custom_hitter", Hitters::mine);

	this.Tag("ignore fall");

	this.Tag(MINE_PRIMING);

	if (this.exists(MINE_STATE))
	{
		if (getNet().isClient())
		{
			CSprite@ sprite = this.getSprite();

			if (this.get_u8(MINE_STATE) == PRIMED)
			{
				sprite.SetFrameIndex(1);
			}
			else
			{
				sprite.SetFrameIndex(0);
			}
		}
	}
	else
	{
		this.set_u8(MINE_STATE, NONE);
	}

	this.set_u8(MINE_TIMER, 0);
	this.addCommandID(MINE_PRIMED);

	this.getCurrentScript().tickIfTag = MINE_PRIMING;
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		//tick down
		if(this.getVelocity().LengthSquared() < 1.0f && !this.isAttached())
		{
			u8 timer = this.get_u8(MINE_TIMER);
			timer++;
			this.set_u8(MINE_TIMER, timer);

			if(timer >= MINE_PRIMING_TIME)
			{
				this.Untag(MINE_PRIMING);
				this.SendCommand(this.getCommandID(MINE_PRIMED));
			}
		}
		//reset if bumped/moved
		else if(this.hasTag(MINE_PRIMING))
		{
			this.set_u8(MINE_TIMER, 35);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID(MINE_PRIMED))
	{
		if (this.isAttached()) return;

		if (this.isInInventory()) return;

		this.set_u8(MINE_STATE, PRIMED);
		this.getShape().checkCollisionsAgain = true;

		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetFrameIndex(1);
			sprite.PlaySound("MineArmed.ogg");
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.Untag(MINE_PRIMING);

	if(this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

	if(this.getDamageOwnerPlayer() is null || this.getTeamNum() != attached.getTeamNum())
	{
		CPlayer@ player = attached.getPlayer();
		if(player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.Untag(MINE_PRIMING);

	if(this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

	if(this.getDamageOwnerPlayer() is null || this.getTeamNum() != inventoryBlob.getTeamNum())
	{
		CPlayer@ player = inventoryBlob.getPlayer();
		if(player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if(getNet().isServer())
	{
		this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if(getNet().isServer() && !this.isAttached())
	{
		this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

bool explodeOnCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() &&
	(blob.hasTag("flesh") || blob.hasTag("projectile") || blob.hasTag("vehicle"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(getNet().isServer() && blob !is null)
	{
		if(this.get_u8(MINE_STATE) == PRIMED && explodeOnCollideWithBlob(this, blob))
		{
			this.Tag("exploding");
			this.Sync("exploding", true);

			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	if(getNet().isServer() && this.hasTag("exploding"))
	{
		const Vec2f POSITION = this.getPosition();

		CBlob@[] blobs;
		getMap().getBlobsInRadius(POSITION, this.getRadius() + 4, @blobs);
		for(u16 i = 0; i < blobs.length; i++)
		{
			CBlob@ target = blobs[i];
			if(target.hasTag("flesh") &&
			(target.getTeamNum() != this.getTeamNum() || target.getPlayer() is this.getDamageOwnerPlayer()))
			{
				this.server_Hit(target, POSITION, Vec2f_zero, 0.5f, Hitters::mine_special, true);
  				ExplodeWithFire(this);
			}
		}
	}
}

void ExplodeWithFire(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null)   return;
    for (int doFire = 0; doFire <= 2 * 8; doFire += 1 * 8) //8 - tile size in pixels
    {
        int variation = 7;
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        variation = 3;
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x, this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(variation)) * 8), this.getPosition().y - ((XORRandom(variation)) * 8)), true);
        map.server_setFireWorldspace(Vec2f(this.getPosition().x - ((XORRandom(variation)) * 8), this.getPosition().y + ((XORRandom(variation)) * 8)), true);
        makeExplosionParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
        makeSmokeParticle(this.getPosition() + getRandomVelocity(300.0f, 14.0f, 360.0f));
    }
    this.getSprite().PlaySound("MolotovExplosion.ogg", 1.6f);
    this.getSprite().PlaySound("Glass-breaking-sound.ogg", 8.2f);
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.get_u8(MINE_STATE) != PRIMED || this.getTeamNum() == blob.getTeamNum();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return customData == Hitters::builder? this.getInitialHealth() / 2 : damage;
}
