#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("summon horde");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("summon horde"), "Summon a zombie horde.", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (cmd == this.getCommandID("summon horde"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller != null)
		{
			ParticleZombieLightning(this.getPosition());
			if (getNet().isServer())
			{
				for (int i = 0; i < 10; i++)
				{
					int random = XORRandom(5);
					if (random == 0)
					{
						server_CreateBlob("zombie", caller.getTeamNum(), caller.getAimPos());
					}
					else if (random == 1)
					{
						server_CreateBlob("zknight", caller.getTeamNum(), caller.getAimPos());
					}
					else if (random == 2)
					{
						server_CreateBlob("skeleton", caller.getTeamNum(), caller.getAimPos());
					}
					else if (random == 3)
					{
						server_CreateBlob("ankou", caller.getTeamNum(), caller.getAimPos());
					}
					else if (random == 4)
					{
						server_CreateBlob("catto", caller.getTeamNum(), caller.getAimPos());
					}
					else
					{
						server_CreateBlob("horror", caller.getTeamNum(), caller.getAimPos());
					}
				}
				this.server_Die();
			}
			
			Sound::Play("SuddenGib.ogg");
		}
	}
}