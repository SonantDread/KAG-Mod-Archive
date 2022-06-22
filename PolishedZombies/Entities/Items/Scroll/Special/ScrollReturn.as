#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("return");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("return"), "Return to a nearby quarters.", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("return"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller != null)
		{
			ParticleZombieLightning(caller.getPosition());

			CBlob@[] potential;
			getBlobsByName("quarters", @potential);
			for (int n = 0; n < potential.length; n++)
			{
				if (potential[n] !is null && potential[n].getTeamNum() == caller.getTeamNum())
				{
					caller.setPosition(potential[n].getPosition());
					ParticleZombieLightning(caller.getPosition());
					break;
				}
			}
			this.server_Die();
		}
	}
}