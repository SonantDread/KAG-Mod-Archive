#include "Hitters.as";
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.02f);

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.server_setTeamNum(9);

	this.Tag("flesh");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}
	
	if (getNet().isServer() && !blob.hasTag("dead") && blob.hasTag("player"))
	{
        this.server_Die();

        if (this.getTickSinceCreated() > 75)
        {
        	Sound::Play("/depleting.ogg", this.getPosition(), 1.0f);
        }
        else
        {
        	Sound::Play("/BombBounce.ogg", this.getPosition(), 1.25f);
        }
	}
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() > 170)
	{
		this.server_Die();
		Sound::Play("/depleted.ogg", this.getPosition(), 0.8f);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.getTickSinceCreated() > 75)
	{
		this.SetAnimation("late");
	}
	else
	{
		this.SetAnimation("default");
	}
}

void onDie(CBlob@ this)
{
    if (isServer())
    {
        CBlob@ b = server_CreateBlob("movementblob");

        if (b !is null)
        {
            b.setPosition(Vec2f(this.getPosition().x+(XORRandom(320)-160),this.getPosition().y+(XORRandom(50)-25)));
        }
    }
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}