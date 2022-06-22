#include "Hitters.as";
//changed by blav
void onInit(CBlob@ this)
{
	this.Tag("ignore fall");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}
}

void onTick(CBlob@ this)
{	
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;
		
		if (point.isKeyJustPressed(key_action1))
		{
			u8 team = holder.getTeamNum();
			
			HitInfo@[] hitInfos;
			if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
			{
				for (uint i = 0; i < hitInfos.length; i++)
				{
					CBlob@ blob = hitInfos[i].blob;
					if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != team)
					{
						if (getNet().isServer())
						{
							CBlob@ slave = server_CreateBlob("slave", -1, blob.getPosition());
							if (slave !is null)
							{
								if (blob.getPlayer() !is null) slave.server_SetPlayer(blob.getPlayer());
								blob.server_Die();
								this.server_Die();
							}
						}
						return;
					}
				}
			}
			
			if (holder.isMyPlayer()) Sound::Play("/NoAmmo");
		}
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	// detached.Untag("noShielding");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	// attached.Tag("noShielding");
}