#include "MakeMat.as";
#include "Requirements.as";

const u16 max_loop = 150; // what you get for breaking it

void onInit(CSprite@ this)
{
	this.SetZ(-50);
}

void onInit(CBlob@ this)
{
	this.Tag("remote_storage");

	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 90;

	this.inventoryButtonPos = Vec2f(0, 0);
	this.set_bool("reversed", false);
	this.addCommandID("reverse");
	this.Tag("builder always hit");

	this.set_string("fetcher_resource", "");
	this.set_string("fetcher_resource_name", "");

	this.addCommandID("fetcher_set");

	client_UpdateName(this);
}

void client_UpdateName(CBlob@ this)
{
	if (isClient())
	{
		this.setInventoryName("Fetcher\n" + this.get_string("fetcher_resource_name"));
	}
}

void onTick(CBlob@ this)
{
	string resource_name = this.get_string("fetcher_resource");
	if (!this.getInventory().isFull() && resource_name != "")
	{
		u8 my_team = this.getTeamNum();

		CBlob@[] blobs;
		if (getMap().getBlobsInRadius(this.getPosition(), 64, @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				if (b is null) continue;
				if (b.hasTag("player")) continue;
				if (b.getConfig() == "fetcher") continue;

				u8 team = b.getTeamNum();

				if(b.getInventory() !is null && (team == my_team || team >= 100))
				{
					if (!b.isInventoryAccessible(this) || b.hasTag("ignore extractor")) continue;

					CBlob@ item = b.getInventory().getItem(resource_name);
					if (item !is null)
					{
						if (this.get_bool("reversed"))
						{
							item.server_Die();
						}
						else
						{
							if (isServer()) this.server_PutInInventory(item);
							if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
						}

						return;
					}
				}
				else if (b.getConfig() == resource_name && !b.isAttached() && !b.getShape().isStatic())
				{
					if (this.get_bool("reversed"))
					{
						b.server_Die();
					}
					else
					{
						if (isServer()) this.server_PutInInventory(b);
						if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
					}

					return;
				}

			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	u16 carried_netid;

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null) carried_netid = carried.getNetworkID();

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	params.write_u16(carried_netid);

	CButton@ button_withdraw = caller.CreateGenericButton(11, Vec2f(0, -8), this, this.getCommandID("fetcher_set"), "Set Resource", params);
	if (button_withdraw !is null)
	{
		button_withdraw.SetEnabled(carried !is null);
	}
	if (this !is null)
	{
		CButton@ button = caller.CreateGenericButton(17, Vec2f(0, 8.0f), this, this.getCommandID("reverse"), "Reverse logic filter \nTo make fetcher destroy absorbed items \n Radius: 6 blocks from edges \nAlready reversed: " + this.get_bool("reversed"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("fetcher_set"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ carried = getBlobByNetworkID(params.read_u16());

		if (caller !is null && carried !is null)
		{
			this.set_string("fetcher_resource", carried.getConfig());
			this.set_string("fetcher_resource_name", carried.getInventoryName());

			client_UpdateName(this);
		}
	}
	else if (cmd == this.getCommandID("reverse"))
	{
		if (this !is null)
		{
			if (!this.get_bool("reversed"))
				this.set_bool("reversed", true);
			else
				this.set_bool("reversed", false);
			printf("" + this.get_bool("reversed"));
		}
	}
}
