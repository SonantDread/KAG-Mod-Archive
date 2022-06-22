#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("summon chickens");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("summon chickens"), "Summons a chicken family!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("summon chickens"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller != null)
		{
			ParticleZombieLightning(this.getPosition());
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob("chicken", caller.getTeamNum(), this.getPosition());
			}
			this.server_Die();
			Sound::Play("SuddenGib.ogg");
		}
	}
}