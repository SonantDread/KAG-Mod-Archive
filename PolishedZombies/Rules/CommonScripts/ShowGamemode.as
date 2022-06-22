#define CLIENT_ONLY

int TIME = 400;
int showTime = TIME;
bool showTut = false;
const string tutorial_image = "GUI/TutorialPg1.png";

void Reset(CRules@ this)
{
	showTime = TIME;
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(KEY_F2))
	{
		showTut = !showTut;
	}
}

void onRender(CRules@ this)
{

	if(showTut)
	{
		GUI::DrawIcon(tutorial_image, Vec2f((getScreenWidth() / 2.0f) - (720 / 2), 0), 0.5f);
	}

	if (showTime > 0)
	{
		showTime--;
		Vec2f middle(getScreenWidth() / 2.0f, showTime < 120 ? showTime : 120.0f);

		//gamemode info
		const string name = this.gamemode_name;
		const string info = this.gamemode_info;
		const string servername = getNet().joined_servername;

		//build display strings
		string display = getTranslatedString("  Gamemode: {GAMEMODE}").replace("{GAMEMODE}", getTranslatedString(name));

		if (name != info && info != "")
			display += "\n\n " + getTranslatedString(info);

		display += getTranslatedString("\n  Server: {SERVERNAME}\n").replace("{SERVERNAME}", servername);

		GUI::SetFont("menu");
		GUI::DrawText(display ,
		              Vec2f(middle.x - 140.0f, middle.y + 20.0f), Vec2f(middle.x + 140.0f, middle.y + 80.0f), color_black, true, true, true);
	}
}
