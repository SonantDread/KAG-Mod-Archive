#include "CanUse.as";

bool editor_cursor = false;

const string editor_place = "editor place";
const string editor_destroy = "editor destroy";
const string editor_copy = "editor copy";
float Limit;

const string cursorTexture = "../Mods/PrimitiveEditor/EditorCursor.png";
 
void onInit( CRules@ this )
{
    this.addCommandID(editor_place);
    this.addCommandID(editor_destroy);
	this.addCommandID(editor_copy);
	
	Limit = 10;
}

void onTick(CRules@ this)
{
		if(getNet().isClient())
		{
			CPlayer@ p = getLocalPlayer();
			CMap@ map = getMap();
			if (p !is null)
			{
				bool op = CanUse(p.getUsername());
				if(op)
				{
					if (getControls().isKeyJustPressed(KEY_LCONTROL))
					{
						editor_cursor = !editor_cursor;
					}

					if (getControls().isKeyJustPressed(KEY_KEY_Z))
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_destroy), params);
					}
					if (getControls().isKeyPressed(KEY_LSHIFT))
					{
						if (getControls().isKeyJustPressed(KEY_KEY_X))
						{
							CBitStream params;
							params.write_u16(p.getNetworkID());
							this.SendCommand(this.getCommandID(editor_place), params);
						}
						if (getControls().isKeyJustPressed(KEY_KEY_Z))
						{
							CBitStream params;
							params.write_u16(p.getNetworkID());
							this.SendCommand(this.getCommandID(editor_destroy), params);
						}
					}
					else
					{
						if (getControls().isKeyPressed(KEY_KEY_X))
						{
							CBitStream params;
							params.write_u16(p.getNetworkID());
							this.SendCommand(this.getCommandID(editor_place), params);
						}
						if (getControls().isKeyPressed(KEY_KEY_Z))
						{
							CBitStream params;
							params.write_u16(p.getNetworkID());
							this.SendCommand(this.getCommandID(editor_destroy), params);
						}
					}
					if (getControls().isKeyJustPressed(KEY_KEY_B))
					{
						CBlob@ blob = p.getBlob();
						if (blob !is null)
						{
							Vec2f pos = blob.getAimPos();
							blob.set_TileType("buildtile", map.getTile(pos).type);
						}
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_copy), params);
					}
				}
				else
				{
					if(Limit > 0.999f)
					{
					if (getControls().isKeyJustPressed(KEY_LCONTROL))
					{
						Limit -= 1;
						editor_cursor = !editor_cursor;
					}

					if (getControls().isKeyJustPressed(KEY_KEY_Z))
					{
						Limit -= 1;
						CBitStream params;
						params.write_u16(p.getNetworkID());
						
						this.SendCommand(this.getCommandID(editor_destroy), params);
					}
					if (getControls().isKeyJustPressed(KEY_KEY_X))
						{
							Limit -= 1;
							CBitStream params;
							params.write_u16(p.getNetworkID());
							
							this.SendCommand(this.getCommandID(editor_place), params);
						}
					}
					if(Limit < 40)
					{
						Limit += 0.05f;
					}
					//print(Limit + "");
				}	
		}
	}
}

void onRender(CRules@ this)
{
	if(editor_cursor)
	{
		CPlayer@ p = getLocalPlayer();

		if (p is null || !p.isMyPlayer()) { return; }
		if (p.getBlob() !is null)
		{
			Vec2f position = Vec2f(int(p.getBlob().getAimPos().x/8), int(p.getBlob().getAimPos().y/8));
			position = getDriver().getScreenPosFromWorldPos(position*8 - Vec2f(1, 1));
			GUI::DrawIcon(cursorTexture, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if (!getNet().isServer())
		return;

    if (cmd == this.getCommandID(editor_place))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		bool op = CanUse(p.getUsername());
		if (blob !is null)
		{
			Vec2f pos = blob.getAimPos();
			CBlob@ behindBlob = getMap().getBlobAtPosition(pos);
			if (behindBlob !is null)
			{
				string behindname = behindBlob.getName();
				if(op)
				{
					behindBlob.server_Die();
				}
				else if(behindname != "knight" && behindname != "archer" && behindname != "builder" && behindname != "sdkjfdsklfjklsdfj" && behindname != "burd" && behindname !=  "efzjklejfklzejfvchjizerlgfhzeuklfhzkfhhjghjkghjkghjkgkjhgefzjklejfklzejfvchjizerlgfhzeuklfhzkfhhjghjkghjkghjkgkjhg" && behindname != "jzeklghefjzelmifghezlfihzemazehldklhfjklhgjklhzcfjklshfkghklmhiolluh" && behindname != "priest" && behindname != "fsdfjhksdjkfhjslqhfuioshufghdfuih" && behindname != "undeadarcher" && behindname != "undeadbuilder" && behindname != "undeadbunny" && behindname != "undeadgargoyle" && behindname != "undeadknight" && behindname != "undeadmystic" && behindname != "undeadnecromancer" && behindname != "undeadslayer" && behindname != "undeadstalker" && behindname != "keg" && behindname != "oct" && behindname != "hayrock" && behindname != "catto" && behindname != "catto2" && behindname != "horror" && behindname != "pbrute" && behindname != "pcrawler" && behindname != "pcrawler2" && behindname != "phellknight" && behindname != "zbison" && behindname != "zbison2" && behindname != "zombie" && behindname != "zombie2" && behindname != "zombieknight" && behindname != "zombieknight2" && behindname != "hall" && behindname != "necromancershop" && behindname != "blackbuilding" && behindname != "dksjgheiruvhirbneuirg" && behindname != "digger" && behindname != "reiughdfkjhgreuihgjkjjhgkjldfhgurvnjfdkdhglkdhufhgrklhgdkljrhgukhfkjhg" && behindname != "reiughdfkjhgreuihgjkjjhgkjldfhgurvnjfdkdhglkdhufhgrklhgdkljrhgukhfkjhgjlkjklj" && behindname != "Haygod" && behindname != "Only_For_Admin_So_Stop_Search_In_File_Like_An_Geek" && behindname != "minotaur" && behindname != "BossGreenTroll" && behindname != "BossRabidDog" && behindname != "BossRedDragon" && behindname != "Calimity" && behindname != "wizard" && behindname != "undeadarcher" && behindname != "crossbow" && behindname != "craftshop" && behindname != "garage" && behindname != "gunshop" && behindname != "gunzerkershop" && behindname != "techshop" && behindname != "scout" && behindname != "soldier" && behindname != "lws" && behindname != "lws_missile" && behindname != "lws_aircraft" && behindname != "techshop" && behindname != "craftshop" && behindname != "garage" && behindname != "gunshop" && behindname != "factoryframe" && behindname != "kiln" && behindname != "factorysteel" && behindname != "factoryjeremy" && behindname != "factorystergun" && behindname != "factoryadvancedframe" && behindname != "factorybeer" && behindname != "factoryadvancedquarry" && behindname != "factoryadvancedbergman" && behindname != "factoryjeffery" && behindname != "factorym95" && behindname != "factorymp18" && behindname != "satagayversion" && behindname != "steel_door" && behindname != "undeadarsonist" && behindname != "sentry" && behindname != "sam")
				{
				
					behindBlob.server_Die();
				}
				
			}
			else
			{
				map.server_SetTile(pos, CMap::tile_empty);
			}
		}
	}
	else if (cmd == this.getCommandID(editor_destroy))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f pos = blob.getAimPos();
			if (blob.get_TileType("buildtile") != 0)
				map.server_SetTile(pos, blob.get_TileType("buildtile"));
			else if (blob.getCarriedBlob() !is null)
			{
				bool op = CanUse(p.getUsername());
				if (canPlaceBlobAtPos(getBottomOfCursor(pos)))
				{
				if(op)
				{
					CBlob@ newblob = server_CreateBlob(blob.getCarriedBlob().getName(), blob.getCarriedBlob().getTeamNum(), getBottomOfCursor(pos));
					if (newblob.isSnapToGrid())
					{
						CShape@ shape = newblob.getShape();
						shape.SetStatic(true);
					}
				}
				else if(blob.getCarriedBlob().getName() != "bomb" && blob.getCarriedBlob().getName() != "keg" && blob.getCarriedBlob().getName() != "spikes" && blob.getCarriedBlob().getName() != "boulder" && blob.getCarriedBlob().getName() != "knight" && blob.getCarriedBlob().getName() != "archer" && blob.getCarriedBlob().getName() != "builder" && blob.getCarriedBlob().getName() != "shark" && blob.getCarriedBlob().getName() != "raft" && blob.getCarriedBlob().getName() != "hayrock" && blob.getCarriedBlob().getName() != "catto" && blob.getCarriedBlob().getName() != "catto2" && blob.getCarriedBlob().getName() != "horror" && blob.getCarriedBlob().getName() != "pbrute" && blob.getCarriedBlob().getName() != "pcrawler" && blob.getCarriedBlob().getName() != "pcrawler2" && blob.getCarriedBlob().getName() != "phellknight" && blob.getCarriedBlob().getName() != "zbison" && blob.getCarriedBlob().getName() != "zbison2" && blob.getCarriedBlob().getName() != "zombie" && blob.getCarriedBlob().getName() != "zombie2" && blob.getCarriedBlob().getName() != "zombieknight" && blob.getCarriedBlob().getName() != "zombieknight2" && blob.getCarriedBlob().getName() != "mushroom_block" && blob.getCarriedBlob().getName() != "fire_trap_block" && blob.getCarriedBlob().getName() != "whitepage" && blob.getCarriedBlob().getName() != "woodenspikes" && blob.getCarriedBlob().getName() != "mine" && blob.getCarriedBlob().getName() != "sdkjfdsklfjklsdfj" && blob.getCarriedBlob().getName() != "efzjklejfklzejfvchjizerlgfhzeuklfhzkfhhjghjkghjkghjkgkjhgefzjklejfklzejfvchjizerlgfhzeuklfhzkfhhjghjkghjkghjkgkjhg" && blob.getCarriedBlob().getName() != "jzeklghefjzelmifghezlfihzemazehldklhfjklhgjklhzcfjklshfkghklmhiolluh" && blob.getCarriedBlob().getName() != "priest" && blob.getCarriedBlob().getName() != "fsdfjhksdjkfhjslqhfuioshufghdfuih" && blob.getCarriedBlob().getName() != "fjkezfgjpofjfiopezjfqsofjhklmqsjdfiofhjeazocvjqzeiofhjeofvh" && blob.getCarriedBlob().getName() != "undeadbuilder" && blob.getCarriedBlob().getName() != "undeadbunny" && blob.getCarriedBlob().getName() != "undeadgargoyle" && blob.getCarriedBlob().getName() != "undeadknight" && blob.getCarriedBlob().getName() != "undeadmystic" && blob.getCarriedBlob().getName() != "undeadnecromancer" && blob.getCarriedBlob().getName() != "undeadslayer" && blob.getCarriedBlob().getName() != "undeadstalker" && blob.getCarriedBlob().getName() != "waterbomb" && blob.getCarriedBlob().getName() != "shorde" && blob.getCarriedBlob().getName() != "szombie" && blob.getCarriedBlob().getName() != "sgreg" && blob.getCarriedBlob().getName() != "selemental" && blob.getCarriedBlob().getName() != "sshark" && blob.getCarriedBlob().getName() != "sfshark" && blob.getCarriedBlob().getName() != "keg" && blob.getCarriedBlob().getName() != "contrabass" && blob.getCarriedBlob().getName() != "blackbuilding" && blob.getCarriedBlob().getName() != "necromancershop" && blob.getCarriedBlob().getName() != "blackpage" && blob.getCarriedBlob().getName() != "smeteor" && blob.getCarriedBlob().getName() != "bomb" && blob.getCarriedBlob().getName() != "Stop_search_file_you_are_ridiculous" && blob.getCarriedBlob().getName() != "saw" && blob.getCarriedBlob().getName() != "youwillneverfindme" && blob.getCarriedBlob().getName() != "ak47" && blob.getCarriedBlob().getName() != "bergman" && blob.getCarriedBlob().getName() != "bigiron" && blob.getCarriedBlob().getName() != "jeremy" && blob.getCarriedBlob().getName() != "jeremymk2" && blob.getCarriedBlob().getName() != "leveraction" && blob.getCarriedBlob().getName() != "martyrifle" && blob.getCarriedBlob().getName() != "lewisgun" && blob.getCarriedBlob().getName() != "m1" && blob.getCarriedBlob().getName() != "m95" && blob.getCarriedBlob().getName() != "m95" && blob.getCarriedBlob().getName() != "mp18" && blob.getCarriedBlob().getName() != "mp40" && blob.getCarriedBlob().getName() != "sasha" && blob.getCarriedBlob().getName() != "shitgun" && blob.getCarriedBlob().getName() != "sigfried" && blob.getCarriedBlob().getName() != "smalliron" && blob.getCarriedBlob().getName() != "stergun" && blob.getCarriedBlob().getName() != "stergunmk2" && blob.getCarriedBlob().getName() != "stg44" && blob.getCarriedBlob().getName() != "supershotgun" && blob.getCarriedBlob().getName() != "thundertube" && blob.getCarriedBlob().getName() != "trenchgun" && blob.getCarriedBlob().getName() != "ultrashotgun" && blob.getCarriedBlob().getName() != "sentry"  && blob.getCarriedBlob().getName() != "sam"  && blob.getCarriedBlob().getName() != "sat"  && blob.getCarriedBlob().getName() != "lws"  && blob.getCarriedBlob().getName() != "zapper"  && blob.getCarriedBlob().getName() != "mat_steel"  && blob.getCarriedBlob().getName() != "mat_coal"  && blob.getCarriedBlob().getName() != "material_powder_crystal"  && blob.getCarriedBlob().getName() != "mat_tape" && blob.getCarriedBlob().getName() != "mat_bolts"  && blob.getCarriedBlob().getName() != "scout" && blob.getCarriedBlob().getName() != "soldier" && blob.getCarriedBlob().getName() != "mat_cementing" && blob.getCarriedBlob().getName() != "mat_polymer" && blob.getCarriedBlob().getName() != "mat_elec" && blob.getCarriedBlob().getName() != "baaby" && blob.getCarriedBlob().getName() != "beer" && blob.getCarriedBlob().getName() != "crak" && blob.getCarriedBlob().getName() != "bobomax" && blob.getCarriedBlob().getName() != "boof" && blob.getCarriedBlob().getName() != "bobongo" && blob.getCarriedBlob().getName() != "fusk" && blob.getCarriedBlob().getName() != "fiks" && blob.getCarriedBlob().getName() != "domino" && blob.getCarriedBlob().getName() != "foof" && blob.getCarriedBlob().getName() != "gooby" && blob.getCarriedBlob().getName() != "paxilon" && blob.getCarriedBlob().getName() != "love" && blob.getCarriedBlob().getName() != "poot" && blob.getCarriedBlob().getName() != "rippio" && blob.getCarriedBlob().getName() != "propesko" && blob.getCarriedBlob().getName() != "radpill" && blob.getCarriedBlob().getName() != "schisk" && blob.getCarriedBlob().getName() != "stim" && blob.getCarriedBlob().getName() != "vodka" && blob.getCarriedBlob().getName() != "mat_battery" && blob.getCarriedBlob().getName() != "mat_gatlingammo" && blob.getCarriedBlob().getName() != "mat_sammissile" && blob.getCarriedBlob().getName() != "mat_iron" && blob.getCarriedBlob().getName() != "mat_sammissile" && blob.getCarriedBlob().getName() != "satagayversion" && blob.getCarriedBlob().getName() != "dew" && blob.getCarriedBlob().getName() != "sosek" && blob.getCarriedBlob().getName() != "fumes" && blob.getCarriedBlob().getName() != "birb" && blob.getCarriedBlob().getName() != "piglet" && blob.getCarriedBlob().getName() != "bunny" && blob.getCarriedBlob().getName() != "mat_bedrock" && blob.getCarriedBlob().getName() != "mat_org" && blob.getCarriedBlob().getName() != "material_powder_crystal" && blob.getCarriedBlob().getName() != "undeadarsonist" && blob.getCarriedBlob().getName() != "steel_door")
				{
					
					CBlob@ newblob = server_CreateBlob(blob.getCarriedBlob().getName(), blob.getCarriedBlob().getTeamNum(), getBottomOfCursor(pos));
					if (newblob.isSnapToGrid())
					{			
						CShape@ shape = newblob.getShape();
						shape.SetStatic(true);
					}
				}
				
				}
			}
		}
	}
	else if (cmd == this.getCommandID(editor_copy))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f pos = blob.getAimPos();
			blob.set_TileType("buildtile", map.getTile(pos).type);
		}
	}
}

bool canPlaceBlobAtPos( Vec2f pos )
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	
	  @_tempBlob = getMap().getBlobAtPosition( pos );
	if(_tempBlob !is null && _tempBlob.isCollidable())
	{
		  @_tempShape = _tempBlob.getShape();
		if(_tempShape.isStatic())
		    return false;
	}
	return true;
}

CPlayer@ ResolvePlayer( CBitStream@ data )
{
    u16 playerNetID;
	if(!data.saferead_u16(playerNetID)) return null;
	
	return getPlayerByNetworkId(playerNetID);
}

Vec2f getBottomOfCursor(Vec2f cursorPos)
{
	cursorPos = getMap().getTileSpacePosition(cursorPos);
	cursorPos = getMap().getTileWorldPosition(cursorPos);
	f32 w = getMap().tilesize / 2.0f;
	f32 h = getMap().tilesize / 2.0f;
	int offsetY = Maths::Max(1, Maths::Round(8 / getMap().tilesize)) - 1;
	h -= offsetY * getMap().tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}