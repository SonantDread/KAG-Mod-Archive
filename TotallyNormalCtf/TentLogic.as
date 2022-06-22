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

	if (this.getTeamNum() == 0)
	{
		return;
	}



	s32 gametime = getGameTime() - 5400;
	s32 meteorcount = (1 * Maths::Sqrt(0.2 * (gametime/30))^2) * (Maths::Sin(0.1 * (gametime/30)));
	if (meteorcount < 0)
	{
		meteorcount = 0;
	}

	if (gametime < 5400)
	{
		return;
	}

	if (getGameTime() % 30 == 0)
	{
	    for (int i = 0; i < meteorcount; i++)
	    {
	    	if (isServer())
			{	
				if (XORRandom(3) == 0)
				{
					CBlob@ b2 = server_CreateBlob("rock");
			        if (b2 !is null)
			        {
			            CMap@ map = getMap();
			            f32 mapWidth = (map.tilemapwidth * map.tilesize);
			            f32 mapHeight = (map.tilemapheight * map.tilesize);

			            b2.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
			            b2.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight - XORRandom(80)));
			            b2.setVelocity(Vec2f(16.0f - XORRandom(32), 0.0f));
			        }
			    }

		        if (gametime > 5400)
		        {
			        CBlob@ b = server_CreateBlob("meteor");
			        if (b !is null)
			        {
			            CMap@ map = getMap();
			            f32 mapWidth = (map.tilemapwidth * map.tilesize);
			            f32 mapHeight = (map.tilemapheight * map.tilesize);

			            b.SetMapEdgeFlags(u8(CBlob::map_collide_sides));
			            b.setPosition(Vec2f(XORRandom(mapWidth), -mapHeight - 500 - XORRandom(80)));
			            b.setVelocity(Vec2f(16.0f - XORRandom(32), 0.0f));
			        }
		    	}
	    	}
		}
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	// button for runner
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, buildSpawnMenu, getTranslatedString("Swap Class"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}
