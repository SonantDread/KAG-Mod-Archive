// REQUIRES:
//
//      onRespawnCommand() to be called in onCommand()
//
//  implementation of:
//
//      bool canChangeClass( CBlob@ this, CBlob @caller )
//
// Tag: "change class sack inventory" - if you want players to have previous items stored in sack on class change
// Tag: "change class store inventory" - if you want players to store previous items in this respawn blob

#include "ClassSelectMenu.as"


void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 2.0f + caller.getRadius());
}

bool canChangeClass(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}

// default classes
void InitClasses(CBlob@ this)
{
	AddIconToken("$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$Polearm_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 15);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Polearm", "$Polearm_class_icon$", "Polearm", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), "Swap class");
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
	}
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	switch (cmd)
	{
		case SpawnCmd::buildMenu:
		{
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller);
			}
		}
		break;

		case SpawnCmd::changeClass:
		{
			if (getNet().isServer())
			{
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());

				if (caller !is null && canChangeClass(this, caller))
				{
				if (caller.getName() == "onestarpolearm" && caller.getTeamNum() == 0)
				{
					CBlob@ onestarpolearmuniform = server_CreateBlob("onestarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarpolearm" && caller.getTeamNum() == 1)
				{
					CBlob@ onestarpolearmuniform = server_CreateBlob("onestarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarpolearm2"  && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarpolearm2"  && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarpolearm" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarpolearm" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarpolearm2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarpolearm2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarpolearm" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarpolearm" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarpolearm2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarpolearmuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarpolearm2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarpolearmuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarknight" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarknight" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarknight2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarknight2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarknight" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarknight" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarknight2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarknight2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarknight" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarknight" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarknight2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarknightuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarknight2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarknightuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestararcher" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestararcher" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestararcher2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestararcher2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostararcher" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostararcher" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostararcher2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostararcher2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestararcher" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestararcher" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestararcher2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestararcheruniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestararcher2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestararcheruniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarbuilder" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarbuilderuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarbuilder" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarbuilder2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "onestarbuilder2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("onestarbuilderuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarbuilder" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarbuilderuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarbuilder" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarbuilder2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "twostarbuilder2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("twostarbuilderuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarbuilder" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarbuilderuniform", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarbuilder" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarbuilder2" && caller.getTeamNum() == 1)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarbuilderuniform2", -1, this.getPosition());
				}
				else if (caller.getName() == "threestarbuilder2" && caller.getTeamNum() == 0)
				{
				CBlob@ onestarpolearmuniform = server_CreateBlob("threestarbuilderuniform", -1, this.getPosition());
				}
					
					string classconfig = params.read_string();
					CBlob @newBlob = server_CreateBlob(classconfig, caller.getTeamNum(), this.getRespawnPosition());

					if (newBlob !is null)
					{
						// copy health and inventory
						// make sack
						CInventory @inv = caller.getInventory();
						if (inv !is null)
						{
							if (this.hasTag("change class drop inventory"))
							{
								while (inv.getItemsCount() > 0)
								{
									CBlob @item = inv.getItem(0);
									caller.server_PutOutInventory(item);
								}
							}
							else if (this.hasTag("change class store inventory"))
							{
								if (this.getInventory() !is null)
								{
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

						// set health to be same ratio
						float healthratio = caller.getHealth() / caller.getInitialHealth();
						newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

						//copy air
						if (caller.exists("air_count"))
						{
							newBlob.set_u8("air_count", caller.get_u8("air_count"));
							newBlob.Sync("air_count", true);
						}

						//copy stun
						if (caller.exists("knocked"))
						{
							newBlob.set_u8("knocked", caller.get_u8("knocked"));
							newBlob.Sync("knocked", true);
						}

						// plug the soul
						newBlob.server_SetPlayer(caller.getPlayer());
						newBlob.setPosition(caller.getPosition());

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
				}
			}
		}
		break;
	}

	//params.SetBitIndex( index );
}

void PutInvInStorage(CBlob@ blob)
{
	CBlob@[] storages;
	if (getBlobsByTag("storage", @storages))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{
				blob.MoveInventoryTo(storage);
				return;
			}
		}
}
