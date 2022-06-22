#include "CTF_Structs.as";

u32 wood_count_blue = 0;
u32 wood_count_red = 0;
u32 stone_count_blue = 0;
u32 stone_count_red = 0;
u32 gold_count_blue = 0;
u32 gold_count_red = 0;

void onTick(CRules@ this)
{
	if (getGameTime() % 30 == 0)
	{
		CMap@ map = getMap();

			CBlob@[] wood_list;
			getBlobsByName("mat_wood", @wood_list);
			wood_count_blue = 0;
			wood_count_red = 0;
			for (int i=0; i<wood_list.length; ++i)
			{
				if (wood_list[i].getPosition().x < map.tilemapwidth * 8 / 2)
				{
					wood_count_blue += wood_list[i].getQuantity();
				}
				else
				{
					wood_count_red += wood_list[i].getQuantity();
				}
			}

			CBlob@[] stone_list;
			getBlobsByName("mat_stone", @stone_list);
			stone_count_blue = 0;
			stone_count_red = 0;
			for (int i=0; i<stone_list.length; ++i)
			{
				if (stone_list[i].getPosition().x < map.tilemapwidth * 8 / 2)
				{
					stone_count_blue += stone_list[i].getQuantity();
				}
				else
				{
					stone_count_red += stone_list[i].getQuantity();
				}
			}

			CBlob@[] gold_list;
			getBlobsByName("mat_gold", @gold_list);
			gold_count_blue = 0;
			gold_count_red = 0;
			for (int i=0; i<gold_list.length; ++i)
			{
				if (gold_list[i].getPosition().x < map.tilemapwidth * 8 / 2)
				{
					gold_count_blue += gold_list[i].getQuantity();
				}
				else
				{
					gold_count_red += gold_list[i].getQuantity();
				}
			}
	}
}

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart( CRules@ this )
{
    UIData ui;

    CBlob@[] flags;
    if(getBlobsByName("ctf_flag", flags))
    {
        for(int i = 0; i < flags.size(); i++)
        {
            CBlob@ blob = flags[i];

            ui.flagIds.push_back(blob.getNetworkID());
            ui.flagStates.push_back("f");
            ui.flagTeams.push_back(blob.getTeamNum());
            ui.addTeam(blob.getTeamNum());


        }

    }

    this.set("uidata", @ui);

    CBitStream bt = ui.serialize();

	this.set_CBitStream("ctf_serialised_team_hud", bt);
	this.Sync("ctf_serialised_team_hud", true);

	//set for all clients to ensure safe sync
	this.set_s16("stalemate_breaker", 0);

}

//only for after the fact if you spawn a flag
void onBlobCreated( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

    if(blob.getName() == "ctf_flag")
    {
        UIData@ ui;
        this.get("uidata", @ui);

        if(ui is null) return;

        ui.flagIds.push_back(blob.getNetworkID());
        ui.flagStates.push_back("f");
        ui.flagTeams.push_back(blob.getTeamNum());
        ui.addTeam(blob.getTeamNum());

        CBitStream bt = ui.serialize();

		this.set_CBitStream("ctf_serialised_team_hud", bt);
		this.Sync("ctf_serialised_team_hud", true);

    }

}

void onBlobDie( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

    if(blob.getName() == "ctf_flag")
    {
        UIData@ ui;
        this.get("uidata", @ui);

        if(ui is null) return;

        int id = blob.getNetworkID();

        for(int i = 0; i < ui.flagIds.size(); i++)
        {
            if(ui.flagIds[i] == id)
            {
                ui.flagStates[i] = "c";

            }

        }

        CBitStream bt = ui.serialize();

		this.set_CBitStream("ctf_serialised_team_hud", bt);
		this.Sync("ctf_serialised_team_hud", true);

    }

}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	CBitStream serialised_team_hud;
	this.get_CBitStream("ctf_serialised_team_hud", serialised_team_hud);

	if (serialised_team_hud.getBytesUsed() > 8)
	{
		serialised_team_hud.Reset();
		u16 check;

		if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
		{
			const string gui_image_fname = "Rules/CTF/CTFGui.png";

			int something_else = 0;

			while (!serialised_team_hud.isBufferEnd())
			{
				CTF_HUD hud(serialised_team_hud);
				Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);

				int step = 0;
				Vec2f startFlags = Vec2f(0, 8);

				string pattern = hud.flag_pattern;
				string flag_char = "";
				int size = int(pattern.size());
				something_else = size;

				GUI::DrawRectangle(topLeft + Vec2f(4, 4), topLeft + Vec2f(size * 32 + 26, 60));

				while (step < size)
				{
					flag_char = pattern.substr(step, 1);

					int frame = 0;
					//c captured
					if (flag_char == "c")
					{
						frame = 2;
					}
					//m missing
					else if (flag_char == "m")
					{
						frame = getGameTime() % 20 > 10 ? 1 : 2;
					}
					//f fine
					else if (flag_char == "f")
					{
						frame = 0;
					}

					GUI::DrawIcon(gui_image_fname, frame , Vec2f(16, 24), topLeft + startFlags + Vec2f(14 + step * 32, 0) , 1.0f, hud.team_num);

					step++;
				}
			}

			Vec2f continueTopLeft = Vec2f(40 + something_else * 32, 16);

			CMap@ map = getMap();

			GUI::SetFont("hud");

			CTeam@ blue = getRules().getTeam(0);
			string blue_wood_message = wood_count_blue;
			string blue_stone_message = stone_count_blue;
			string blue_gold_message = gold_count_blue;
			GUI::DrawPane(continueTopLeft + Vec2f(0, 4), continueTopLeft + Vec2f(190, 40), blue.color);
			GUI::DrawText("W:", continueTopLeft + Vec2f(0, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(blue_wood_message, continueTopLeft + Vec2f(20, 12), SColor(255, 204, 100, 31));
			GUI::DrawText("S:", continueTopLeft + Vec2f(68, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(blue_stone_message, continueTopLeft + Vec2f(82, 12), SColor(255, 151, 167, 146));
			GUI::DrawText("G:", continueTopLeft + Vec2f(130, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(blue_gold_message, continueTopLeft + Vec2f(145, 12), SColor(255, 254, 165, 61));

			continueTopLeft += Vec2f(0, 64);

			CTeam@ red = getRules().getTeam(1);
			string red_wood_message = wood_count_red;
			string red_stone_message = stone_count_red;
			string red_gold_message = gold_count_red;
			GUI::DrawPane(continueTopLeft + Vec2f(0, 4), continueTopLeft + Vec2f(190, 40), red.color);
			GUI::DrawText("W:", continueTopLeft + Vec2f(0, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(red_wood_message, continueTopLeft + Vec2f(20, 12), SColor(255, 204, 100, 31));
			GUI::DrawText("S:", continueTopLeft + Vec2f(68, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(red_stone_message, continueTopLeft + Vec2f(82, 12), SColor(255, 151, 167, 146));
			GUI::DrawText("G:", continueTopLeft + Vec2f(130, 12), SColor(255, 255, 255, 255));
			GUI::DrawText(red_gold_message, continueTopLeft + Vec2f(145, 12), SColor(255, 254, 165, 61));
		}

		serialised_team_hud.Reset();
	}

	string propname = "ctf spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			string spawn_message = getTranslatedString("Respawning in: {SEC}").replace("{SEC}", ((spawn > 250) ? getTranslatedString("approximatively never") : ("" + spawn)));

			GUI::SetFont("hud");
			GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	this.SyncToPlayer("ctf_serialised_team_hud", player);
}
