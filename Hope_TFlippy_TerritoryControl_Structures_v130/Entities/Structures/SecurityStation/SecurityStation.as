#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";

// A script by TFlippy

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getSprite().SetZ(-10.0f);
	this.set_u32("security_link_id", u32(this.getNetworkID()));

	if (isServer())
	{
		CBlob@ card = server_CreateBlobNoInit("securitycard");
		card.setPosition(this.getPosition());
		card.set_u32("security_link_id", this.get_u32("security_link_id"));
		card.server_setTeamNum(this.getTeamNum());
		card.Tag("security_linkable");
		card.Init();
		printf("" + card.get_u32("security_link_id"));
	}

	this.setInventoryName("Security Station #" + this.get_u32("security_link_id"));
	this.addCommandID("copy_card");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller !is null && caller.isOverlapping(this))
	{
		CBlob@[] blobs;
		getBlobsByTag("security_linkable", @blobs);

		CBlob@ card = caller.getCarriedBlob();

		if (card !is null)
		{
			if (card.getName() == "securitycard" && card.get_u32("security_link_id") == this.get_u32("security_link_id"))
			{
				u32 link = this.get_u32("security_link_id");
				for (int i = 0; i < blobs.length; i++)
				{
					CBlob@ blob = blobs[i];
					if (blob !is null)
					{
						// Vec2f deltaPos = (blob.getPosition() - this.getPosition()) * 0.50f;
						u32 blob_link = blob.get_u32("security_link_id");

						CBitStream params;
						params.write_bool(!blob.get_bool("security_state"));

						blob.addCommandID("security_set_state");
						CButton@ button = caller.CreateGenericButton(11, Vec2f(0, -8), blob, blob.getCommandID("security_set_state"), "Toggle", params);
						button.enableRadius = 512;
						button.SetEnabled((blob_link == link || blob_link == 0) && blob.getTeamNum() != 250);
					}
				}
			}
			if (card.isAttachedTo(caller))
			{
				CBitStream params;
				params.write_u32(card.get_u32("security_link_id"));
				params.write_u16(caller.getNetworkID());
				CButton@ button = caller.CreateGenericButton(11, Vec2f(0, -8), this, this.getCommandID("copy_card"), "Copy card", params);
			}	
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("copy_card"))
	{
		u32 id = params.read_u32();

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ card = server_CreateBlobNoInit("securitycard");

		if (caller !is null && isServer())
		{
			printf("yes");
			card.setPosition(this.getPosition());
			card.server_setTeamNum(this.getTeamNum());
			card.set_u32("security_link_id", id);
			card.Init();
			caller.getPlayer().server_setCoins(caller.getPlayer().getCoins() - 200);
		}
	}
}