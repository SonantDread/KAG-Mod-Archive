// Mine.as

#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";

const string required_class = "assassin";

const u8 MINE_PRIMING_TIME = 45;

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
			this.set_u8(MINE_TIMER, 0);
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
		this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 1.0f, Hitters::spikes, true);
		SetKnocked(blob, 50);
			CBlob@ dead = server_CreateBlob("trapdead", -1, this.getPosition());
			this.server_Die();
			Sound::Play("SpikerThrust.ogg");

		}
	}
}
		

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return blob.getName() == required_class && this.getTeamNum() == blob.getTeamNum() || blob.getName() == required_class && this.get_u8(MINE_STATE) != PRIMED;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return customData == Hitters::builder? this.getInitialHealth() / 2 : damage;
}
