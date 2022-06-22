#include "SSK_Structs.as";
#include "TeamColour.as";

/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/

void onInit(CRules@ this)
{
	CBitStream stream;
	stream.write_u16(0xDEAD);
	this.set_CBitStream("ssk_serialised_team_hud", stream);
}

void onRender(CRules@ this)
{
	CPlayer@ localPlayer = getLocalPlayer();

	if (localPlayer is null || !localPlayer.isMyPlayer()) { return; }

	GUI::SetFont("menu");

	CBitStream serialised_team_hud;
	this.get_CBitStream("ssk_serialised_team_hud", serialised_team_hud);

	if (serialised_team_hud.getBytesUsed() > 10)
	{
		serialised_team_hud.Reset();
		u16 check;

		if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
		{
			const string gui_image_fname = "Rules/SSK/SSKGui.png";

			while (!serialised_team_hud.isBufferEnd())
			{
				SSK_HUD hud(serialised_team_hud);
				Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);
				if (hud.gameType != GameTypes::FFA_STOCK)
				{
					GUI::DrawIcon(gui_image_fname, 0, Vec2f(128, 32), topLeft, 1.0f, hud.team_num);
				}
				int team_player_count = 0;
				int team_dead_count = 0;
				int step = 0;
				Vec2f startIcons = Vec2f(64, 8);
				Vec2f startSkulls = Vec2f(160, 8);
				string player_char = "";
				int size = int(hud.unit_pattern.size());

				if (hud.gameType != GameTypes::FFA_STOCK)
				{
					while (step < size)
					{
						player_char = hud.unit_pattern.substr(step, 1);
						step++;

						if (player_char == " ") { continue; }

						if (player_char != "s")
						{
							int player_frame = 1;

							if (player_char == "a")
							{
								player_frame = 2;
							}

							GUI::DrawIcon(gui_image_fname, 12 + player_frame, Vec2f(16, 16), topLeft + startIcons + Vec2f(team_player_count * 8, 0) , 1.0f, hud.team_num);
							team_player_count++;
						}
						else
						{
							GUI::DrawIcon(gui_image_fname, 12 , Vec2f(16, 16), topLeft + startSkulls + Vec2f(team_dead_count * 16, 0) , 1.0f, hud.team_num);
							team_dead_count++;
						}
					}

					if (hud.spawn_time != 255)
					{
						string time = "" + hud.spawn_time;
						GUI::DrawText(time, topLeft + Vec2f(196, 42), SColor(255, 255, 255, 255));
					}
				}

				if (hud.gameType == GameTypes::TDM)
				{
					string kills = getTranslatedString("WARMUP");

					if (hud.kills_limit > 0)
					{
						kills = getTranslatedString("KILLS") + ": " + hud.kills + "/" + hud.kills_limit;
					}
					else if (hud.kills_limit == -2)
					{
						kills = getTranslatedString("SUDDEN DEATH");
					}

					GUI::DrawText(kills, topLeft + Vec2f(64, 42), SColor(255, 255, 255, 255));
				}
				else if (hud.gameType == GameTypes::TEAM_STOCK)
				{
					// team stock count
					string teamStocks = getTranslatedString("STOCKS") + ": " + hud.teamStocks;
					GUI::DrawText(teamStocks, topLeft + Vec2f(64, 42), SColor(255, 255, 255, 255));

					// personal player stock count
					GUI::DrawIcon("SSKGui2.png", 0, Vec2f(74, 16), Vec2f(264, 16), 1.0f, 0);
					string playerStocks = getTranslatedString("YOUR STOCKS") + "   " + this.get_u8("playerStocks"+localPlayer.getUsername());
					GUI::DrawText(playerStocks, Vec2f(270, 24), SColor(255, 255, 255, 255));
				}
				else if (hud.gameType == GameTypes::FFA_STOCK)
				{
					Vec2f topLeftFFA = Vec2f(8, 8);

					// personal player stock count
					GUI::DrawIcon("SSKGui2.png", 0, Vec2f(74, 16), topLeftFFA, 1.0f, 0);
					string playerStocks = getTranslatedString("YOUR STOCKS") + "   " + this.get_u8("playerStocks"+localPlayer.getUsername());
					GUI::DrawText(playerStocks, Vec2f(topLeftFFA.x + 6, 16), SColor(255, 255, 255, 255));

					// player stock counts
					GUI::DrawText("PLAYER STOCKS", Vec2f(topLeftFFA.x, topLeftFFA.y + 44), SColor(255, 255, 255, 255));
					for (u32 i = 0; i < getPlayersCount(); i++)
					{
						CPlayer@ player = getPlayer(i);

						if (player.getTeamNum() == this.getSpectatorTeamNum())
						{
							continue;
						}

						topLeftFFA.y += 16;

						// if player is not dead, set color to team color
						SColor pColor = 0xff505050;					
						CBlob@ pBlob = player.getBlob();
						if (pBlob !is null)
						{
							pColor = getTeamColor( pBlob.getTeamNum() );
						}

						string pCharName = player.getCharacterName();
						u8 charNameMaxLen = 16;
						if (pCharName.size() > charNameMaxLen)
						{
							pCharName.resize(charNameMaxLen);
							pCharName.opAddAssign("...");
						}

						GUI::DrawText(pCharName, Vec2f(topLeftFFA.x, topLeftFFA.y + 48), pColor);

						int pStocks = this.get_u8("playerStocks"+player.getUsername());
						string pStocksString = ""+pStocks;
						if (!this.isWarmup() && pStocks == 0)
						{
							pStocksString = "ELIMINATED";
						}
						GUI::DrawText(pStocksString, Vec2f(topLeftFFA.x + 144, topLeftFFA.y + 48), pColor);
					}
				}
			}
		}

		serialised_team_hud.Reset();
	}

	string propname = "ssk spawn time " + localPlayer.getUsername();
	if (localPlayer.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			if (spawn == 254)
			{
				GUI::DrawText(getTranslatedString("In Queue to Respawn...") , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
			else if (spawn == 253)
			{
				GUI::DrawText(getTranslatedString("No Respawning - Wait for the Game to End.") , Vec2f(getScreenWidth() / 2 - 180, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
			else
			{
				GUI::DrawText(getTranslatedString("Respawning in:") + " " + spawn , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
			}
		}
	}
}
