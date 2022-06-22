void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw self indicator
	Vec2f p = blob.getPosition() + Vec2f(0.0f, -blob.getHeight() * 3.0f);
	p.x -= 8;
	Vec2f pos = getDriver().getScreenPosFromWorldPos(p);
	pos.y += -2 + Maths::FastSin(getGameTime() / 4.5f) * 3.0f;
	Vec2f dim(16, 16);
	GUI::DrawIcon("GUI/PartyIndicator.png", 2, dim, pos, getCamera().targetDistance);
}