//BF_Tract script


#include "BF_Costs.as"
#include "CheckSpam.as";
void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 45;
	this.set_u16( "lastHit", 0 );
	this.Tag( "flesh" );
	this.Tag( "mutant" );
	this.Tag( "building" );
	this.getSprite().SetZ( -5.0f );
}


void onTick( CSprite@ this )
{
	//anim
	if ( this.isAnimationEnded() )
		this.SetAnimation( "default" );
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//anim
	this.getSprite().SetAnimation( "hit" );

	if ( this.getTeamNum() != hitterBlob.getTeamNum() )
	{
		this.set_u16( "lastHit", getGameTime() );
		Sound::Play( "FleshHit.ogg", this.getPosition() );
	}
	ParticleBloodSplat( worldPoint, true );

	return damage;
}
bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return ( forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) );
}