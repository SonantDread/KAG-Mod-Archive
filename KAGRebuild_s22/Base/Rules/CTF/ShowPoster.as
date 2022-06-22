#define CLIENT_ONLY

bool showtut = true;

void onTick(CRules@ this)
{
	CControls@ controls = getControls();

	if (controls.isKeyJustPressed(KEY_KEY_X))
	{
		showtut = false;
	}

	if (controls.isKeyJustPressed(KEY_KEY_P))
	{
		showtut = true;
	}
}

void onRender(CRules@ this)
{
	float screen_size_y = getDriver().getScreenHeight();
    float resolution_scale = screen_size_y / 720.f;

    Vec2f middle(getDriver().getScreenWidth() / 2.0f, getDriver().getScreenHeight() / 2.0f);

	const string tutorial_image = "Poster.png";

	if(showtut)
	{
		if (resolution_scale >= 2.0)
			GUI::DrawIcon(tutorial_image, Vec2f(middle.x - 720, middle.y - (getDriver().getScreenHeight() / 2.0f)), 2.0f);
		else 
			GUI::DrawIcon(tutorial_image, Vec2f(middle.x - 360, middle.y - 360), 1.0f);
	}
}
