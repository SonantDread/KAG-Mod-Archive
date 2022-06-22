#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"
#include "PrecacheTextures.as"
#include "EmotesCommon.as"

void onInit(CRules@ this)
{
	LoadDefaultMapLoaders();
	LoadDefaultGUI();

	sv_gravity = 9.8f;
	particles_gravity.y = 0.4f;
	sv_visiblity_scale = 1.25f;
	cc_halign = 2;
	cc_valign = 2;

	s_effects = false;
	sv_max_localplayers = 1;
	PrecacheTextures();

	//shader
	Driver@ driver = getDriver();
	driver.AddShader("hq2x", 1.0f);
	driver.SetShader("hq2x", true);

	onRestart(this);
}

bool need_sky_check = true;
void onRestart(CRules@ this)
{
	//map borders
	CMap@ map = getMap();
	if (map !is null)
	{
		map.SetBorderFadeWidth(22.0f);
		map.SetBorderColourTop(SColor(0xff000000));
		map.SetBorderColourLeft(SColor(0xff000000));
		map.SetBorderColourRight(SColor(0xff000000));
		map.SetBorderColourBottom(SColor(0xff000000));
		need_sky_check = true;
	}
}

void onTick(CRules@ this)
{
	if (need_sky_check)
	{
		need_sky_check = false;
		CMap@ map = getMap();
		bool has_solid_tiles = false;
		for(int i = 0; i < map.tilemapwidth; i++) {
			if(map.isTileSolid(map.getTile(i))) {
				has_solid_tiles = true;
				break;
			}
		}
		map.SetBorderColourTop(SColor(has_solid_tiles ? 0xff000000 : 0xff000000));
	}
}

//chat
void onEnterChat(CRules @this)
{
	if (getChatChannel() != 0) return;

	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null)
		set_emote(localblob, Emotes::dots, 100000);
}

void onExitChat(CRules @this)
{
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null)
		set_emote(localblob, Emotes::off);
}
