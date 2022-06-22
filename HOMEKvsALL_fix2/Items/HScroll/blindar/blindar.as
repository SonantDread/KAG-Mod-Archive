#include "Hitters.as";
#include "Knocked.as";
#include "GenericButtonCommon.as";
const f32 max_range = 500.00f;
void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

   	this.set_string("power name", "blindr");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;
    if (!this.isAttachedTo(caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("activate"), "Activate", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("activate"))
    {
        this.server_Die();

        CBlob@ caller = getBlobByNetworkID(params.read_u16());
        if (caller.getPlayer() !is null)
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
			if (blob.getTeamNum() != this.getTeamNum())
			{

				 SetKnocked(blob, 65 * factor);
			
				if (blob is getLocalPlayerBlob())
				{		
					SetScreenFlash(255, 0, 0, 0, 20);	
				}
				}
				
				if (blob.getTeamNum() == this.getTeamNum())
			{

			
				if (blob is getLocalPlayerBlob())
				{		
					SetScreenFlash(255, 0, 0, 0, 2);	
				}
				}
			}
			

		}
	}
            //Sound::Play("MagicWand.ogg");
        }
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}
