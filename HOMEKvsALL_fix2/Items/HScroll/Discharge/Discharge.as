#include "Hitters.as";
#include "Knocked.as";
#include "GenericButtonCommon.as";
const f32 max_range = 16.00f;
void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

   	this.set_string("power name", "kaghlos");
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
        this.server_Hit(this, this.getPosition(), Vec2f(0,0), 1.0f, Hitters::fall, true);

        CBlob@ caller = getBlobByNetworkID(params.read_u16());
        if (caller.getPlayer() !is null)
        {
            if (isServer())
            {
                /*CBlob@ lightA = server_CreateBlob("hardlight", caller.getTeamNum(), caller.getAimPos());
				CBlob@ lightA1 = server_CreateBlob("hardlight", caller.getTeamNum(), caller.getAimPos());
				CBlob@ lightA2 = server_CreateBlob("hardlight", caller.getTeamNum(), caller.getAimPos());
                lightA.Tag("SurgeLight");
                lightA.SetDamageOwnerPlayer(caller.getPlayer());
				lightA1.Tag("SurgeLight");
                lightA1.SetDamageOwnerPlayer(caller.getPlayer());
				lightA2.Tag("SurgeLight");
                lightA2.SetDamageOwnerPlayer(caller.getPlayer());
*/
            }
        }
    }
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}


