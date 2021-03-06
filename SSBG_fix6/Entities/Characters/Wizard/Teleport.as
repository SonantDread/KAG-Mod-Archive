
#include "WizardCommon.as";
#include "MakeDustParticle.as";

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
		if(this.isKeyJustPressed( key_action2 )) {
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
		
		if(this.isKeyJustPressed( key_action2 ) && this.isMyPlayer()){
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/EvilNotice.ogg"); 
		}
	}
}

void Teleport( CBlob@ blob, Vec2f pos){	
	AttachmentPoint@[] ap;
	blob.getAttachmentPoints(ap);
	for (uint i = 0; i < ap.length; i++){
		if(!ap[i].socket && ap[i].getOccupied() !is null){
			@blob = ap[i].getOccupied();
			break;
		}
	}
	ParticleZombieLightning( blob.getPosition() );
	MakeParticle( blob.getPosition(),
								"Hit5.png", 500.0 );
	blob.setPosition( pos );
	blob.setVelocity( Vec2f_zero );
	ParticleZombieLightning( pos );
	MakeParticle( pos,
								"Hit5.png", 500.0 );
	blob.getSprite().PlaySound("/Respawn.ogg");
}
