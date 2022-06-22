#define SERVER_ONLY
#include "Hitters.as";
// AMOGUS
const f32 max_range = 64.00f;

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if ( this.get_bool("amogus") == true)
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
								f32 factor = 1.0f - Maths::Pow(dist / max_range, 2);
			if ( blob.hasTag("dead") && (blob.getTeamNum() != this.getTeamNum()))
			{
			
					this.server_setTeamNum(blob.getTeamNum());
					this.Tag("IMPOSTOR");
					this.getCurrentScript().removeIfTag = "VENTED";

				}
				

			}
			

		}
	}
	
	
	
	}
		if (this.hasTag("IMPOSTOR") && (this.isKeyPressed(key_action1) || this.isKeyPressed(key_action2) || this.isKeyPressed(key_action3) || this.isKeyPressed(key_pickup) || this.isKeyPressed(key_eat)) )
		{
			this.Tag("VENTED");
			this.server_setTeamNum(2);
			this.server_SetTimeToDie(15);
		}

	}
	
	


