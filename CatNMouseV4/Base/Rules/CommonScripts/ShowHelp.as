#include "modname.as";
#define CLIENT_ONLY

bool isShowing = true;
const Vec2f size(720.0f, 742.0f); //window size
const string helpFilename = "Base/Rules/CommonScripts/help.png";
const SColor fontColor(255,26,78,131);

const string Update_Entry = "";

void onInit(CRules@ this)
{
    if (!GUI::isFontLoaded("bunniE"))
        GUI::LoadFont("bunniE", "../Mods/"+modname+"/Base/Rules/CommonScripts/11px3bus.ttf", 20, false);
}

void onTick(CRules@ this)
{
	CControls@ cls = getControls();
	if (cls.isKeyJustPressed(KEY_KEY_X))
	{
		isShowing = !isShowing;
	}
}

void onRender(CRules@ this)
{
	Vec2f mid(getScreenWidth()/2.0f, getScreenHeight()/2.0f);

	if(isShowing)
	{
		if (GUI::isFontLoaded("bunniE"))
			GUI::SetFont("bunniE");
		else
			GUI::SetFont("menu");
		GUI::DrawIcon(helpFilename, 0, size, Vec2f(mid.x-size.x/2, mid.y-size.y/2), 0.5f);
		//GUI::DrawWindow(Vec2f(mid.x - 10.0f - size.x/2, mid.y - 10.0f - size.y/2), Vec2f(mid.x + size.x/2 , mid.y + size.y/2));
		//GUI::DrawText( txt, Vec2f(mid.x - 185.0f, mid.y - 200.0f), Vec2f(mid.x + 220.0f, mid.y - 10.0f), color_black, true, true, true );
		//GUI::DrawText(Update_Entry, Vec2f(mid.x - size.x/2+150, mid.y - size.y/2+210), fontColor);
		drawRulesFont(Update_Entry, fontColor, Vec2f(mid.x - size.x/2+150, mid.y - size.y/2+210), Vec2f(mid.x - size.x/2+150, mid.y - size.y/2+210), false, false);
	}
}