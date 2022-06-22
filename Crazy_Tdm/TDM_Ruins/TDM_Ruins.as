// TDM Ruins logic
// added new classes.
#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "RespawnCommandCommon.as"
#include "GenericButtonCommon.as"
#include "ClassesConfig.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$rockthrower_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$medic_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$spearman_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$assassin_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$crossbowman_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$musketman_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 5);
	AddIconToken("$butcher_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$duelist_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 11);
	AddIconToken("$weaponthrower_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 12);
	AddIconToken("$firelancer_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 13);
	AddIconToken("$gunner_class_icon$", "GUI/LWBClassIcons.png", Vec2f(32, 32), 14);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$ninja_class_icon$", "Crazy_Tdm/ninja_class_icon.png", Vec2f(32, 32), 0);


	//TDM classes
	if(ClassesConfig::rockthrower) addPlayerClass(this, "Rock Thrower", "$rockthrower_class_icon$", "rockthrower", "Basic Tactics.");
	if(ClassesConfig::medic) addPlayerClass(this, "Medic", "$medic_class_icon$", "medic", "Medicine and Chemical.");
	if(ClassesConfig::butcher) addPlayerClass(this, "Butcher", "$butcher_class_icon$", "butcher", "Human Resources.");
	if(ClassesConfig::knight) addPlayerClass(this, "Knight", "$knight_class_icon$", "knight", "Hack and Slash.");
	if(ClassesConfig::spearman) addPlayerClass(this, "Spearman", "$spearman_class_icon$", "spearman", "Omnipotent Weapon.");
	if(ClassesConfig::assassin) addPlayerClass(this, "Assassin", "$assassin_class_icon$", "assassin", "Nothing can Escape.");
	if(ClassesConfig::duelist) addPlayerClass(this, "Duelist", "$duelist_class_icon$", "duelist", "Dodge and Pick.");
	if(ClassesConfig::archer) addPlayerClass(this, "Archer", "$archer_class_icon$", "archer", "The Ranged Advantage.");	if(ClassesConfig::musketman) addPlayerClass(this, "Musketman", "$musketman_class_icon$", "musketman", "New Era of War.");
	if(ClassesConfig::weaponthrower) addPlayerClass(this, "Weapon Thrower", "$weaponthrower_class_icon$", "weaponthrower", "Skill of Human.");
	if(ClassesConfig::firelancer) addPlayerClass(this, "Fire Lancer", "$firelancer_class_icon$", "firelancer", "Chinese shotgun.");
	if(ClassesConfig::builder) addPlayerClass(this, "Builder", "$builder_class_icon$", "builder", "Can Build And Break");
	if(ClassesConfig::crusher) addPlayerClass(this, "Crusher", "$knight_class_icon$", "crusher", "Boulder Rain!");


	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");
	this.Tag("all_classes_loaded");

	this.Tag("change class drop inventory");

	this.getSprite().SetZ(-50.0f);   // push to background
}

void onTick(CBlob@ this)
{
	if (enable_quickswap)
	{
		//quick switch class
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null && blob.isMyPlayer())
		{
			if (
				isInRadius(this, blob) && //blob close enough to ruins
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 7) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("class menu"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null && caller.isMyPlayer())
		{
			BuildRespawnMenuFor(this, caller);
		}
	}
	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller))
	{
		if (isInRadius(this, caller))
		{
			BuildRespawnMenuFor(this, caller);
		}
		else
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			caller.CreateGenericButton("$change_class$", Vec2f(0, 6), this, this.getCommandID("class menu"), getTranslatedString("Change class"), params);
		}
	}

	// warning: if we don't have this button just spawn menu here we run into that infinite menus game freeze bug
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return (this.getPosition() - caller.getPosition()).Length() < this.getRadius();
}
