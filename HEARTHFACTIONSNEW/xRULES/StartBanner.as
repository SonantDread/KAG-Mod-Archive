#define CLIENT_ONLY

Vec2f bannerPos = Vec2f_zero;

bool minimap = true;

void onInit(CRules@ this)
{
    if (!GUI::isFontLoaded("AveriaSerif-Bold_32"))
    {
        string AveriaSerif = CFileMatcher("AveriaSerif-Bold.ttf").getFirst();
        GUI::LoadFont("AveriaSerif-Bold_32", AveriaSerif, 32, true);
    }

    minimap = this.minimap;
    onRestart(this);
}

void onRestart(CRules@ this)
{
	Driver@ driver = getDriver();
    bannerPos = Vec2f(driver.getScreenWidth()/2, driver.getScreenHeight()/5);

    this.minimap = minimap;
}

void onStateChange(CRules@ this, const u8 oldState)
{
    Driver@ driver = getDriver();
    if (driver !is null)
    {
        this.minimap = false;
    }
}

void onRender(CRules@ this)
{
    Driver@ driver = getDriver();
    if (driver !is null)
    {
        bannerPos = Vec2f(driver.getScreenWidth()/2, driver.getScreenHeight()/5);

        if (this.get_u32("match_time") < 700)
        {
        	DrawBanner(bannerPos, this.getTeamWon());
        }

        this.SetGlobalMessage("");
    }
}

void DrawBanner(Vec2f center, int team)
{
    Vec2f offset = Vec2f_zero;

    GUI::SetFont("AveriaSerif-Bold_32");
    GUI::DrawTextCentered(getTranslatedString("Bring offerings to The Fire to progress."), center, SColor(255, 190, 30, 30));
}