#include "Hitters.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

    this.set_u32("duration", 10 * 30);
   	this.set_string("power name", "default power");
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

        caller.set_bool(this.get_string("power name"), true);
        caller.set_u32(this.get_string("power name") + " duration", getGameTime() + this.get_u32("duration"));

        //Sound::Play("MagicWand.ogg");
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}
