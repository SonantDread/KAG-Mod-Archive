// Tent logic

#include "StandardRespawnCommand.as";
#include "ClassSelectMenu.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	this.CreateRespawnPoint("tent", Vec2f(0.0f, -4.0f));
	if(this.getTeamNum() == 0)
	{
		InitClasses(this);
	}
	else
	{
		AddIconToken("$kagician_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 32);
		AddIconToken("$necromancer_class_icon$", "GUI/MenuItems.png", Vec2f(32, 32), 33);
		
		addPlayerClass(this, "Kagician", "$kagician_class_icon$", "kagician", "Casts spells.");
		addPlayerClass(this, "Necromancer", "$necromancer_class_icon$", "necromancer", "Summons minions and kills people.");
	}
	this.Tag("change class drop inventory");

	this.Tag("respawn");

	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, SpawnCmd::buildMenu, "Swap Class", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}