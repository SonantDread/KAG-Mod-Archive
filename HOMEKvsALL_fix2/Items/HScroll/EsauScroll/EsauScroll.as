#include "Hitters.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

    this.set_u32("duration", 10 * 30);
   	this.set_string("power name", "esau");
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
            if (isServer())
            {
                CBlob@ clone = server_CreateBlob("knight", caller.getTeamNum(), caller.getPosition());
                clone.Tag("esau_clone");
                clone.SetDamageOwnerPlayer(caller.getPlayer());
                u16[] clones;
                caller.get("clones", clones);
                clones.insertLast(clone.getNetworkID());
                caller.set("clones", clones);

                this.server_Die();
            }
            //Sound::Play("MagicWand.ogg");
        }
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}
