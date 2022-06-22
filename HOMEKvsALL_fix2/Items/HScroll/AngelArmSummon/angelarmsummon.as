#include "Hitters.as";
#include "Knocked.as";
#include "GenericButtonCommon.as";
void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

   	this.set_string("power name", "angelarmsummon");
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

 

							
							server_CreateBlob("angelarm", -1, this.getPosition() + Vec2f(0, -40.0f));

							
		
			}
			

		}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}


