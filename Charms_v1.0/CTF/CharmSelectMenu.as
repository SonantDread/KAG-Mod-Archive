//stuff for building respawn menus

#include "RespawnCommandCommon.as"

//class for getting everything needed for charms

shared class PlayerCharm
{
	string name;
	string iconFilename;
	string iconName;
	string configFilename;
	string description;
	uint8 slots;
};

const f32 CHARM_BUTTON_SIZE = 2;

//adding a charm to a blobs list of charms

void addPlayerCharm(CBlob@ this, string name, string iconName, string configFilename, string description, uint8 slots)
{
	if (!this.exists("playercharms"))
	{
		PlayerCharm[] charms;
		this.set("playercharms", charms);
	}

	PlayerCharm p;
	p.name = name;
	p.iconName = iconName;
	p.configFilename = configFilename;
	p.description = description;
	p.slots = slots;
	this.push("playercharms", p);
}

//helper for building menus of classes

void addCharmsToMenu(CBlob@ this, CGridMenu@ menu, uint16 callerID)
{
	printf("hm");
	PlayerCharm[]@ charms;

	if (this.get("playercharms", @charms))
	{
		for (uint i = 0 ; i < charms.length; i++)
		{
			PlayerCharm @pcharm = charms[i];

			uint16 testd = callerID;

			CPlayer@ callerplayer = getBlobByNetworkID(testd).getPlayer();

			CBitStream params;
			params.write_u16(callerID);
			params.write_string(pcharm.configFilename);
			params.write_u8(pcharm.slots);

			CRules@ rules = getRules();

			string charm_user = pcharm.configFilename + "_" + callerplayer.getUsername();
			string charm_user_slots = "charmslots_" + callerplayer.getUsername();

			printf("existence is pain. do we even get here?: " + charm_user + " " + charm_user_slots);

			CGridButton@ button = menu.AddButton(pcharm.iconName, pcharm.name, SpawnCmd::selectCharm, Vec2f(CHARM_BUTTON_SIZE, CHARM_BUTTON_SIZE), params);

			if (button !is null)
			{
				if(rules.get_bool(charm_user) == true)
				{
					button.SetSelected(1);
					printf("Bruh?");
				}
				else if(rules.get_bool(charm_user) == false && pcharm.slots > rules.get_u8(charm_user_slots))
				{
					button.SetEnabled(false);
					printf("bruh!");
				}
			}

			button.SetHoverText( "\n" + pcharm.description + "\n" );
			printf("homek god " + i);
		}
	}
}

PlayerCharm@ getDefaultCharm(CBlob@ this)
{
	PlayerCharm[]@ charms;

	if (this.get("playercharms", @charms))
	{
		return charms[0];
	}
	else
	{
		return null;
	}
}
