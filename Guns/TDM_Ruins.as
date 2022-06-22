// TDM Ruins logic

#include "ClassSelectMenu.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "RespawnCommandCommon.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.CreateRespawnPoint("ruins", Vec2f(0.0f, 16.0f));
	AddIconToken("$crewman_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 8);
	AddIconToken("$ranger_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 12);
	AddIconToken("$sniper_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 24);
	AddIconToken("$antitank_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 16);
	AddIconToken("$mechanic_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 20);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	//TDM classes
	addPlayerClass(this, "Crewman", "$crewman_class_icon$", "crewman", "Crewman for a vehicle.");
	addPlayerClass(this, "Ranger", "$ranger_class_icon$", "ranger", "Uses an Ak47.");
	addPlayerClass(this, "Sniper", "$sniper_class_icon$", "sniper", "Uses a long range sniper.");
	addPlayerClass(this, "Anti-Tank", "$antitank_class_icon$", "antitank", "Uses an RPG-7.");
	addPlayerClass(this, "Mechanic", "$mechanic_class_icon$", "mechanic", "Builds, digs, repairs.");
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
	this.addCommandID("class menu");

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
