// Tent logic

#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	this.CreateRespawnPoint("tent", Vec2f(0.0f, -4.0f));
	InitClasses(this);
	this.Tag("change class drop inventory");

	this.Tag("respawn");

	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));

	if(!this.exists("playercharms"))
	{
		InitCharms(this);
	}
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
				canChangeClass(this, blob) && blob.getTeamNum() == this.getTeamNum() && //can change class
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 4) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		AddIconToken("$switch_charms$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 11, 2);
		caller.CreateGenericButton("$switch_charms$", Vec2f(0, -5), this, SpawnCmd::changeCharm, "Switch Charms", params);
	}

	if (caller !is null && canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, SpawnCmd::buildMenu, getTranslatedString("Swap Class"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}
