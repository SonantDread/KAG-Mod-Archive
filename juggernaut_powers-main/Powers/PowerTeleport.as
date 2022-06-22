#include "Logging.as";

const int TELEPORT_FREQUENCY = 4 * 30; //4 secs
const int TELEPORT_DISTANCE = 160 * 1.25;//getMap().tilesize;

void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
}


void onTick( CBlob@ this ) 
{	
	CControls@ controls = getControls();
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	
	if(ready) {
		if (controls.isKeyJustPressed(KEY_KEY_B)) {
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
		
		if(this.isKeyJustPressed( key_taunts ) && this.isMyPlayer()){
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
	CBlob@ smok = server_CreateBlob("teamcoloredlargesmoke", blob.getTeamNum(), blob.getPosition());
	blob.setPosition( pos );
	blob.setVelocity( Vec2f_zero );
	CBlob@ smoke = server_CreateBlob("teamcoloredlargesmoke", blob.getTeamNum(), blob.getPosition());		
	blob.getSprite().PlaySound("/Respawn.ogg");
}