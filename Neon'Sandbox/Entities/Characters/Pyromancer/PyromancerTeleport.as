
#include "PyromancerCommon.as";

void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
}


void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	
	if(ready) {
		if (this.isKeyJustPressed( key_action3)) {
			Vec2f delta = this.getPosition() - this.getAimPos();
			if(delta.Length() < TELEPORT_DISTANCE){
				this.set_u32("last teleport", gametime);
				this.set_bool("teleport ready", false );
				Teleport(this, this.getAimPos());
			} else if(this.isMyPlayer()) {
				Sound::Play("option.ogg");
			}
		}
	} else {		
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		
		if(this.isKeyJustPressed( key_action3 ) && this.isMyPlayer()){
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/Cooldown2.ogg"); 
		}
	}
}

void Teleport( CBlob@ this, Vec2f aimpos){	
{
	ParticleAnimated( "/LargeSmoke.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
	ParticleAnimated( "/FireFlash.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 2, -0.1f, false );
	this.getSprite().PlaySound("/FireRoar.ogg");
    this.setPosition( aimpos );
    this.setVelocity( Vec2f_zero );
    ParticleAnimated( "/LargeSmoke.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
    ParticleAnimated( "/FireFlash.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 2, -0.1f, false );
    this.getSprite().PlaySound("/Respawn.ogg");
	}
}

