#include "CreatureCommon.as";
#include "Hitters.as";

// Config
const u8 ATTACK_FREQUENCY = 60;
const f32 ATTACK_DAMAGE = 0.25f;
const f32 ATTACK_DISTANCE = 0.5f;
const u16 BLOCK_HIT_CHANCE = 75;
const u16 COINS_ON_DEATH = 1;

void onInit(CBlob@ this)
{
	this.set_u8("attack frequency", ATTACK_FREQUENCY);
	this.set_f32("attack damage", ATTACK_DAMAGE);
	this.set_f32("attack distance", ATTACK_DISTANCE);
	this.set_u16("block hit chance", BLOCK_HIT_CHANCE);
	this.set_u8("attack hitter", Hitters::bite);
	this.set_string("attack sound", "ZombieBite2");
	this.set_u16("coins on death", COINS_ON_DEATH);
	this.set_f32(target_searchrad_property, 512.0f);

    this.getSprite().PlayRandomSound("/SkeletonSpawn");
	this.getShape().SetRotationsAllowed(false);

	this.getBrain().server_SetActive(true);

	this.set_f32("gib health", 0.0f);
    this.Tag("flesh");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (getNet().isClient() && XORRandom(768) == 0)
	{
		this.getSprite().PlaySound("/ZombieHit");
	}

	if (getNet().isServer() && getGameTime() % 10 == 0)
	{
		CBlob@ target = this.getBrain().getTarget();

		if (target !is null && this.getDistanceTo(target) < 72.0f)
		{
			this.Tag(chomp_tag);
		}
		else
		{
			this.Untag(chomp_tag);
		}

		this.Sync(chomp_tag, true);
	}
	
	this.getShape().SetGravityScale(0.8);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= 0.0f)
	{
	    this.getSprite().PlaySound("/ZombieHit");
    }

	return damage;
}


// This is for debugging the mod, please don't touch.
void onRender(CSprite@ this)
{
	if ((getLocalPlayer().getUsername() == "xTheSwiftOnex") && getRules().get_bool("target lines"))
	{
		CBlob@ blob = this.getBlob();
		CBlob@ target = blob.getBrain().getTarget();

		if (target !is null)
		{
			Vec2f mypos = getDriver().getScreenPosFromWorldPos(blob.getPosition());
			Vec2f targetpos = getDriver().getScreenPosFromWorldPos(target.getPosition());
			GUI::DrawArrow2D(mypos,targetpos , SColor(0xffdd2212));
		}
	}
}