const u8 default_aircount = 180; //6s, remember to update runnerdrowning.as

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

string[] scroll_names = {"flight", "infinite wallrun", "use drill"};

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();

	GUI::SetFont("menu");

	f32 text_offset = 0.0f;
	for (int i=0; i < scroll_names.size(); ++i)
	{
		if (blob.get_bool(scroll_names[i]) && blob.get_u32(scroll_names[i] + " duration") > getGameTime())
		{
			GUI::DrawTextCentered("Scroll of " + scroll_names[i] + " active for " + ((blob.get_u32(scroll_names[i] + " duration") - getGameTime()) / 30) + " more seconds.", Vec2f(getScreenWidth() / 2, getScreenHeight() / 4 - 70.0f - text_offset),
			              SColor(255, 255, 55, 55));

			text_offset += 20.0f;
		}
	}

	if (getHUD().hasButtons())
	{
		return;
	}

	//draw air bubbles
	s32 extra = 1;
	s32 offset = -30;
	s32 maxaircount = default_aircount + offset;
	s32 aircount = blob.get_u8("air_count") + offset + extra;
	if (aircount < default_aircount + offset + extra)
	{
		// draw drown indicator
		Vec2f p = blob.getInterpolatedPosition() + Vec2f(0.0f, -blob.getHeight() * 1.5f);
		p.x -= 8;
		Vec2f pos = getDriver().getScreenPosFromWorldPos(p);
		Vec2f dim(8, 8);

		s32 bubblecount = maxaircount / 30; //1 bubble = 1 second
		for (s32 bubble = 0; bubble < bubblecount; bubble++)
		{
			s32 frac = aircount - (bubble * 30);

			u32 frame = (frac > 24) ? 0 : (frac > 18) ? 1 : (frac > 12) ? 2 : 3;
			if (frac > 6)
			{
				GUI::DrawIcon("Sprites/Water/AirBubble.png", frame, dim,
				              pos + Vec2f(-((bubblecount - 1) / 2.0f - bubble - 0.5f) * dim.x, 0) * 2.0f * getCamera().targetDistance,
				              getCamera().targetDistance);
			}
		}
	}
}
