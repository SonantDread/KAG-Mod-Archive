#include "CTF_Structs.as";
#include "CharmCommon.as";

/*string get_font(string file_name, f32 size)
{
    string result = file_name+"_"+size;
    if (!GUI::isFontLoaded(result)) {
        string full_file_name = CFileMatcher(file_name+".ttf").getFirst();
        // TODO(hobey): apparently you cannot load multiple different sizes of a font from the same font file in this api?
        GUI::LoadFont(result, full_file_name, size, true);
    }
    return result;
}/*

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/

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

			while (!serialised_team_hud.isBufferEnd())
			{
				CTF_HUD hud(serialised_team_hud);

				Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);

				int step = 0;
				Vec2f startFlags = Vec2f(0, 8);

				string pattern = hud.flag_pattern;
				string flag_char = "";
				int size = int(pattern.size());

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

			/*const string[] charmNames = { "heartcharm",
								  "falldmgcharm",
								  "clockcharm",
								  "4xcharm",
								  "waterhealcharm",

								  "dashcharm",
								  "fireswordcharm",
								  "heavycharm",
								  "velocity3xcharm",
								  "bombsondeathcharm",

								  "speedonkillcharm",
								  "teleportcharm",
								  "killerqueencharm",
								  "stasischarm",
								  "arrowraincharm",

								  "360slashcharm",
								  "swapplacescharm",
								  "divineprotectioncharm",
								  "infinitewallruncharm",
								  "materialsextractioncharm",

								  "coinincreasecharm",
								  "2heartsondeathcharm",
								  "lightcharm",
								  "quickbuildcharm",
								  "treeclimbcharm"
								};

			const string[] charmIcons = { "HeartCharm",
								  "FallDmgCharm",
								  "ClockCharm",
								  "4xCharm",
								  "WaterHealCharm",

								  "DashCharm",
								  "FireSwordCharm",
								  "HeavyCharm",
								  "LForceCharm",
								  "SkullBombCharm",

								  "SpeedOnKillCharm",
								  "TeleportCharm",
								  "KillerQueenCharm",
								  "StasisCharm",
								  "ArrowRainCharm",

								  "360SlashCharm",
								  "SwapPlacesCharm",
								  "DivineProtectionCharm",
								  "InfiniteWallrunCharm",
								  "MaterialsExtractionCharm",

								  "CoinIncreaseCharm",
								  "2HeartsCharm",
								  "LightCharm",
								  "QuickBuildCharm",
								  "TreeClimbCharm"
								};*/

			string[] charmNames = {};

			string[] charmIcons = {};

			if (!this.exists("playercharms_" + p.getUsername()))
			{
				PlayerCharm[] charms;
				this.set("playercharms_" + p.getUsername(), charms);
			}

			PlayerCharm[]@ charms;

			if (this.get("playercharms_" + p.getUsername(), @charms))
			{
				for (uint i = 0 ; i < charms.length; i++)
				{
					PlayerCharm @pcharm = charms[i];

					if (pcharm.active == false) continue;
	
					charmNames.push_back(pcharm.configFilename);
					charmIcons.push_back(pcharm.iconName);
				}
			}

			if (this.get("playercharms_" + p.getUsername(), @charms))
			{
				for (uint i = 0 ; i < charms.length; i++)
				{
					PlayerCharm @pcharm = charms[i];

					if (pcharm.active == true) continue;
	
					charmNames.push_back(pcharm.configFilename);
					charmIcons.push_back(pcharm.iconName);
				}
			}

			string username = getLocalPlayer().getUsername();

			Vec2f startCharms = Vec2f(0, 200);

			Vec2f startDifferent = Vec2f(100, 200);

			uint d = 0;

			if (!this.exists(username + "_size"))
			{
   				this.set_f32(username + "_size", 1.0f);
   				this.Sync(username + "_size", true);
   			}

			float resolution_scale = this.get_f32(username + "_size");

			int h = 1;

						u8 yop;

						if(resolution_scale < 2.0f) yop = 1;
						else if(resolution_scale <= 2.9f) yop = 2;
						else yop = 3;

						uint sizev = 10 * yop;
						string result = "AveriaSerif-Bold" + yop;

					    if (!GUI::isFontLoaded(result)) 
					    {
					        string full_file_name = CFileMatcher("AveriaSerif-Bold" + yop + ".ttf").getFirst();
					        GUI::LoadFont(result, full_file_name, sizev, true);
					    }

					    if(resolution_scale < 2.0f)
					    {
							GUI::SetFont("AveriaSerif-Bold1");
						}

						else if(resolution_scale <= 2.9f)
						{
							GUI::SetFont("AveriaSerif-Bold2");
						}

						else if(resolution_scale > 2.9f)
						{
							GUI::SetFont("AveriaSerif-Bold3");
						}

						//GUI::SetFont("AveriaSerif-Bold_" + sizev);

			for(uint i = 0; i < charmNames.length; ++i)
			{
				string currentCharm = charmNames[i] + "_" + username;
				string charmIcon = charmIcons[i];
				if(this.get_bool(currentCharm) == true && getLocalPlayer().isMyPlayer())
				{
					GUI::DrawRectangle(startCharms + Vec2f(16, d * 32 * resolution_scale), startCharms + Vec2f(16 + 32 * resolution_scale, d * 32 * resolution_scale + 32 * resolution_scale));
					GUI::DrawIconByName(charmIcon, startCharms + Vec2f(16, d * 32 * resolution_scale), 0.5f * resolution_scale);

					CRules@ rules = getRules();

					if(getCharmByName(charmNames[i]).active || charmNames[i] == "divineprotectioncharm")
					{

						u32 hmm;

						hmm = ((getRules().get_u32(charmNames[i] + "_cd" + username) + (getCharmByName(charmNames[i]).cooldown)) - getGameTime()) / 30 + 1;

						if(hmm > getCharmByName(charmNames[i]).cooldown / 30 + 1)
						hmm = 0;

						string textd;

						if(charmNames[i] != "dashcharm" && charmNames[i] != "divineprotectioncharm")
						{
							textd = "Ability Key: [" + h +"]\nCooldown: " + hmm + "s";
							++h;
						}
						else if(charmNames[i] == "dashcharm")
						{
							textd = "Ability Key: [S]" + "\nCooldown: " + hmm + "s";
							//if(i>1) --i;
						}
						else if(charmNames[i] == "divineprotectioncharm")
						{
							textd = "Cooldown: " + hmm + "s";
						}

						GUI::DrawText(textd, startDifferent + Vec2f(16, d * 32 * resolution_scale), color_white);
						//GUI::DrawText(textd, startDifferent + Vec2f(16, d * 32 * resolution_scale), startDifferent + Vec2f(16 + 32 * resolution_scale * 100, d * 32 * resolution_scale + 32 * resolution_scale), color_white, true, true);
					}

					d++;
				}
			}
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
