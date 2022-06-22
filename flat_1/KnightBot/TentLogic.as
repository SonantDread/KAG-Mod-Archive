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

	// BC Bot spawn timer
  	this.set_u32("SpawnMax",2800);
	this.set_u32("SpawnTimer",this.get_u32("SpawnMax"));
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

	// BC Respawn Knight bot at tent (code from Conclave)
 	if(this.get_u32("SpawnTimer") > 0 ) {
   		this.set_u32("SpawnTimer",this.get_u32("SpawnTimer")-1);
 	}
  	else if(this.get_u32("SpawnTimer")== 0) {
  		CBlob@ blob = server_CreateBlobNoInit("botknight");
    		if (blob !is null)
    		{
       			blob.server_setTeamNum(this.getTeamNum());
        		blob.setPosition(this.getPosition());
        		blob.set_string("botknight", "botknight");
        		blob.Tag("bot");
        		blob.Init();
        		if(blob.getTeamNum() == 1)
          			blob.SetFacingLeft(true);
        		else
          			blob.SetFacingLeft(false);
        

        		blob.getBrain().server_SetActive(true);
        		blob.setSexNum(1);
        		blob.setHeadNum(1);
        		blob.server_SetTimeToDie(120);	 // delete after 120 seconds
      		}
    
    	this.set_u32("SpawnTimer",this.get_u32("SpawnMax"));
  	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	// button for runner
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
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

