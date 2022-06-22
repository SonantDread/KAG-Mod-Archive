#include "RunnerCommon.as";
#include "Hitters.as";

const float PULL_RADIUS = 32.0;
const float PULL_FORCE = 1.0;
const float MASS_FACTOR = 1.0;

const int CRUSH_FREQUENCY = 30;
const float CRUSH_RADIUS = 32.0;
const float PUSH_RADIUS = 64.0;

void onInit(CBlob@ this) {

    this.getCurrentScript().removeIfTag = "dead";
}

void onInit(CSprite@ this) {
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this) 
{
    

    if ( this.get_bool("grip") == true && getGameTime() < this.get_u32("grip duration"))
	{
	
	

        CBlob@[] blobs;
        getMap().getBlobsInRadius(this.getAimPos(), CRUSH_RADIUS, blobs);
        for (int i=0; i < blobs.length; i++) 
		{
            CBlob@ blob = blobs[i];
            if (blob is null || blob is this  ) continue;
		
            Vec2f delta = this.getAimPos() - blob.getPosition();

            Vec2f force = delta;
            force.Normalize();
            force *= PULL_FORCE * MASS_FACTOR * blob.getMass() * (delta.Length() / PULL_RADIUS);

            blob.AddForce(force);
        }
    }
	
	
	
	

    }






