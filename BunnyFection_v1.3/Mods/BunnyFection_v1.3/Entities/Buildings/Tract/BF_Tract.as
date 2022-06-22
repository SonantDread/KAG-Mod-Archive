﻿//BF_Tract script

#include "BF_TractCommon.as"
#include "BF_Costs.as"

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 45;
	this.set_u16( "lastHit", 0 );
	this.Tag( "flesh" );
	this.Tag( "mutant" );
	this.Tag( "building" );
	this.getSprite().SetZ( -5.0f );
}

void onTick( CBlob@ this )
{
	//make distance checks for nearby tunnel/hatchery. if too far, get damaged
	

	//anim
	if ( this.getSprite().isAnimationEnded() )
		this.getSprite().SetAnimation( "default" );
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