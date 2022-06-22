#include "Hitters.as";
#include "Knocked.as";
#include "GenericButtonCommon.as";
const f32 max_range = 16.00f;
void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

   	this.set_string("power name", "mine");
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

 

							
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(32, -230.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-32, -230.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(64, -250.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-64, -250.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(96, -270.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-96, -270.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(128, -290.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-128, -290.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(160, -310.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-160, -310.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(192, -330.0f));
							server_CreateBlob("mine", -1, this.getPosition() + Vec2f(-192, -330.0f));
							
		
			}
			

		}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}


