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
#include "EquipmentCommon.as"

void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
}

bool canChangeClass(CBlob@ this, CBlob@ blob)
{
    if(blob.hasTag("switch class")) return false;

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
				// build menu for them
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				BuildRespawnMenuFor(this, caller);
				this.set_bool("quick switch class", false);
			}
		}
		break;

		case SpawnCmd::changeClass:
		{
			
			// build menu for them
			CBlob@ caller = getBlobByNetworkID(params.read_u16());

			if (caller !is null && canChangeClass(this, caller))
			{
				string classconfig = params.read_string();
				
				if(classconfig == "builder"){
					if(caller.getTeamNum() > 8)equipType(caller, EquipSlot::Main, Equipment::Hammer, 0);
					else equipType(caller, EquipSlot::Main, Equipment::Hammer, 2);
					equipType(caller, EquipSlot::Sub, Equipment::Pick, 0);
					equipType(caller, EquipSlot::Torso, Equipment::Shirt, 0);
				}
				
				if(classconfig == "knight"){
					equipType(caller, EquipSlot::Main, Equipment::Sword, 0);
					equipType(caller, EquipSlot::Sub, Equipment::Shield, 0);
					equipType(caller, EquipSlot::Torso, Equipment::KnightArmour, 0);
				}
				
				if(classconfig == "archer"){
					equipType(caller, EquipSlot::Main, Equipment::Bow, 0);
					equipType(caller, EquipSlot::Sub, Equipment::Grapple, 0);
					equipType(caller, EquipSlot::Torso, Equipment::Shirt, 0);
					
					if (getNet().isServer())
					if(!caller.hasBlob("mat_arrows", 1)){
						caller.server_PutInInventory(server_CreateBlob("mat_arrows",-1,this.getPosition()));
					}
				}
				caller.set_string("class",classconfig);
				
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
