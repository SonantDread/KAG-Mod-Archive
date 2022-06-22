// took from FFA gamemode...
// ...its not like i cant do that, i made FFA mod :\

#define CLIENT_ONLY

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) {return;}

	GUI::SetFont("menu");
	float font_height = getFontHeight();

	for(int i = 0; i < blobs_for_hp.size(); i++)
	{
		CBlob@ blob = blobs_for_hp[i];
		string name = blob.getPlayer() is null ? "Cat man John" : blob.getPlayer().getCharacterName();
		Vec2f pos = blob.getInterpolatedPosition() + Vec2f(0, 10);
		float inHP = blob.getInitialHealth();
		int hearts = inHP*2;
		float HP = blob.getHealth();
		int HPinHearts = HP*2*4;
		//print("HP: "+HP);
		Vec2f hearts_pos = getDriver().getScreenPosFromWorldPos(pos);
		hearts_pos.x -= offset*inHP;
		for(int j = 0; j < hearts; j++)
		{
			int frame = Maths::Clamp((HPinHearts)-j*4, 0, 4);
			//print("frame: "+frame);
			GUI::DrawIcon("HealthBar.png", frame, Vec2f(12,12), hearts_pos);
			hearts_pos.x += offset;
		}
		Vec2f name_pos = getDriver().getScreenPosFromWorldPos(pos)+Vec2f(0, font_height*5.2f);
		Vec2f dim;
		GUI::GetTextDimensions(name, dim);
		dim.x += 2;
		GUI::DrawRectangle(name_pos-(dim/2), name_pos+(dim/2), 0x8000280E);
		GUI::DrawTextCentered(name, name_pos-Vec2f(3,3), color_white);
	}
}

bool dead;
bool mous;
bool cato;
bool spec;
CBlob@[] blobs_for_hp;
int offset = 24; // icon width

void onTick(CRules@ this)
{
	blobs_for_hp.clear();

	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) {return;}

	dead = p.getBlob() is null;
	mous = p.getTeamNum() == 1 && !dead;
	cato = p.getTeamNum() == 0 && !dead;
	spec = !mous && !cato;
	
	CBlob@[] temp;
	if(getBlobsByTag("player", @temp))
	{
		if(mous || cato) // show mous or cato
		{
			CControls@ controls = getControls();
			if(controls !is null)
			{
				Vec2f mousepos = controls.getMouseWorldPos();
				for(int i = 0; i < temp.size(); i++)
				{
					CBlob@ blob = temp[i];
					if(blob is getLocalPlayerBlob()) continue;
					if(cato && blob.getTeamNum() != 0) continue;
					if(mous && blob.getTeamNum() != 1) continue;
					if((mousepos - blob.getPosition()).Length() < 14)
					{
						blobs_for_hp.push_back(@blob);
					}
				}
			}
		}
		else if(spec) // show only cato, but dont care about mouse pos
		{
			CControls@ controls = getControls();
			if(controls !is null)
			{
				Vec2f mousepos = controls.getMouseWorldPos();
				for(int i = 0; i < temp.size(); i++)
				{
					CBlob@ blob = temp[i];
					if(blob is getLocalPlayerBlob()) continue;
					if(blob.getTeamNum() != 0) continue;
					
					blobs_for_hp.push_back(@blob);
				}
			}
		}
	}
}
