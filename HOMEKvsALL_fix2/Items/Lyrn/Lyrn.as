
#include "Hitters.as";

const u8 LYRN_SETUP_TIME = 100;

const string LYRN_STATE = "lyrn_state";
const string LYRN_TIME = "lyrn_time";
const string LYRN_SETUP = "lyrn_setup";
const string LYRN_SETED = "lyrn_seted";

enum State
{
	NONE = 0,
	SETED
};

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	if (shape is null) return;
	
	shape.SetRotationsAllowed(false);
	this.set_u8("custom_hitter", Hitters::fire);

	this.Tag("ignore fall");
	this.Tag("ignore_saw");
	this.Tag("flesh");
	this.Tag(LYRN_SETUP);
	this.Tag("Obelisk");
	this.Tag("medium weight");

	this.set_u8(LYRN_STATE, NONE);
	this.set_u8(LYRN_TIME, 0);
	this.addCommandID(LYRN_SETED);
	
	this.getShape().getConsts().collideWhenAttached = true;

	this.getCurrentScript().tickIfTag = LYRN_SETUP;
	
	//this.getShape().SetGravityScale(0.008f);
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		u8 timer = this.get_u8(LYRN_TIME);
		timer++;
		this.set_u8(LYRN_TIME, timer);

		if(timer >= LYRN_SETUP_TIME)
		{
			this.Untag(LYRN_SETUP);
			this.SendCommand(this.getCommandID(LYRN_SETED));
		}
	}
	
}



void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID(LYRN_SETED))
	{
		this.set_u8(LYRN_STATE, SETED);
		this.getShape().checkCollisionsAgain = true;
		this.Tag("MENDING");

		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			this.getSprite().PlaySound("/sand_fall.ogg"); 
			sprite.SetFrameIndex(1);
			
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.Untag(LYRN_SETUP);

	if(this.get_u8(LYRN_STATE) == SETED)
	{
		this.Untag("MENDING");
		this.set_u8(LYRN_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if(getNet().isServer())
	{
		this.Tag(LYRN_SETUP);
		this.set_u8(LYRN_TIME, 0);
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if(getNet().isServer() && !this.isAttached())
	{
		this.Tag(LYRN_SETUP);
		this.set_u8(LYRN_TIME, 0);
	}
}



bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	return damage;
}



bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return blob.getTeamNum() == this.getTeamNum();
}

