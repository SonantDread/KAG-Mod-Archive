/* Skeleton.as
 * author: Aphelion
 *
 * Skeletons are vicious and fast. They aren't as dumb as regular Zombies but have less HP.
 */

#include "RP_Common.as";

#include "CreatureCommon.as";

const string chomp_tag = "chomping";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const u16 BITE_FREQUENCY = 30; // 30 = 1 second

void onInit(CBlob@ this)
{
    string[] tags = {"player"};
	this.set("tags to eat", tags);
	
	string[] names = {"bison", "chicken"};
	this.set("names to eat", names);
	
	this.set_f32("attack damage", 0.5f);
	this.set_string("attack sound", "../Mods/Roleplay/Entities/Creatures/Skeleton/SkeletonAttack");
	this.set_u16("attack frequency", BITE_FREQUENCY);
	
	this.set_u8("coins_on_death", 5);
	
	// MOVE VARS
	CreatureMoveVars vars;
	vars.walkForce.Set(5.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -2.0f);
	vars.climbTime = 10; // lower
	
	this.set("moveVars", vars);
	
	// BRAIN
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 10); // higher is less
	this.set_f32(target_searchrad_property, 144.0f);
	this.set_f32(terr_rad_property, 72.0f);
	this.set_u8(target_lose_random, 48);
	
	this.getBrain().server_SetActive( true );
	
	this.set_f32("gib health", 0.0f); // It's a SKELETON, always gib!
    this.Tag("flesh");
	
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft( x < 0 );
	}
	else
	{
		if (this.isKeyPressed(key_left))
		{
			this.SetFacingLeft( true );
		}
		if (this.isKeyPressed(key_right))
		{
			this.SetFacingLeft( false );
		}
	}
	
	if(getNet().isServer() && getGameTime() % 10 == 0)
	{
		if(this.get_u8(state_property) == MODE_TARGET)
		{
			CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
			if(b !is null && this.getDistanceTo(b) < 72.0f)
			{
				this.Tag(chomp_tag);
			}
			else
			{
				this.Untag(chomp_tag);
			}
		}
		else
		{
			this.Untag(chomp_tag);
		}
		this.Sync(chomp_tag, true);
	}
}

void onDie( CBlob@ this )
{
    this.getSprite().PlaySound( "/SkeletonBreak1" );	
}
