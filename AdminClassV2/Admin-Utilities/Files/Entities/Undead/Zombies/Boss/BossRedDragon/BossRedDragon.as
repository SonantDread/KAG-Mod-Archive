// Aphelion \\

#include "CreatureCommon.as";
#include "Hitters.as";

const u8 ATTACK_FREQUENCY = 80;
const f32 ATTACK_DAMAGE = 1.0f;
const f32 ATTACK_DISTANCE = 6.0f;
const int COINS_ON_DEATH = 1250;

void onInit(CBlob@ this)
{
	TargetInfo[] infos;

	{
		TargetInfo i("survivorplayer", 1.0f, true, true);
		infos.push_back(i);
	}
		
	
	this.set("target infos", @infos);
		this.set_u8("attack frequency", ATTACK_FREQUENCY);
	this.set_f32("attack damage", ATTACK_DAMAGE);
	this.set_f32("attack distance", ATTACK_DISTANCE);
	this.set_u8("attack hitter", Hitters::fire);
		
	this.set_string("attack sound", "minotaur_attack");
	this.set_u16("coins on death", COINS_ON_DEATH);
	this.set_f32(target_searchrad_property, 512.0f);

    this.getSprite().SetEmitSound("DragonFlying.ogg");
    this.getSprite().SetEmitSoundPaused(false);

    this.getSprite().PlayRandomSound("/x");
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
		this.getSprite().PlaySound("/DragonFireBreath");
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
}


f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (damage >= 0.0f)
	{
	    this.getSprite().PlaySound( "/ZombieHit" );
    }
	return damage;
}

void onDie( CBlob@ this )
{
    this.getSprite().PlaySound("/DragonFireBreath2");	
}