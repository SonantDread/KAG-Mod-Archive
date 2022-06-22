// Lantern script
#include "Knocked.as";
#include "Hitters.as";
#include "FireCommon.as";
const f32 max_range = 1200.00f;
const int TELEPORT_FREQUENCY = 900; //4 secs
const int TELEPORT_DISTANCE = 32;//getMap().tilesize;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 0, 0, 0));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$lantern on$", "Lantern.png", Vec2f(8, 8), 0);
	AddIconToken("$lantern off$", "Lantern.png", Vec2f(8, 8), 3);
	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");
	this.Tag("ignore fall");
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CBlob@ this)
{

  bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	CBlob@[] blobs;

	
	if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs) && this.hasTag("blindr"))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			
			
			
			
				if(ready) {
				if(this.hasTag("blindr")) {
				Vec2f delta = this.getPosition() - blob.getPosition();
				if(delta.Length() > TELEPORT_DISTANCE )
				{
				this.set_u32("last teleport", gametime);
				this.set_bool("teleport ready", false );
				if(blob.hasTag("flesh"))
				{
				Teleport(blob, this.getPosition());
				}
			} 	

		}
	} 
	
		else {		
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/sand_fall.ogg"); 
		}
	}
			
		}
	}
}

void Light(CBlob@ this, bool on)
{
	CBlob@[] blobs;
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
		this.Untag("blindr");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
		this.Tag("blindr");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
	
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic();
}

void Teleport( CBlob@ blob, Vec2f pos){	
	AttachmentPoint@[] ap;
	blob.getAttachmentPoints(ap);
	blob.hasTag("flesh");
	for (uint i = 0; i < ap.length; i++){
		if(!ap[i].socket && ap[i].getOccupied() !is null){
			@blob = ap[i].getOccupied();
			break;
		}
	}
	blob.setPosition( pos );
	blob.setVelocity( Vec2f_zero );	
	blob.getSprite().PlaySound("/gasp.ogg");
}