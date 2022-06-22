//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos.as";
#include "Hunger.as"

void renderBackBar(Vec2f origin, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width / scale - 64; step += 64.0f * scale)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderFrontStone(Vec2f farside, f32 width, f32 scale)
{
	for (f32 step = 0.0f; step < width / scale - 16.0f * scale * 2; step += 16.0f * scale * 2)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-step * scale - 32 * scale, 0), scale);
	}

	if (width > 16)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale, 0), scale);
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside, scale);
}

void renderHPBar(CBlob@ blob, Vec2f origin)
{
	string heartFile = "GUI/HeartNBubble.png";
	int segmentWidth = 32;
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	int HPs = 0;

	for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16, 32), origin + Vec2f(segmentWidth * HPs, 0));
		f32 thisHP = blob.getHealth() - step;

		if (thisHP > 0)
		{
			Vec2f heartoffset = (Vec2f(2, 10) * 2);
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;

			if (thisHP <= 0.125f)
			{
				GUI::DrawIcon(heartFile, 4, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.25f)
			{
				GUI::DrawIcon(heartFile, 3, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.375f)
			{
				GUI::DrawIcon(heartFile, 2, Vec2f(12, 12), heartpos);
			}
			else
			{
				GUI::DrawIcon(heartFile, 1, Vec2f(12, 12), heartpos);
			}
		}

		HPs++;
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), origin + Vec2f(32 * HPs, 0));
}
void renderEquip(CBlob@ blob, Vec2f origin)
{
	GUI::SetFont("tempesta");
	GUI::DrawPane(origin + Vec2f(-5, -35), origin + Vec2f(170, 25));
	origin.y -= 30;
	if (blob.get_s8("hunger") > 18)
	{
		GUI::DrawText("You are bloated! ", origin, SColor(255, 135, 243, 106));
		origin.y += 20;
		GUI::DrawText("You cannot eat anymore.", origin, SColor(255, 53, 51, 43));
	}
	else if (blob.get_s8("hunger") > 4)
	{
		GUI::DrawText("You are sated. ", origin, SColor(255, 167, 226, 95));
		origin.y += 20;
		GUI::DrawText("You do not need food for", origin, SColor(255, 53, 51, 43));
		origin.y += 10;
		GUI::DrawText("the time being.", origin, SColor(255, 53, 51, 43));
	}
	else if (blob.get_s8("hunger") > 1)
	{
		GUI::DrawText("You are hungry. ", origin, SColor(255, 196, 223, 66));
		origin.y += 20;
		GUI::DrawText("Find or cook some food or", origin, SColor(255, 53, 51, 43));
		origin.y += 10;
		GUI::DrawText("soon you will perish.", origin, SColor(255, 53, 51, 43));
	}
	else if (blob.get_s8("hunger") > 0)
	{
		GUI::DrawText("You are beginning to starve. ", origin, SColor(255, 229, 124, 67));
		origin.y += 20;
		GUI::DrawText("Quickly eat some food or", origin, SColor(255, 53, 51, 43));
		origin.y += 10;
		GUI::DrawText("you will perish.", origin, SColor(255, 53, 51, 43));
	}
	else if (blob.get_s8("hunger") == 0)
	{
		GUI::DrawText("You are starving!", origin, SColor(255, 255, 40, 40));
		origin.y += 20;
		GUI::DrawText("Hurry up and eat or die.", origin, SColor(255, 53, 51, 43));
	}
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f dim = Vec2f(402, 64);
	Vec2f ul(HUD_X - dim.x / 2.0f, HUD_Y - dim.y + 12);
	Vec2f lr(ul.x + dim.x, ul.y + dim.y);
	//GUI::DrawPane(ul, lr);
	renderBackBar(ul, dim.x, 1.0f);
	u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
	f32 width = bar_width_in_slots * 40.0f;
	renderFrontStone(ul + Vec2f(dim.x + 40, 0), width, 1.0f);
	renderHPBar(blob, ul);
	renderEquip(blob, ul + Vec2f(-200, 30));
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}