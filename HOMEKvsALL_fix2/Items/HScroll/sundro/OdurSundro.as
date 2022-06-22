#include "Knocked.as";
#include "Hitters.as";

const f32 max_range = 96.00f;
const float field_force = 0.60;
const float mass = 1.0;

const float first_radius = 64.0;
const float second_radius = 110.0;

void onInit(CBlob@ this) {

    this.getCurrentScript().removeIfTag = "dead";
}

void onInit(CSprite@ this) {
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this) 
{
    if ( this.get_bool("sundro") == true && getGameTime() < this.get_u32("sundro duration"))
	{
        CBlob@[] blobs;
	
	    if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs))
	    {
            for (int i = 0; i < blobs.length; i++)
            {
    			CBlob@ blob = blobs[i];
			
	    		if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
		    	{
			    	f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				    f32 factor = 1.00f - Maths::Pow(dist / max_range, 2);
                    CBlob@[] blobs;
                    getMap().getBlobsInRadius(this.getPosition(), first_radius, blobs);
                    for (int i=0; i < blobs.length; i++) 
                    {
                        CBlob@ blob = blobs[i];
                        if ( blob.getTeamNum() == this.getTeamNum() ) continue;

                        Vec2f delta = this.getPosition() - blob.getPosition();

                        Vec2f force = -delta;
                        force.Normalize();
                        force *= field_force * mass * blob.getMass() * (delta.Length() / second_radius);

                        blob.AddForce(force);
                    }
                }
			}
		}
    }
}






