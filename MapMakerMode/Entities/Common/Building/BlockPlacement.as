#include "PlacementCommon.as";
#include "BuildBlock.as";
#include "HistoryBlocks.as";
#include "Requirements.as";
#include "GameplayEvents.as";

Random@ map_random = Random();

void PlaceBlock(CBlob@ this, u8 index, Vec2f cursorPos, Vec2f temp_start, Vec2f temp_finish)
{
	BuildBlock @bc = getBlockByIndex(this, index);
	
	if (bc is null)
	{
		return;
	}	
	if (bc.tile > 0)
	{
		CMap@ map = getMap();
		Vec2f tpos;
		bool doSym = this.get_bool("symmetry selected");

		if (this.get_u8("brush type") == 0)
		{			
			u8 radius = this.get_u8("brushsize");
			f32 radmax = radius * 4 * radius * 4;

			for (int x_step = -radius; x_step < radius; ++x_step)
			{
				for (int y_step = -radius; y_step < radius; ++y_step)
				{
					Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

					if (off.LengthSquared() > radmax)
						continue;

					Vec2f tpos = cursorPos + off;
					if (tpos.x > -8 && tpos.x < map.tilemapwidth*8)
					{
						Paint(this, map, tpos, bc, doSym);
					}				
				}
			}
		}
		else if (this.get_u8("brush type") == 1)
		{						 
			f32 Distance_x = (temp_finish.x - temp_start.x);
			f32 Distance_y = (temp_finish.y - temp_start.y);

			if( !this.get_bool("canceled"))
			{
				for (int x_step = 0; x_step-1 < (Distance_x < 0 ? -Distance_x/8 : Distance_x/8); ++x_step)
				{
					for (int y_step = 0; y_step-1 < (Distance_y < 0 ? -Distance_y/8 : Distance_y/8); ++y_step)
					{
						Vec2f off(((Distance_x < 0 ? -x_step : x_step) * map.tilesize), ((Distance_y < 0 ? -y_step : y_step) * map.tilesize));

						Vec2f tpos = cursorPos - off + Vec2f(4,4);
						if (tpos.x > -8 && tpos.x < map.tilemapwidth*8)
						{
							Paint(this, map, tpos, bc, doSym);							
						}																	
					}	
				}			
			}
			else
			{
				this.set_bool("canceled",false);
			}
		}
	}
}
void Paint(CBlob@ this, CMap@ map, Vec2f tilepos, BuildBlock @bc, bool doSym)
{	
	TileType maptile = map.getTile(tilepos).type;
	TileType buildtile = this.get_TileType("buildtile");

	bool candie = true;
	CBlob@[] behindBlob;
	getMap().getBlobsAtPosition( tilepos, @behindBlob);	

	HistoryInfo@ history;
	if (!this.get("historyInfo", @history))
	{ return; }

	if (maptile != buildtile)
	{
		for(uint i = 0; i < behindBlob.length; i++)
		{
	        if (behindBlob[i].hasTag("player") || this.get_u8("replace type") == 1) 
	        {
	        	candie = false;
	        }
	        if(candie)
	        {
	        	behindBlob[i].server_Die();
	        }
		}

		if (map.isInWater(tilepos))
		{	
			history.PushHistory( tilepos, maptile, "", -1);
			Vec2f tilespace = map.getTileSpacePosition(tilepos);
			map.RemoveTileFlag( map.getTileOffsetFromTileSpace(tilespace), Tile::WATER_PASSES );
			map.server_setFloodWaterWorldspace(tilepos, false);
		}
		else if (buildtile == 0)
		{		
			if (map.getBlobAtPosition(tilepos) !is null || maptile != CMap::tile_empty)
			{
				history.PushHistory( tilepos, maptile, "", -1);
				getMap().server_SetTile(tilepos , 126);
			}
		}
		else if (buildtile == 12 && maptile != buildtile && maptile != buildtile+1 && maptile != buildtile+2 && maptile != buildtile+3)
		{	
			history.PushHistory( tilepos, maptile, "", -1);
			map.server_SetTile(tilepos, CMap::tile_grass + map_random.NextRanged(3));
		}
		else if(this.get_u8("replace type") == 2)
		{	
			history.PushHistory( tilepos, maptile, "", -1);
			map.server_SetTile(tilepos , bc.tile);		
		}
		else if(this.get_u8("replace type") == 1 && map.isTileSolid(tilepos))
		{	
			history.PushHistory( tilepos, maptile, "", -1);
			map.server_SetTile(tilepos , buildtile);
		}
		else if(this.get_u8("replace type") == 0 && !map.isTileSolid(tilepos))
		{	
			history.PushHistory( tilepos, maptile, "", -1);
			map.server_SetTile(tilepos , buildtile);
		}
	}

	if (doSym)
	{
		f32 mapcenter = map.tilemapwidth*8/2;
		f32 aimdistfromcenter = tilepos.x-mapcenter;
		Vec2f sympos = Vec2f(mapcenter-aimdistfromcenter, tilepos.y);
		TileType symmaptile = map.getTile(sympos).type;

		if (symmaptile != buildtile)
		{			
			CBlob@[] behindBlobSym;
			getMap().getBlobsAtPosition( sympos, @behindBlobSym);

	  		for(uint i = 0; i < behindBlobSym.length; i++)
			{
	            if (behindBlobSym[i].hasTag("player"))
	            {
	            	candie = false;								
	            }
	            if(candie)
	            {
	            	behindBlobSym[i].server_Die();
	            }
			}
			if (map.isInWater(sympos))
			{
				history.PushHistory( sympos, symmaptile, "", -1);
				Vec2f symtilespace = map.getTileSpacePosition(sympos);					
				map.RemoveTileFlag( map.getTileOffsetFromTileSpace(symtilespace), Tile::WATER_PASSES );
				map.server_setFloodWaterWorldspace(sympos, false);
			}
			else if (buildtile == 0)
			{
				if (map.getBlobAtPosition(sympos) !is null || symmaptile != CMap::tile_empty)
				{
					history.PushHistory( sympos, symmaptile, "", -1);
					map.server_SetTile(sympos, 126);
				}				
			}
			else if (buildtile == 12 && symmaptile != buildtile && symmaptile != buildtile+1 && symmaptile != buildtile+2 && symmaptile != buildtile+3)
			{	
				history.PushHistory( sympos, symmaptile, "", -1);
				map.server_SetTile(sympos, CMap::tile_grass + map_random.NextRanged(3));
			}
			else if(this.get_u8("replace type") == 2)
			{	
				history.PushHistory( sympos, symmaptile, "", -1);
				map.server_SetTile(sympos , buildtile);
			}
			else if(this.get_u8("replace type") == 1 && map.isTileSolid(sympos))
			{	
				history.PushHistory( sympos, symmaptile, "", -1);
				map.server_SetTile(sympos, buildtile);
			}
			else if(this.get_u8("replace type") == 0 && !map.isTileSolid(sympos))
			{	
				history.PushHistory( sympos, symmaptile, "", -1);
				map.server_SetTile(sympos , buildtile);
			}
		}
	}
}

void onInit(CBlob@ this)
{
	AddCursor(this);
	SetupBuildDelay(this);
	this.addCommandID("SetTimeline");
	this.addCommandID("PlaceBlocks");
	this.addCommandID("undoHistory");
	this.addCommandID("redoHistory");
	this.set_bool("canceled", false);

	HistoryInfo history;
	history.currentHistoryTimeline = 1;
	this.set("historyInfo", @history);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";	
}

Vec2f getBottomOfCursor(Vec2f cursorPos, CBlob@ carryBlob)
{
	// check at bottom of cursor
	CMap@ map = getMap();
	f32 w = map.tilesize / 2.0f;
	f32 h = map.tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}

void pushPickup(CBlob@ this)
{
	HistoryInfo@ history;
	if (!this.get("historyInfo", @history))
	{
		return;
	}

	CMap@ map = getMap();
	
	CBlob@ underblob = getMap().getBlobAtPosition(this.getAimPos());
	if (underblob !is null && !underblob.isAttached() && !underblob.hasTag("player"))
	{			
		history.setTimeline();
		TileType maptile = getMap().getTile(underblob.getPosition()).type;
		history.PushHistory( underblob.getPosition(), maptile, underblob.getName(), underblob.getTeamNum());	
	}
}

void onTick(CBlob@ this)
{
	if (this.isInInventory()) { return; }
	if (getHUD().hasMenus()) { return; }
	if (getGameTime() - this.get_u32("closetime") < 1 ) { this.DisableKeys(key_action1); return; }
	//if (isBuildDelayed(this)) { return; }
	if (this.isKeyJustReleased(key_pickup)) { }//pushPickup(this); }
	BlockCursor @bc; this.get("blockCursor", @bc); if (bc is null) { return; }
	HistoryInfo@ history; if (!this.get("historyInfo", @history)) { return; }	

	if ((getControls().isKeyPressed( KEY_LCONTROL ) || getControls().isKeyPressed( KEY_RCONTROL )) && getControls().isKeyJustPressed( KEY_KEY_Z ))
	{		
		this.SendCommand(this.getCommandID("undoHistory"));
	}

	else if ((getControls().isKeyPressed( KEY_LCONTROL ) || getControls().isKeyPressed( KEY_RCONTROL )) && getControls().isKeyJustPressed( KEY_KEY_X ))
	{	
		this.SendCommand(this.getCommandID("redoHistory"));		
	}

	SetTileAimpos(this, bc);
	TileType buildtile = this.get_TileType("buildtile");
	bool hasCanceled = false;	

	if (this.isKeyJustPressed(key_action2) && this.isKeyPressed(key_action1))
	{		
		hasCanceled = true;	
		this.set_bool("canceled", true);

		history.currentHistoryTimeline--;
	}
	else
	{
		this.set_bool("canceled",false);
	}

	if (buildtile > 0 && !hasCanceled)
	{
		bc.blockActive = true;
		bc.blobActive = false;
		CMap@ map = this.getMap();
		u8 blockIndex = getBlockIndexByTile(this, buildtile);
		BuildBlock @block = getBlockByIndex(this, blockIndex);
		if (block !is null)
		{
			bc.missing.Clear();
		}	

		if (this.isKeyJustPressed(key_action1))
		{
			this.SendCommand(this.getCommandID("SetTimeline"));
		}	

		// place block
		if (this.get_u8("brush type") == 1)
		{
			if (this.isKeyJustPressed(key_action1))
			{				
				this.set_Vec2f("temp start", bc.tileAimPos);
			}
			if (this.isKeyPressed(key_action1) && bc.tileAimPos != this.get_Vec2f("temp finish"))
			{				
				this.set_Vec2f("temp finish", bc.tileAimPos);
			}		
			if (this.isKeyJustReleased(key_action1))
			{	
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);				
				params.write_Vec2f(this.get_Vec2f("temp start"));
				params.write_Vec2f(this.get_Vec2f("temp finish"));
				this.SendCommand(this.getCommandID("PlaceBlocks"), params);
				u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, block.tile < 255 ? delay : delay / 3);
				bc.blockActive = false;
				
				this.set_Vec2f("temp start", bc.tileAimPos);	
				this.set_Vec2f("temp finish", bc.tileAimPos);
			}
			Vec2f ts = this.get_Vec2f("temp start");
			u8 stxp = ts.x;

			if (!this.isKeyPressed(key_action1))
			{	
				if (stxp < bc.tileAimPos.x)	
				{		
					this.set_Vec2f("temp start", bc.tileAimPos);	
					this.set_Vec2f("temp finish", bc.tileAimPos);
				}
			}
		}

		if (this.get_u8("brush type") == 0)
		{
			if (this.isKeyPressed(key_action1))
			{
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				params.write_Vec2f(Vec2f_zero);
				params.write_Vec2f(Vec2f_zero);
				this.SendCommand(this.getCommandID("PlaceBlocks"), params);
				u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, block.tile < 255 ? delay : delay / 3);
				bc.blockActive = false;
			}
			else if (this.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
			{
				Sound::Play("NoAmmo.ogg");
			}
		}
	}
	else
	{
		bc.blockActive = false;
		this.set_Vec2f("temp start", bc.tileAimPos);	
		this.set_Vec2f("temp finish", bc.tileAimPos);
	}
}
// render block placement

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	CBlob @carryBlob = blob.getCarriedBlob();
	if (carryBlob !is null)
	{
		return;
	}
	// draw a map block or other blob that snaps to grid
	TileType buildtile = blob.get_TileType("buildtile");

	if (buildtile > 0)
	{
		CMap@ map = getMap();
		BlockCursor @bc;
		blob.get("blockCursor", @bc);
	
		if (blob.get_u8("brush type") == 0)
		{			
			u8 radius = blob.get_u8("brushsize");
			f32 radsq = radius * 4 * radius * 4;

			for (int x_step = -radius; x_step < radius; ++x_step)
			{
				for (int y_step = -radius; y_step < radius; ++y_step)
				{
					Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

					if (off.LengthSquared() >  radsq)
						continue;

					Vec2f tpos = bc.tileAimPos +  off;				

					drawbrushat(this, map, tpos);	

					if (blob.get_bool("symmetry selected")) // draw symmetry boxes
					{	
						f32 mapcenter = map.tilemapwidth*8/2;

						Vec2f tl(tpos.x+0.5f,tpos.y+0.5f);
						Vec2f tr(tpos.x+7.5f,tpos.y+0.5f);
						Vec2f bl(tpos.x+0.5f,tpos.y+7.5f);
						Vec2f br(tpos.x+7.5f,tpos.y+7.5f);

						GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-tr.x,tr.y), SColor(255,255,0,225));
						GUI::DrawLine( Vec2f(mapcenter*2-bl.x,bl.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));

						GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-bl.x,bl.y), SColor(255,255,0,225));
						GUI::DrawLine( Vec2f(mapcenter*2-tr.x,tr.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));
					}			
				}		
			}
		}
		else if (blob.get_u8("brush type") == 1)
		{
			Vec2f temp_start = blob.get_Vec2f("temp start");
			Vec2f temp_finish = blob.get_Vec2f("temp finish");
	 
			f32 Distance_x = (temp_finish.x - temp_start.x);
			f32 Distance_y = (temp_finish.y - temp_start.y);	
			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;	
			u8 rpt = blob.get_u8("replace type");		

			for (int x_step = 0; x_step-1 < (Distance_x < 0 ? -Distance_x/8 : Distance_x/8); ++x_step)
			{
				for (int y_step = 0; y_step-1 < (Distance_y < 0 ? -Distance_y/8 : Distance_y/8); ++y_step)
				{				
					Vec2f off(((Distance_x < 0 ? -x_step : x_step) * map.tilesize), ((Distance_y < 0 ? -y_step : y_step) * map.tilesize));

					map.DrawTile(bc.tileAimPos - off, buildtile,
					SColor(255, 255, 255, 255),
					getCamera().targetDistance, false);

					u8 placecolour = rpt == 2 ? 1 : rpt == 0 ? map.isTileSolid(bc.tileAimPos - off) ? 0:1 : map.isTileSolid(bc.tileAimPos - off) ? 1:0;
					
					Vec2f aligned = getDriver().getScreenPosFromWorldPos(bc.tileAimPos - off);
					GUI::DrawIcon( "PlaceColours.png", placecolour, Vec2f(8,8), aligned, zoom );					
				}
			}	
					
			u8 xamount = (Distance_x < 0 ? -Distance_x/8 : Distance_x/8)+1;
			u8 yamount = (Distance_y < 0 ? -Distance_y/8 : Distance_y/8)+1;
			GUI::SetFont("menu");
			GUI::DrawText(("x:"+xamount)+"\n"+("y:"+yamount), getDriver().getScreenPosFromWorldPos(bc.tileAimPos - Vec2f(Distance_x < 0 ? 12.0f : -12.0f, Distance_y < 0 ? 12.0f : -12.0f)), SColor(32,255,255,255));	
			//GUI::DrawText(, getDriver().getScreenPosFromWorldPos(bc.tileAimPos - Vec2f(0.0f, 10.0f) : Vec2f(0.0f, -10.0f))), color_white);

			if (blob.get_bool("symmetry selected")) // draw symmetry box
			{	
				f32 mapcenter = map.tilemapwidth*8/2;

				Vec2f tl(((Distance_x >= 0.0f ? 0.5f : 7.5f)+temp_start.x),(Distance_y >= 0.0f ? 0.5f : 7.5f)+temp_start.y);
				Vec2f tr(((Distance_x >= 0.0f ? 7.5f : 0.5f)+temp_finish.x),(Distance_y >= 0.0f ? 0.5f : 7.5f)+temp_start.y);
				Vec2f bl(((Distance_x >= 0.0f ? 0.5f : 7.5f)+temp_start.x),(Distance_y >= 0.0f ? 7.5f : 0.5f)+temp_finish.y);
				Vec2f br(((Distance_x >= 0.0f ? 7.5f : 0.5f)+temp_finish.x),(Distance_y >= 0.0f ? 7.5f : 0.5f)+temp_finish.y);

				GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-tr.x,tr.y), SColor(255,255,0,225));
				GUI::DrawLine( Vec2f(mapcenter*2-bl.x,bl.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));

				GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-bl.x,bl.y), SColor(255,255,0,225));
				GUI::DrawLine( Vec2f(mapcenter*2-tr.x,tr.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));
			}	
		}
	}
}

void drawbrushat(CSprite@ this, CMap@ map, Vec2f tilepos)
{
	CBlob@ blob = this.getBlob();
	TileType buildtile = blob.get_TileType("buildtile");

	map.DrawTile(tilepos, buildtile,
	SColor(255, 255, 255, 255),
	getCamera().targetDistance, false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
	if (getNet().isServer() && cmd == this.getCommandID("SetTimeline"))
	{			
		HistoryInfo@ history;
		if (this.get("historyInfo", @history))
		{		
			history.setTimeline();
		}								
	}

	if (getNet().isServer() && cmd == this.getCommandID("PlaceBlocks"))
	{			
		u8 index = params.read_u8();
		Vec2f pos = params.read_Vec2f();
		Vec2f ts = params.read_Vec2f();
		Vec2f tf = params.read_Vec2f();
		PlaceBlock(this, index, pos, ts, tf);
								
	}
	else if (getNet().isServer() && cmd == this.getCommandID("undoHistory"))
	{	
		HistoryInfo@ history;
		if (this.get("historyInfo", @history))
		{
			CMap@ map = getMap();

			if (history.currentHistoryTimeline-1 > 0)
			{
				history.currentHistoryTimeline--;
			
				for(uint i = 0; i < history.historyblocks[history.currentHistoryTimeline].length; i++)
				{
					HistoryBlock@ historyblock = history.historyblocks[history.currentHistoryTimeline][i];
					
					Vec2f tpos = historyblock.pos;
					CBlob@ underblob = map.getBlobAtPosition(tpos);
					TileType maptile = getMap().getTile(tpos).type;

					if (maptile == 0)
					{
						maptile = 126;
					}

					if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
					{
						HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), underblob.getPosition());
						history.historyblocks[history.currentHistoryTimeline+1].insertAt(i,b);	
					}	
					else
					{
						HistoryBlock b( maptile, "", 0, tpos);
						history.historyblocks[history.currentHistoryTimeline+1].insertAt(i,b);
					}	

					map.server_SetTile(tpos , historyblock.tile);

					if (map.isInWater(tpos))
					{	
						Vec2f tilespace = map.getTileSpacePosition(tpos);
						map.RemoveTileFlag( map.getTileOffsetFromTileSpace(tilespace), Tile::WATER_PASSES );
						map.server_setFloodWaterWorldspace(tpos, false);
					}

					CBlob@[] overlapping;
					map.getBlobsAtPosition(tpos, @overlapping);
					for(uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ underblob = overlapping[i];
						if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
						{ 
							underblob.server_Die();
						}
					}	

					if (historyblock.name != "" && underblob is null)
					{					
						CBlob@ undoBlob = server_CreateBlob(historyblock.name, historyblock.team, historyblock.pos); // add team
						if (undoBlob !is null)
						{
							undoBlob.getShape().SetStatic(true);
						}
					}
				}
				history.historyblocks[history.currentHistoryTimeline+1].set_length(history.historyblocks[history.currentHistoryTimeline].length);
			}		
		}
	}
	else if (getNet().isServer() && cmd == this.getCommandID("redoHistory"))
	{				
		HistoryInfo@ history;
		if (this.get("historyInfo", @history))
		{
			CMap@ map = getMap();		
			if (history.historyblocks[history.currentHistoryTimeline+1].length != 0)
			{
				history.currentHistoryTimeline++;

				for(uint i = 0; i < history.historyblocks[history.currentHistoryTimeline].length; i++)
				{
					HistoryBlock@ historyblock = history.historyblocks[history.currentHistoryTimeline][i];
									
					Vec2f tpos = historyblock.pos;
					TileType maptile = getMap().getTile(tpos).type;

					if (maptile == 0)
					{
						maptile = 126;
					}

					CBlob@ underblob = getMap().getBlobAtPosition(historyblock.pos);
					if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
					{
						HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), underblob.getPosition());
						history.historyblocks[history.currentHistoryTimeline-1].insertAt(i,b);	

						underblob.server_Die();
					}	
					else
					{
						HistoryBlock b( maptile, "", 0, tpos);
						history.historyblocks[history.currentHistoryTimeline-1].insertAt(i,b);	
					}					

					getMap().server_SetTile(tpos , historyblock.tile);					

					CBlob@[] overlapping;
					getMap().getBlobsAtPosition(tpos, @overlapping);
					for(uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ underblob = overlapping[i];
						if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
						{ 
							underblob.server_Die();
						}
					}			

					if (historyblock.name != "" && underblob is null)
					{					
						CBlob@ redoBlob = server_CreateBlob(historyblock.name, historyblock.team, tpos);
						if (redoBlob !is null)
						{
							redoBlob.getShape().SetStatic(true);
						}
					}				
				}
				history.historyblocks[history.currentHistoryTimeline-1].set_length(history.historyblocks[history.currentHistoryTimeline].length);
			}		
		}
	}
}