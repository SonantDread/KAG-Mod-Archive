#include "ClassSelectMenu.as"
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
	AddIconToken("$crewman_class_icon$", "ClassIcon.png", Vec2f(48, 48), 1);
	AddIconToken("$ranger_class_icon$", "ClassIcon.png", Vec2f(48, 48), 2);
	AddIconToken("$shotgun_class_icon$", "ClassIcon.png", Vec2f(48, 48), 3);
	AddIconToken("$sniper_class_icon$", "ClassIcon.png", Vec2f(48, 48), 4);
	AddIconToken("$antitank_class_icon$", "ClassIcon.png", Vec2f(48, 48), 5);
	AddIconToken("$medic_class_icon$", "ClassIcon.png", Vec2f(48, 48), 6);
	AddIconToken("$lmg_class_icon$", "ClassIcon.png", Vec2f(48, 48), 7);
	//AddIconToken("$paratrooper_class_icon$", "Class.png", Vec2f(32, 32), 28);
	AddIconToken("$mechanic_class_icon$", "ClassIcon.png", Vec2f(48, 48), 0);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	addPlayerClass(this, "---- Mechanic ----", "$mechanic_class_icon$", "mechanic", "---- Mechanic ----\n\nBuild and break.\nLMB: Build\nRMB: Mine");
	addPlayerClass(this, "---- Crewman ----", "$crewman_class_icon$", "crewman", "---- Crewman ----\n\nTough and quick.\nLMB: Pistol\nRMB: Knife");
	addPlayerClass(this, "---- Ranger ----", "$ranger_class_icon$", "ranger", "---- Ranger ----\n\nHigh rate of fire.\nLMB: AK47\nRMB: Buttstroke");
	addPlayerClass(this, "---- Shotgun ----", "$shotgun_class_icon$", "shotgun", "---- Shotgunner ----\n\nDeadly at close range.\nLMB: Shotgun\nRMB: Knife");
	addPlayerClass(this, "---- Sniper ----", "$sniper_class_icon$", "sniper", "---- Sniper ----\n\nLong range sniper.\nLMB: Rifle\nRMB: Knife");
	addPlayerClass(this, "---- Anti-Tank ----", "$antitank_class_icon$", "antitank", "---- Anti-Tank ----\n\nEliminate tanks onfoot.\nLMB: RPG\nRMB: Knife");
	addPlayerClass(this, "---- Medic ----", "$medic_class_icon$", "medic", "---- Medic ----\n\nHeal nearby teammates.\nLMB: MP5\nRMB: Knife");
	addPlayerClass(this, "---- LMG ----", "$lmg_class_icon$", "lmg", "---- LMG ----\n\nExtreme firepower.\nLMB: LMG\nRMB: ADS");
	//addPlayerClass(this, "---- Paratrooper ----", "$paratrooper_class_icon$", "paratrooper", "---- Paratrooper ----\n\nUse a parachute.\nLMB: Ak47\nRMB: Knife");
	
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE, CLASS_BUTTON_SIZE), getTranslatedString("CHANGE CLASS"));
		if (menu !is null)
		{
			addClassesToMenu(this, menu, caller.getNetworkID());
		}
	}
}

void buildSpawnMenu(CBlob@ this, CBlob@ caller)
{
	BuildRespawnMenuFor(this, caller);
}

void onRespawnCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	switch (cmd)
	{
		case SpawnCmd::buildMenu: 
		{
			{
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller);
			}
		}
		break;

		case SpawnCmd::lockedClass: 
		{
			{
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				if (caller.isMyPlayer())
				{
					this.getSprite().PlaySound("/NoAmmo", 0.5);
				}
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

						caller.Tag("switch class");
						caller.server_SetPlayer(null);
						caller.server_Die();
					}
				}
			}
		}
		break;
	}
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
