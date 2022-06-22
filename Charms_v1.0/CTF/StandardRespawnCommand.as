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
#include "CharmCommon.as"
#include "KnockedCommon.as"

void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
}

bool canChangeClass(CBlob@ this, CBlob@ blob)
{
    if (blob.hasTag("switch class")) return false;

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
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), getTranslatedString("Swap class"));
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
	}
}

void BuildCharmMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerCharm[]@ charms;

	CPlayer@ player = caller.getPlayer();

	if(player is null)
		return;

	CRules@ rules = getRules();

	string charm_user_slots = "charmslots_" + player.getUsername();

	if(!this.exists("playercharms"))
	{
		InitCharms(this);
	}

	if(player !is null && !rules.exists(charm_user_slots))
	{
		rules.set_u8(charm_user_slots, 10);
	}

	this.get("playercharms", @charms);

	if (caller !is null && caller.isMyPlayer() && charms !is null && player !is null && rules.exists(charm_user_slots))
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(5 * CHARM_BUTTON_SIZE, 5 * CHARM_BUTTON_SIZE), "Switch Charms. Current slot amount: " + rules.get_u8(charm_user_slots));
		if (menu !is null)
		{
			addCharmsToMenu(this, menu, caller.getNetworkID());
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
				this.set_bool("quick switch class", false);
			}
		}
		break;

		case SpawnCmd::changeClass:
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());

			if(caller !is null)
			{
				CParticle@[] particles;

				if (caller.get("particles", particles))
				{
					for (int i = 0; i < particles.length(); i++)
					{
						particles[i].timeout = 0;
					}
					caller.set("particles", null);
				}
			}

			if (getNet().isServer())
			{
				// build menu for them
				//CBlob@ caller = getBlobByNetworkID(params.read_u16());

				if (caller !is null && canChangeClass(this, caller))
				{
					if(caller.getPlayer() is null)
						return;

					string classconfig = params.read_string();

					if((classconfig == "knight" || classconfig == "builder" || classconfig == "archer") && getRules().get_bool("heartcharm_" + caller.getPlayer().getUsername()))
					{
						classconfig = classconfig + "2";
					}

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
						if (isKnockable(caller))
						{
							setKnocked(newBlob, getKnockedRemaining(caller));
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
						CParticle@[] particles;
	
						caller.Tag("switch class");
						caller.server_SetPlayer(null);
						caller.server_Die();
					}
				}
			}
		}
		break;

		case SpawnCmd::changeCharm:
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			BuildCharmMenuFor(this, caller);
		}
		break;

		case SpawnCmd::selectCharm:
		{
			u16 netid = params.read_u16();
			CBlob@ caller = getBlobByNetworkID(netid);

			if (isServer())
			{
				CPlayer@ player = caller.getPlayer();

				CRules@ rules = getRules();

				if (player is null) return;

				if (caller !is null && canChangeClass(this, caller))
				{
					if (!rules.exists("playercharms_" + player.getUsername()))
					{
						PlayerCharm[] charms;
						rules.set("playercharms_" + player.getUsername(), charms);
						//player.Sync("playercharms_" + player.getUsername(), true);
					}

					string charm = params.read_string();
					uint8 cost = params.read_u8();

					PlayerCharm[]@ charms;

					string charm_user = charm + "_" + player.getUsername();
					string charm_user_slots = "charmslots_" + player.getUsername();

					if(rules.get_bool(charm_user) == false && rules.get_u8(charm_user_slots) >= cost)
					{
						rules.set_bool(charm_user, true);
						rules.sub_u8(charm_user_slots, cost);

						if (rules.get("playercharms_" + player.getUsername(), @charms))
						{
							PlayerCharm@ current = getCharmByName(charm);
							if(current !is null)
							{
								charms.push_back(current);
							}

							CBitStream bparams;

							bparams.write_bool(true);
							bparams.write_u16(caller.getNetworkID());
							bparams.write_string(charm);

							this.SendCommand(SpawnCmd::syncCharms, bparams);
						}

						PlayerCharm@ iteratorcharm = getCharmByName(charm);

						if(iteratorcharm !is null && iteratorcharm.active && charm != "dashcharm")
						{
							rules.add_u8("iterator_" + player.getUsername(), 1);
							rules.Sync("iterator_" + player.getUsername(), true);

							string keystring = "KEY_KEY_" + rules.get_u8("iterator_" + player.getUsername());

							rules.set_string("key_" + charm + "_" + player.getUsername(), keystring);
							rules.Sync("key_" + charm + "_" + player.getUsername(), true);
						}
						if(iteratorcharm !is null && charm == "dashcharm")
						{
							string keystring = "KEY_KEY_S";

							rules.set_string("key_" + charm + "_" + player.getUsername(), keystring);
							rules.Sync("key_" + charm + "_" + player.getUsername(), true);
						}
						if(charm == "heartcharm")
						{
							CBitStream paramsf;
							write_classchange(paramsf, caller.getNetworkID(), player.getBlob().getName() + "2");
							this.SendCommand(SpawnCmd::changeClass, paramsf);
						}
					}
					else if(rules.get_bool(charm_user) == true)
					{
						rules.set_bool(charm_user, false);
						rules.add_u8(charm_user_slots, cost);

						if (rules.get("playercharms_" + player.getUsername(), @charms))
						{
							for (uint i = 0 ; i < charms.length; i++)
							{
								PlayerCharm @pcharm = charms[i];

								if (pcharm.configFilename == charm)
								{
									charms.erase(i);
									i--;
								}
							}

							CBitStream bparams;

							bparams.write_bool(false);
							bparams.write_u16(caller.getNetworkID());
							bparams.write_string(charm);

							this.SendCommand(SpawnCmd::syncCharms, bparams);
						}

						PlayerCharm@ iteratorcharm = getCharmByName(charm);

						if(iteratorcharm !is null && iteratorcharm.active && charm != "dashcharm")
						{
							rules.sub_u8("iterator_" + player.getUsername(), 1);
							rules.Sync("iterator_" + player.getUsername(), true);

							rules.set_string("key_" + charm + "_" + player.getUsername(), "NOKEY");
							rules.Sync("key_" + charm + "_" + player.getUsername(), true);

							uint it = 1;

							for(uint i = 0; i < charms.length; i++)
							{
								PlayerCharm @pcharm = charms[i];

								if (pcharm.active && pcharm.configFilename != "dashcharm")
								{
									string keystring = "KEY_KEY_" + it;

									rules.set_string("key_" + pcharm.configFilename + "_" + player.getUsername(), keystring);
									rules.Sync("key_" + pcharm.configFilename + "_" + player.getUsername(), true);
									++it;
								}

							}
						}

						if(charm == "heartcharm" && (player.getBlob().getName() == "knight2" || player.getBlob().getName() == "archer2" || player.getBlob().getName() == "builder2"))
						{
							CBitStream paramsf;
							string haha = player.getBlob().getName();
							haha.resize(haha.size() - 1);

							write_classchange(paramsf, caller.getNetworkID(), haha);
							this.SendCommand(SpawnCmd::changeClass, paramsf);
						}

					}

					else if (rules.get_u8(charm_user_slots) < cost)
					{
						caller.getSprite().PlaySound("NoAmmo.ogg", 0.5);
					}

					rules.Sync(charm_user, true);
					rules.Sync(charm_user_slots, true);
				}
			}
			if(isClient())
			{
				BuildCharmMenuFor(this, caller);
			}
		}

		break;

		case SpawnCmd::syncCharms:
		{
			if(isClient())
			{
				bool addorno = params.read_bool();

				CBlob@ caller = getBlobByNetworkID(params.read_u16());

				CPlayer@ player = caller.getPlayer();

				if(!player.isMyPlayer()) return;

				CRules@ rules = getRules();

				if (!rules.exists("playercharms_" + player.getUsername()))
				{
					PlayerCharm[]@ charms;
					rules.set("playercharms_" + player.getUsername(), @charms);
					//player.Sync("playercharms_" + player.getUsername(), true);
				}

				PlayerCharm[]@ charms;

				string s = params.read_string();

				if (rules.get("playercharms_" + player.getUsername(), @charms) && addorno)
				{
					PlayerCharm@ charm = getCharmByName(s);

					for (uint i = 0 ; i < charms.length; i++)
					{
						if (charms[i].configFilename == s)
						{
							charms.erase(i);
							i--;
						}
					}

					charms.push_back(charm);
				}
				else if (rules.get("playercharms_" + player.getUsername(), @charms) && !addorno)
				{
					for (uint i = 0 ; i < charms.length; i++)
					{
						if (charms[i].configFilename == s)
						{
							charms.erase(i);
							i--;
						}
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

const bool enable_quickswap = false;
void CycleClass(CBlob@ this, CBlob@ blob)
{
	//get available classes
	PlayerClass[]@ classes;
	if (this.get("playerclasses", @classes))
	{
		CBitStream params;
		PlayerClass @newclass;

		//find current class
		for (uint i = 0; i < classes.length; i++)
		{
			PlayerClass @pclass = classes[i];
			if (pclass.name.toLower() == blob.getName())
			{
				//cycle to next class
				@newclass = classes[(i + 1) % classes.length];
				break;
			}
		}

		if (newclass is null)
		{
			//select default class
			@newclass = getDefaultClass(this);
		}

		//switch to class
		write_classchange(params, blob.getNetworkID(), newclass.configFilename);
		this.SendCommand(SpawnCmd::changeClass, params);
	}
}