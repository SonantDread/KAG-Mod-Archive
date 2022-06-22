#include "Explosion.as";
#include "LimbsCommon.as";

void onInit( CBlob@ this )
{
	this.addCommandID("transform");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("transform"), "Start the parade of darkness", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("transform"))
	{
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			int bodies = 0;
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b.getHealth() <= 0.0f && isFlesh(b.get_u8("tors_type")))
					{
						bodies += 1;
						b.server_Die();
					}
				}
			}
			if(bodies > 0 || caller.get_s16("darkness") >= 10){
				CBlob @newBlob = server_CreateBlob("dark_being", 9, caller.getPosition());
				if (newBlob !is null)
				{
					// plug the soul
					newBlob.server_SetPlayer(caller.getPlayer());
					
					newBlob.set_s16("darkness",caller.get_s16("darkness")+bodies*100);
					
					this.getSprite().PlaySound("DarkBeingSummon.ogg", 2.0f, 0.70f);

					caller.Tag("switch class");
					caller.server_SetPlayer(null);
					caller.server_Die();
					this.server_Die();
				}
			}
		}
		
	}
}
