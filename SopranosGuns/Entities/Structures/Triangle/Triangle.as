//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;
    this.server_setTeamNum(-1); //allow anyone to break them  
    //this.Tag("place norotate");
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}



void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}




bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 2.9f;
		break;
			
	case Hitters::bomb:
		dmg = 1.2f;
		break;

	case Hitters::keg:
		dmg = 10.0f;
		break;
	case Hitters::arrow:
		dmg = 0.0f;
		break;

	case Hitters::cata_stones:
		dmg = 2.0f;
		break;

	case Hitters::sword:
		dmg *= 0.0f;
		break;
		
	default:
		dmg *= 1.0f;
		break;
	}		
	return dmg;
}
