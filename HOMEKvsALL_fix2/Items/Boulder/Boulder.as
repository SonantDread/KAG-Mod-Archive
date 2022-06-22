#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";

const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

const bool shatter_from_cata_only = true; // should boulder shatter only if launched from a catapult

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);

	this.server_setTeamNum(-1);

	this.Tag("medium weight");

	LimitedAttack_setup(this);

	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (this.hasTag("player controlled")) return;

	this.set_u8("launch team", detached.getTeamNum());
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.hasTag("player controlled")) return;

	if (attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}

	if (attached.getName() != "catapult") // end of rock and roll
	{
		this.Untag("rock_n_roll");
	}
	this.set_u8("launch team", attached.getTeamNum());
}

void shatter(CBlob@ this, u16 rocks_amount, f32 min_vel, f32 max_vel_inc)
{
	for (int i = 0; i < rocks_amount; i++)
		{
			CBlob@ rock = server_CreateBlob("cata_rock", this.get_u8("launch team"), this.getPosition());
			rock.Tag("fromBoulder");
			rock.Sync("fromBoulder", true);
			if (this.getDamageOwnerPlayer() !is null)
				rock.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());

			Vec2f vel = Vec2f(XORRandom(max_vel_inc*10)*0.1f+min_vel,0.0f);

			f32 angle = XORRandom(3600)*0.1f;
			if (i <= 5)
				angle = (this.getOldVelocity().AngleDegrees()+XORRandom(900)*0.1f-45.0f);

			vel.RotateBy(angle);
			rock.setVelocity(vel);
		}
		this.server_Die();
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{

	Vec2f hitvel = this.getOldVelocity();
	f32 vellen = hitvel.Length();
	
	if (solid && isServer())
	{
		if ((this.hasTag("rock_n_roll") || (vellen > 7.5f && !shatter_from_cata_only)) && !this.hasTag("shattered"))
		{
			this.Tag("shattered"); //without this, it sometimes shatters 2-5 times for some reason
			shatter(this, 12, 4.0f, 4.0f);
		}
	}

	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);


		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		if (isServer())
		{
			if ((this.hasTag("rock_n_roll") || (vellen > 7.5f && !shatter_from_cata_only)) && !this.hasTag("shattered"))
			{
				this.Tag("shattered");
				shatter(this, 12, 4.0f, 4.0f);
			}
		}

		//bounce off if not gibbed
		if (dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		return;

	}

}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	if (this.getPlayer() !is null && customData == Hitters::fall)
	{
		damage *= 0.5f;

		if (this.hasTag("player controlled"))
		damage *= 0.0f;
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	string name = blob.getName();

	if (this.hasTag("player controlled") && blob.getTeamNum() == this.getTeamNum()) 
	{
		return false; 
	}

	else return true;
}

//sprite

void onInit(CSprite@ this)
{
	this.animation.frame = (this.getBlob().getNetworkID() % 4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
