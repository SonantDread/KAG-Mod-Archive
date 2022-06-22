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

#include "ClassSelectMenu.as";
#include "SwapClass.as";

void InitRespawnCommand(CBlob@ this)
{
	this.addCommandID("class menu");
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
	AddIconToken("$builder_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$knight_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$archer_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$sapper_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$ghoul_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$waterman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$crossbow_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 5);
	AddIconToken("$necro_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$runemaster_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$paladin_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$priest_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),10);
	AddIconToken("$samurai_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),11);
	AddIconToken("$ninja_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),16);
	AddIconToken("$mindman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),12);
	AddIconToken("$shadowman_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),13);
	AddIconToken("$runescribe_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),14);
	AddIconToken("$brainswitch_class_icon$", "ClassSwitchIcons.png", Vec2f(32, 32),15);
	
	AddIconToken("$change_class$", "GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	
	
	addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Build ALL the towers.");
	addPlayerClass(this, "Rune Master", "$runemaster_class_icon$", "runemaster", "Rune carver.");
	addPlayerClass(this, "Sapper", "$sapper_class_icon$", "sapper", "Destroy the world.");
	
	addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	addPlayerClass(this, "Samurai", "$samurai_class_icon$", "samurai", "Ninja's worst enemy.");
	addPlayerClass(this, "Ninja", "$ninja_class_icon$", "ninja", "Samurai's worst enemy.");
	
	addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");
	addPlayerClass(this, "Crossbowman", "$crossbow_class_icon$", "crossbow", "The Ranged Advantage.");
	
	addPlayerClass(this, "Elementalist", "$waterman_class_icon$", "waterman", "Burning water.");
	addPlayerClass(this, "Gravity Charmer", "$mindman_class_icon$", "mindman", "The hover and float.");
	addPlayerClass(this, "Mind Writer", "$brainswitch_class_icon$", "brainswitcher", "Body Switching!");
	addPlayerClass(this, "Rune Scribe", "$runescribe_class_icon$", "runescribe", "The write and spell.");
	
	addPlayerClass(this, "Priest", "$priest_class_icon$", "priest", "Holy smiter.");
	addPlayerClass(this, "Paladin", "$paladin_class_icon$", "paladin", "Holy crusher.");

	addPlayerClass(this, "Ghoul", "$ghoul_class_icon$", "ghoul", "Devour and consume.");
	addPlayerClass(this, "Boring Necromancer", "$necro_class_icon$", "necro", "The summon and splode.");
	addPlayerClass(this, "Shadow Master", "$shadowman_class_icon$", "shadowman", "The phase and stab.");

	
	//addPlayerClass(this, "Test", "$builder_class_icon$", "zombie", "testing.");
}

void buildSpawnMenu(CBlob@ this, CBlob@ caller)
{
	BuildRespawnMenuFor(this, @caller);
}

void BuildRespawnMenuFor(CBlob@ this, CBlob @caller)
{
	PlayerClass[]@ classes;
	this.get("playerclasses", @classes);

	int Width = 4;
	int Height = 4;
	
	if (caller !is null && caller.isMyPlayer() && classes !is null)
	{
		//CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(CLASS_BUTTON_SIZE * Width, CLASS_BUTTON_SIZE * Height), "Swap class");
		//if (menu !is null)
		//{
		//	addClassesToMenu(this, menu, caller.getNetworkID());
		//}
		
		int Y = 48-380;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 3, CLASS_BUTTON_SIZE * 1), "Builders");
			if (menu !is null)
			{
				addClassesToMenuBuilder(this, menu, caller.getNetworkID());
			}
		}
		
		Y += 24*5;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 3, CLASS_BUTTON_SIZE * 1), "Melee");
			if (menu !is null)
			{
				addClassesToMenuMelee(this, menu, caller.getNetworkID());
			}
		}
		
		Y += 24*5;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 2, CLASS_BUTTON_SIZE * 1), "Range");
			if (menu !is null)
			{
				addClassesToMenuRange(this, menu, caller.getNetworkID());
			}
		}
		
		Y += 24*5;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 4, CLASS_BUTTON_SIZE * 1), "Casters");
			if (menu !is null)
			{
				addClassesToMenuCaster(this, menu, caller.getNetworkID());
			}
		}
		
		Y += 24*5;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 2, CLASS_BUTTON_SIZE * 1), "Holy");
			if (menu !is null)
			{
				addClassesToMenuHoly(this, menu, caller.getNetworkID());
			}
		}
		
		Y += 24*5;
		
		{
			CGridMenu@ menu = CreateGridMenu(caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + Y), this, Vec2f(CLASS_BUTTON_SIZE * 3, CLASS_BUTTON_SIZE * 1), "Evil");
			if (menu !is null)
			{
				addClassesToMenuEvil(this, menu, caller.getNetworkID());
			}
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
					string classconfig = params.read_string();
					if(getRules().isWarmup() && caller.getPlayer().getUsername() != "Pirate-Rob")classconfig = "builder";
					
					swapClass(caller,classconfig);
					
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
