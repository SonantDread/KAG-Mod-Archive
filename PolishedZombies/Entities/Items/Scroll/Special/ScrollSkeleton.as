#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("summon skeletons");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("summon skeletons"), "Summon 3 friendly skeletons.", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("summon skeletons"))
	{
		ParticleZombieLightning(this.getPosition());

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller != null)
		{
			if (getNet().isServer())
			{
				for (int i = 0; i < 3; i++)
				{
					server_CreateBlob("skeleton", caller.getTeamNum(), caller.getAimPos());
				}
				this.server_Die();
			}
			Sound::Play("SuddenGib.ogg");
		}
	}
}