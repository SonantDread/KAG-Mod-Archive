#include "Hitters.as";
#include "RespawnCommandCommon.as";
#include "StandardRespawnCommand.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("necro");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("necro"), "Use this to change into a necromancer.", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("necro"))
	{
		ParticleZombieLightning(this.getPosition());

		bool hit = false;
		u16 caller_id = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(caller_id);
		
		if (caller !is null)
		{
	        if (getNet().isServer())
	        {
                string classconfig = "necromancer";//params.read_string();
                CBlob @newBlob = server_CreateBlobNoInit(classconfig);//, caller.getTeamNum(), this.getRespawnPosition());

                if (newBlob !is null)
                {
                    // copy health and inventory
                    // make sack
                    CInventory @inv = caller.getInventory();

                    if (inv !is null)
                    {
						if (this.hasTag("change class drop inventory"))
						{
							while(inv.getItemsCount() > 0)
                            {
                                CBlob @item = inv.getItem(0);
                                caller.server_PutOutInventory(item);
							}
						}
						else if (this.hasTag("change class store inventory"))
						{		
							if (this.getInventory() !is null) {
								caller.MoveInventoryTo(this);
							}
							else // find a storage
							{	   
								PutInvInStorage(caller);
							}
						}
						else
                        {
                            // keep inventory if possible
                            caller.MoveInventoryTo(newBlob);
                        }
                    }

                    if (caller.getHealth() != caller.getInitialHealth()) //only if was damaged, else just set max hearts //fix contributed by norill 19 aug 13
						newBlob.server_SetHealth(Maths::Min(caller.getHealth(), newBlob.getInitialHealth())); //set old hearts, capped by new initial hearts
					
					newBlob.Init();

                    // plug the soul
                    newBlob.server_SetPlayer(caller.getPlayer());
                    newBlob.setPosition(caller.getPosition());
					newBlob.server_setTeamNum(caller.getTeamNum());
					newBlob.Tag("player");
					newBlob.Tag("flesh");
                    // no extra immunity after class change
                    if (caller.exists("spawn immunity time"))
                    {
                        newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
                        newBlob.Sync("spawn immunity time", true);
                    }

                    caller.Tag("switch class");
                    caller.server_SetPlayer(null);
                    caller.server_Die();
                }
				this.server_Die();
        	}
		}
	}
}